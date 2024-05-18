# frozen_string_literal: true

require "cgi"
require "dtext" # Load the C extension.

# The DText class handles Danbooru's markup language, DText. Parsing DText is
# handled by the DTextRagel class in the dtext_rb gem.
#
# @see https://github.com/evazion/dtext_rb
# @see https://danbooru.donmai.us/wiki_pages/help:dtext
class DText
  extend Memoist

  DEFAULT_EMOJI_MAP = Danbooru.config.dtext_emojis
  DEFAULT_EMOJI_LIST = DEFAULT_EMOJI_MAP.keys.map(&:downcase)

  # post #1234, pixiv #1234, etc. The canonical list is in lib/dtext_rb/ext/dtext/dtext.cpp.rl.
  SHORTLINKS = %w[
    alias appeal artist asset ban bur comment dmail dmail favgroup feedback flag forum implication mod action modreport
    note pool post topic topic user wiki
    issue pull commit
    artstation deviantart gelbooru nijie pawoo pixiv pixiv sankaku seiga twitter yandere
  ]

  attr_reader :dtext, :inline, :disable_mentions, :media_embeds, :base_url, :domain, :alternate_domains, :emoji_list, :emoji_map, :options

  # Preprocess a set of DText messages and collect all tag, artist, wiki page, post, and media asset references. Called
  # before rendering a collection of DText messages (e.g. comments or forum posts) to do all database lookups in one batch.
  #
  # @param [Array<String>] a list of DText strings
  # @return [Hash<Symbol, ActiveRecord::Relation>] The set of wiki pages, tags, artists, posts, and media assets.
  def self.preprocess(dtext_messages)
    references = Array.wrap(dtext_messages).map { |message| parse_dtext_references(message) }
    references = references.reduce({}) { |all, hash| all.merge(hash) { |_key, left, right| left + right } }
    references.transform_values!(&:uniq)

    tag_aliases = TagAlias.where(id: references[:tag_aliases]).to_a
    tag_implications = TagImplication.where(id: references[:tag_implications]).to_a
    bulk_update_requests = BulkUpdateRequest.includes(:approver).where(id: references[:bulk_update_requests]).to_a

    references[:wiki_pages] ||= []
    references[:wiki_pages] += tag_aliases.pluck(:antecedent_name, :consequent_name).flatten
    references[:wiki_pages] += tag_implications.pluck(:antecedent_name, :consequent_name).flatten
    references[:wiki_pages] += bulk_update_requests.pluck(:tags).flatten
    references[:wiki_pages].uniq!

    wiki_pages = WikiPage.where(title: references[:wiki_pages])
    tags = Tag.where(name: references[:wiki_pages])
    artists = Artist.where(name: references[:wiki_pages])
    media_assets = MediaAsset.where(id: references[:media_assets])
    posts = Post.includes(:media_asset).where(id: references[:posts])

    { wiki_pages:, tags:, artists:, media_assets:, posts:, tag_aliases:, tag_implications:, bulk_update_requests: }
  end

  # @param dtext [String] The DText input.
  # @param inline [Boolean] If true, allow only inline constructs. Ignore block-level constructs, such as paragraphs, quotes, lists, and tables.
  # @param disable_mentions [Boolean] If true, don't parse @mentions.
  # @param media_embeds [Boolean] If true, allow `!post #123` syntax for embedding images.
  # @param base_url [String, nil] If present, convert relative URLs to absolute URLs.
  # @param domain [String, nil] If present, treat links to this domain as internal links rather than external links.
  # @param alternate_domains [Array<String>] A list of additional domains for this site where direct links will be converted to shortlinks
  #   (e.g on betabooru.donmai.us, https://danbooru.donmai.us/posts/1234 is converted to post #1234).
  # @param emoji_map [Hash<String, String>] A hash of emoji (name, value) pairs. The emoji `:name:` is replaced with the value (which may be an HTML <img> or a plaintext emoji).
  # @param emoji_list [Array<String>] The list of valid emoji names.
  def initialize(dtext, inline: false, disable_mentions: false, media_embeds: false, base_url: Rails.application.config.relative_url_root, domain: Danbooru::URL.parse!(Danbooru.config.canonical_url).host, alternate_domains: Danbooru.config.alternate_domains, emoji_map: DEFAULT_EMOJI_MAP, emoji_list: DEFAULT_EMOJI_LIST)
    @dtext = dtext
    @inline = inline
    @disable_mentions = disable_mentions
    @media_embeds = media_embeds
    @base_url = base_url
    @domain = domain
    @alternate_domains = alternate_domains
    @emoji_map = emoji_map
    @emoji_list = emoji_list
    @options = { inline:, disable_mentions:, media_embeds:, base_url:, domain:, alternate_domains:, emoji_list: }
  end

  # Convert a string of DText to HTML.
  #
  # Rendering DText may require looking up records in the database. The `references` parameter should contain all the
  # database records needed to render this piece of DText. This is used to batch together database lookups when
  # rendering a collection of DText messages on a page (e.g. comments or forum posts).
  #
  # @param references [Hash<Symbol, Array<ActiveRecord::Base>] The database records needed to render this DText.
  # @param current_user [User] The user viewing the DText (used for determining visibility of media embeds).
  # @return [String, nil] The HTML output
  def format_text(references: DText.preprocess([dtext]), current_user: User.anonymous)
    return nil if dtext.nil?

    fragment = parsed_html.dup

    fragment.css("media-embed").each do |node|
      replace_media_embed!(node, posts: references[:posts], media_assets: references[:media_assets], current_user:)
    end

    fragment.css("tag-request-embed").each do |node|
      replace_tag_request_embed!(node, tag_aliases: references[:tag_aliases], tag_implications: references[:tag_implications], bulk_update_requests: references[:bulk_update_requests])
    end

    fragment.css("a.dtext-wiki-link").each do |node|
      replace_wiki_link!(node, wiki_pages: references[:wiki_pages], tags: references[:tags], artists: references[:artists])
    end

    fragment.css("emoji").each do |node|
      replace_emoji!(node)
    end

    fragment.to_s.html_safe
  rescue DText::Error
    ""
  end

  # Replace an <a class="dtext-wiki-link"> tag with a colorized link.
  def replace_wiki_link!(node, wiki_pages:, tags:, artists:)
    path = Addressable::URI.parse(node["href"]).path
    name = path[%r!/wiki_pages/(.*)\z!i, 1]
    name = CGI.unescape(name)
    name = WikiPage.normalize_title(name)
    wiki = wiki_pages.find { _1.title == name }
    tag = tags.find { _1.name == name }
    artist = artists.find { _1.name == name }

    if tag.present?
      node["class"] += " tag-type-#{tag.category}"
    end

    if tag.present? && tag.artist?
      node["href"] = Routes.show_or_new_artists_path(name: name)

      if artist.blank?
        node["class"] += " dtext-artist-does-not-exist"
        node["title"] = "This artist page does not exist"
      end
    else
      if wiki.blank?
        node["class"] += " dtext-wiki-does-not-exist"
        node["title"] = "This wiki page does not exist"
      end

      if WikiPage.is_meta_wiki?(name)
        # skip (meta wikis aren't expected to have a tag)
      elsif tag.blank?
        node["class"] += " dtext-tag-does-not-exist"
        node["title"] = "This wiki page does not have a tag"
      elsif tag.empty?
        node["class"] += " dtext-tag-empty"
        node["title"] = "This wiki page does not have a tag"
      end
    end
  end

  # Replace a <media-embed> tag with an embedded image or video.
  #
  # Example:
  #
  #     <media-embed data-type="post" data-id="1234">Caption.</media-embed>
  #
  # Produces:
  #
  #     <article class="dtext-media-embed" data-type="post" data-id="1234">
  #       <div class="media-embed-image">
  #         <a href="/posts/1234">
  #           <img src="http://cdn.donmai.us/[...].jpg" width="123" height="456">
  #         </a>
  #       </div>
  #       <div class="media-embed-caption">Caption.</div>
  #     </article>
  def replace_media_embed!(node, posts:, media_assets:, current_user:)
    type = node["data-type"]
    id = node["data-id"].to_i
    caption = node.inner_html.presence

    if type == "post"
      asset = posts.find { _1.id == id }&.media_asset
      href = Routes.post_path(id)
    else
      asset = media_assets.find { _1.id == id }
      href = Routes.media_asset_path(id)
    end

    node.name = "article"
    node["class"] = "dtext-media-embed"
    node["data-type"] = type
    node["data-id"] = id

    if asset.nil? || !asset.active? || asset.is_flash? || !asset.policy(current_user).can_see_image?
      link_attributes = %{class="inactive-link flex items-center justify-center border rounded min-w-150px min-h-150px"}
      asset_html = ApplicationController.helpers.image_icon
      caption ||= "This #{type} is unavailable."
    elsif asset.is_image?
      variant = asset.variant(:"720x720")
      asset_html = %{<img src="#{variant.file_url}" width="#{variant.width}" height="#{variant.height}">}
    elsif asset.is_video? || asset.is_ugoira?
      variant = asset.is_ugoira? ? asset.variant(:sample) : asset.variant(:original)
      asset_html = %{<video src="#{variant.file_url}" width="#{variant.width}" height="#{variant.height}" autoplay controls muted loop>}
    end

    node.inner_html  = %{<div class="media-embed-image"><a #{link_attributes} href="#{href}">#{asset_html}</a></div>}
    node.inner_html += %{<div class="media-embed-caption">#{caption}</div>} if caption.present?
  end

  # Replace a <tag-request-embed> node with the contents of the alias, implication, or bulk update request.
  def replace_tag_request_embed!(node, tag_aliases:, tag_implications:, bulk_update_requests:)
    type = node["data-type"]
    id = node["data-id"].to_i

    case type
    when "tag-alias"
      request = tag_aliases.find { _1.id == id }
    when "tag-implication"
      request = tag_implications.find { _1.id == id }
    when "bulk-update-request"
      request = bulk_update_requests.find { _1.id == id }
    end

    body = case request
    when TagAlias, TagImplication
      if request.is_active?
        "#{request.relationship} ##{id} [[#{request.antecedent_name}]] -> [[#{request.consequent_name}]] has been approved."
      elsif request.is_retired?
        "#{request.relationship} ##{id} [[#{request.antecedent_name}]] -> [[#{request.consequent_name}]] has been retired."
      elsif request.is_deleted?
        "#{request.relationship} ##{id} [[#{request.antecedent_name}]] -> [[#{request.consequent_name}]] has been rejected."
      elsif request.is_pending?
        "#{request.relationship} ##{id} [[#{request.antecedent_name}]] -> [[#{request.consequent_name}]] is pending approval."
      else # should never happen
        "#{request.relationship} ##{id} [[#{request.antecedent_name}]] -> [[#{request.consequent_name}]] has an unknown status."
      end
    when BulkUpdateRequest
      bur = request

      if bur.script.size < 700
        embedded_script = bur.processor.to_dtext
      else
        embedded_script = "[expand]#{bur.processor.to_dtext}[/expand]"
      end

      case bur.status
      when "approved"
        "BUR ##{id} has been approved by <@#{bur.approver&.name}>.\n\n#{embedded_script}"
      when "pending"
        "BUR ##{id} is pending approval.\n\n#{embedded_script}"
      when "rejected"
        "BUR ##{id} has been rejected.\n\n#{embedded_script}"
      when "processing"
        "BUR ##{id} is being processed.\n\n#{embedded_script}"
      when "failed"
        "BUR ##{id} has failed.\n\n#{embedded_script}"
      else # should never happen
        "BUR ##{id} has an unknown status.\n\n#{embedded_script}"
      end
    when nil
      "#{type.tr("-", " ")} ##{id} does not exist."
    end

    html = DText.parse(body)
    node.replace(html)
  end

  # Insert the emoji value into an <emoji> node.
  def replace_emoji!(node)
    lowercase_name = node["data-name"]
    proper_name, value = emoji_map.find { |name, _| name.casecmp?(lowercase_name) }

    node["title"] = ":#{proper_name}:"
    node["data-mode"] = "inline" if inline
    node.inner_html = value
  end

  # Return the DText parsed to HTML. This is before the HTML is rewritten to colorize wiki links and replace
  # <media-embed> and <tag-request-embed> tags.
  #
  # @return [String] The HTML.
  memoize def to_html
    DText.parse(dtext, inline:, disable_mentions:, media_embeds:, base_url:, domain:, internal_domains: [domain, *alternate_domains].compact_blank, emoji_list:)
  end

  # Return the DText after parsing it to a Nokogiri HTML5 object.
  #
  # @return [Nokogiri::HTML5::DocumentFragment] The parsed HTML.
  memoize def parsed_html
    DText.parse_html(to_html)
  end

  # Return a list of user names mentioned in a string of DText. Ignore mentions in [quote] blocks.
  #
  # @return [Array<String>] The list of mentioned user names.
  memoize def mentions
    nodes = parsed_html.css("a.dtext-user-mention-link").select do |mention|
      mention.ancestors.none? { |ancestor| ancestor.name == "blockquote" }
    end

    nodes.pluck("data-user-name").map { |name| User.normalize_name(name) }.uniq
  end

  # Return a list of wiki pages mentioned in a string of DText.
  #
  # @param text [String] the string of DText
  # @return [Array<String>] the list of wiki page names
  memoize def wiki_titles
    DText.parse_html(format_text).css("a.dtext-wiki-link").pluck("href").map do |href|
      title = href[%r{(?:/wiki_pages/|/artists/show_or_new\?name=)(.*)\z}i, 1]
      title = CGI.unescape(title)
      title = WikiPage.normalize_title(title)
      title
    end.uniq
  end

  # @return [Array<Nokogiri::HTML5::Node>] The list of media embeds in this DText.
  memoize def embedded_media
    parsed_html.css("media-embed")
  end

  # @return [Array<Integer>] The list of post IDs used by media embeds in this DText.
  memoize def embedded_post_ids
    embedded_media.select { |node| node["data-type"] == "post" }.pluck("data-id").map(&:to_i).uniq
  end

  # @return [Array<Integer>] The list of media asset IDs used by media embeds in this DText.
  memoize def embedded_media_asset_ids
    embedded_media.select { |node| node["data-type"] == "asset" }.pluck("data-id").map(&:to_i).uniq
  end

  # @return [Array<Post>] The list of posts used by media embeds in this DText.
  memoize def embedded_posts
    Post.where(id: embedded_post_ids)
  end

  # @return [Array<MediaAsset>] The list of media assets used by media embeds in this DText.
  memoize def embedded_media_assets
    MediaAsset.where(id: embedded_media_asset_ids)
  end

  # @return [Array<String>] The list of emoji names used by this DText (normalized to lowercase).
  memoize def emoji_names
    parsed_html.css("emoji").pluck("data-name")
  end

  # @return [Array<String>] The list of block (large) emojis used by this DText.
  memoize def block_emoji_names
    parsed_html.css("emoji").select { |node| node["data-mode"] == "block" }.pluck("data-name")
  end

  # @return [Array<String>] The list of inline (small) emojis used by this DText.
  memoize def inline_emoji_names
    parsed_html.css("emoji").select { |node| node["data-mode"] == "inline" }.pluck("data-name")
  end

  # Return a hash of the wiki pages, posts, media assets, aliases, implications, and BURs referenced by a string of DText.
  #
  # @param text [String] the string of DText
  # @return [Hash<Symbol, Array<String>>] The set of items referenced in the DText.
  def self.parse_dtext_references(text)
    html = DText.parse(text)
    fragment = DText.parse_html(html)

    wiki_pages = fragment.css("a.dtext-wiki-link").map do |node|
      title = node["href"][%r{/wiki_pages/(.*)\z}i, 1]
      title = CGI.unescape(title)
      title = WikiPage.normalize_title(title)
      title
    end

    # <media-embed data-type="post data-id="1234"></media-embed>
    # <tag-request-embed data-type="bulk-update-request data-id="1234"></tag-request-embed>
    posts = fragment.css("media-embed").select { |node| node["data-type"] == "post" }.pluck("data-id").uniq
    media_assets = fragment.css("media-embed").select { |node| node["data-type"] == "asset" }.pluck("data-id").uniq
    tag_aliases = fragment.css("tag-request-embed").select { |node| node["data-type"] == "tag-alias" }.pluck("data-id").uniq
    tag_implications = fragment.css("tag-request-embed").select { |node| node["data-type"] == "tag-implication" }.pluck("data-id").uniq
    bulk_update_requests = fragment.css("tag-request-embed").select { |node| node["data-type"] == "bulk-update-request" }.pluck("data-id").uniq

    { wiki_pages:, posts:, media_assets:, tag_aliases:, tag_implications:, bulk_update_requests: }
  rescue DText::Error
    { wiki_pages: [], posts: [], media_assets: [], tag_aliases: [], tag_implications: [], bulk_update_requests: [] }
  end

  # Return a list of external links mentioned in a string of DText.
  #
  # @param text [String] the string of DText
  # @return [Array<String>] the list of external URLs
  memoize def external_links
    parsed_html.css("a.dtext-external-link").pluck("href").uniq
  end

  # Return whether the two pieces of DText have the same set of links and media embeds.
  #
  # @param other [DText] The other piece of DText.
  # @return [Boolean]
  def links_differ?(other)
    wiki_titles.to_set != other.wiki_titles.to_set ||
      external_links.to_set != other.external_links.to_set ||
      embedded_post_ids.to_set != other.embedded_post_ids.to_set ||
      embedded_media_asset_ids.to_set != other.embedded_media_asset_ids.to_set
  end

  # Rewrite wiki links to [[old_name]] with [[new_name]]. We attempt to match the capitalization of the old tag when
  # rewriting it to the new tag, but if we can't determine how the new tag should be capitalized based on some simple
  # heuristics, then we skip rewriting the tag.
  #
  # @param old_name [String] the old wiki name
  # @param new_name [String] the new wiki name
  # @return [DText] The DText with links rewritten.
  def rewrite_wiki_links(old_name, new_name)
    old_name = old_name.downcase.squeeze("_").tr("_", " ").strip
    new_name = new_name.downcase.squeeze("_").tr("_", " ").strip

    # Match `[[name]]` or `[[name|title]]`
    rewritten_dtext = dtext.gsub(/\[\[(.*?)(?:\|(.*?))?\]\]/) do |match|
      name = $1
      title = $2

      # Skip this link if it isn't the tag we're trying to replace.
      normalized_name = name.downcase.tr("_", " ").squeeze(" ").strip
      next match if normalized_name != old_name

      # Strip qualifiers, e.g. `atago (midsummer march) (azur lane)` => `atago`
      unqualified_name = name.tr("_", " ").squeeze(" ").strip.gsub(/( \(.*\))+\z/, "")

      # If old tag was lowercase, e.g. [[ink tank (Splatoon)]], then keep new tag in lowercase.
      if unqualified_name == unqualified_name.downcase
        final_name = new_name
      # If old tag was capitalized, e.g. [[Colored pencil (medium)]], then capitialize new tag.
      elsif unqualified_name == unqualified_name.downcase.capitalize
        final_name = new_name.capitalize
      # If old tag was in titlecase, e.g. [[Hatsune Miku (cosplay)]], then titlecase new tag.
      elsif unqualified_name == unqualified_name.split.map(&:capitalize).join(" ")
        final_name = new_name.split.map(&:capitalize).join(" ")
      # If we can't determine how to capitalize the new tag, then keep the old tag.
      # e.g. [[Suzumiya Haruhi no Yuuutsu]] -> [[The Melancholy of Haruhi Suzumiya]]
      else
        next match
      end

      if title.present?
        "[[#{final_name}|#{title}]]"
      # If the new name has a qualifier, then hide the qualifier in the link.
      elsif final_name.match?(/( \(.*\))+\z/)
        "[[#{final_name}|]]"
      else
        "[[#{final_name}]]"
      end
    end

    DText.new(rewritten_dtext)
  end

  # Wrap a DText message in a [quote] block.
  #
  # @param message [String] the DText to quote
  # @param creator_name [String] the name of the user to quote.
  # @return [String] the quoted DText
  def quote(creator_name)
    stripped_body = strip_blocks("quote")
    "[quote]\n#{creator_name} said:\n\n#{stripped_body}\n[/quote]\n\n"
  end

  # Remove all [<tag>] blocks from the DText.
  #
  # @param tag [String] the type of block to remove
  # @return [String] the DText output
  def strip_blocks(tag)
    n = 0
    stripped = "".dup
    string = dtext.to_s.dup

    string.gsub!(/\s*\[#{tag}\](?!\])\s*/mi, "\n\n[#{tag}]\n\n")
    string.gsub!(%r{\s*\[/#{tag}\]\s*}mi, "\n\n[/#{tag}]\n\n")
    string.gsub!(/(?:\r?\n){3,}/, "\n\n")
    string.strip!

    string.split(/\n{2}/).each do |block|
      case block
      when "[#{tag}]"
        n += 1

      when "[/#{tag}]"
        n -= 1

      else
        if n == 0
          stripped << "#{block}\n\n"
        end
      end
    end

    stripped.strip
  end

  # Remove all DText formatting from the string of DText, converting it to plain text.
  #
  # @return [String] the plain text output
  def strip_dtext
    html = DText.parse_html(format_text)
    DText.html_to_plaintext(html).strip
  end

  # Convert HTML to plaintext.
  #
  # @param html [Nokogiri::HTML5::DocumentFragment] the HTML input
  # @return [String] the plain text output
  def self.html_to_plaintext(html)
    html.children.map do |node|
      case node.name
      when "p", "h1", "h2", "h3", "h4", "h5", "h6"
        "#{html_to_plaintext(node)}\n\n"
      when "li"
        "* #{html_to_plaintext(node)}\n"
      when "br"
        "\n"
      when "blockquote"
        html_to_plaintext(node).strip.gsub(/^/, "> ")
      when "details"
        html_to_plaintext(node.css("div"))
      when "text"
        node.text
      else
        html_to_plaintext(node)
      end
    end.join
  end

  # Convert DText formatting to Markdown.
  #
  # @return [String] the Markdown output
  def to_markdown
    html = DText.parse_html(format_text)
    DText.html_to_markdown(html)
  end

  # Convert HTML to Markdown.
  #
  # @param html [Nokogiri::HTML5::DocumentFragment] the HTML input
  # @return [String] the Markdown output
  def self.html_to_markdown(html)
    html.children.map do |node|
      case node.name
      when "div", "blockquote", "table"
        "" # strip [expand], [quote], and [table] tags
      when "br"
        "\n"
      when "text"
        node.text.gsub(/_/, '\_').gsub(/\*/, '\*')
      when "p", "h1", "h2", "h3", "h4", "h5", "h6"
        html_to_markdown(node) + "\n\n"
      else
        html_to_markdown(node)
      end
    end.join
  end

  # Convert plain text to DText.
  #
  # @param text [String] The plain text input.
  # @param options [Hash] The options to pass to DText.escape.
  # @return [String] the DText output.
  def self.from_plaintext(text, **options)
    escape(text.to_s, **options).then { normalize_whitespace(_1) }
  end

  # Normalize the whitespace in a piece of DText, and remove any unnecessary whitespace.
  #
  # @param text [String] The DText input.
  # @return [String] The normalized DText output.
  def self.normalize_whitespace(text)
    text.to_s.normalize_whitespace(eol: "\n").gsub(/^ +| +$/, "").gsub(/\n{3,}/, "\n\n").squeeze(" ").strip
  end

  # Convert HTML to DText.
  #
  # @param html [Nokogiri::HTML5::DocumentFragment, String] The HTML input.
  # @param base_url [String] The base URL to use for relative URLs.
  # @param inline [Boolean] If true, convert <img> tags to plaintext.
  # @param allowed_shortlinks [Array<String>] The list of shortlinks to allow in the DText (e.g. ["pixiv"] to not escape `pixiv #1234` shortlinks).
  # @return [String] the DText output
  def self.from_html(html, base_url: nil, inline: false, allowed_shortlinks: [], &block)
    html = parse_html(html) if html.is_a?(String)
    dtext = html_to_dtext(html, base_url:, inline:, allowed_shortlinks:, &block)
    dtext.gsub(/^ +| +$/, "").gsub(/\n{3,}/, "\n\n").strip
  end

  def self.html_to_dtext(html, base_url: nil, inline: false, allowed_shortlinks: [], &block)
    return "" if html.nil?

    options = { base_url:, inline:, allowed_shortlinks: }

    # Allow caller to rewrite elements before processing them.
    html.children.each { |element| block.call(element) } if block.present?

    children = []
    html.children.each do |current|
      # Normalize equivalent elements
      current.name = "b" if current.name == "strong"
      current.name = "i" if current.name == "em"
      current.name = "s" if current.name == "strike"
      current.name = "small" if current.name == "sub"

      # Merge adjacent elements of the same type: <b>foo</b><b>bar</b> -> <b>foobar</b>
      if current.name.in?(%w[b i u s small]) && children.last&.name == current.name
        children.last.add_child(current.children)
      else
        children << current
      end
    end

    children.map do |element|
      case element.name
      in "text"
        escape(element.content, allowed_shortlinks:).normalize_whitespace(eol: "\n").gsub(/ *\n+ */, "\n").gsub(/[ \n]+/, " ")
      in "br" if element.ancestors.any? { |e| e.name.in?(%w[a h1 h2 h3 h4 h5 h6]) }
        " "
      in "br" if element.ancestors.any? { |e| e.name == "li" } && element.next.present?
        "[br]"
      in "br"
        "\n"
      in "hr"
        "\n\n[hr]\n\n"
      in ("p" | "ul" | "ol")
        content = html_to_dtext(element, **options, &block).strip
        "\n\n#{content}\n\n"
      in "blockquote"
        content = html_to_dtext(element, **options, &block).strip
        "\n\n[quote]\n#{content}\n[/quote]\n\n" if content.present?
      in "pre"
        content = html_to_dtext(element, **options, &block)
        "\n\n[code]\n#{content}\n[/code]\n\n" if content.present?
      in "block-spoiler" # fake tag added by source extractors
        content = html_to_dtext(element, **options, &block).strip
        "\n\n[spoiler]\n#{content}\n[/spoiler]\n\n" if content.present?
      in "inline-spoiler" # fake tag added by source extractors
        content = html_to_dtext(element, **options, &block).strip
        "[spoiler]#{content}[/spoiler]" if content.present?
      in "small" unless element.ancestors.any? { |e| e.name == "small" }
        content = html_to_dtext(element, **options, &block)
        "[tn]#{content}[/tn]" if content.present?
      in "b" unless element.ancestors.any? { |e| e.name == "b" }
        content = html_to_dtext(element, **options, &block)
        "[b]#{content}[/b]" if content.present?
      in "i" unless element.ancestors.any? { |e| e.name == "i" }
        content = html_to_dtext(element, **options, &block)
        "[i]#{content}[/i]" if content.present?
      in "u" unless element.ancestors.any? { |e| e.name == "u" }
        content = html_to_dtext(element, **options, &block)
        "[u]#{content}[/u]" if content.present?
      in "s" unless element.ancestors.any? { |e| e.name == "s" }
        content = html_to_dtext(element, **options, &block)
        "[s]#{content}[/s]" if content.present?
      in "code" unless element.ancestors.any? { |e| e.name == "code" }
        content = html_to_dtext(element, **options, &block)
        "[code]#{content}[/code]" if content.present?
      in "li"
        content = html_to_dtext(element, **options, &block).gsub(/\n+/, "\n").strip
        depth = element.ancestors.count { _1.name in "ul" | "ol" }.clamp(1..)
        list = "*" * depth
        "#{list} #{content}\n" if content.present?
      in ("h1" | "h2" | "h3" | "h4" | "h5" | "h6")
        hn = element.name
        title = html_to_dtext(element, **options, &block).strip
        "\n\n#{hn}. #{title}\n\n" if title.present?
      in "a"
        title = html_to_dtext(element, **options, inline: true, &block).squeeze(" ")
        url = element["href"].to_s

        if title.blank?
          ""
        elsif !url.match?(%r{\A(https?://|mailto:|//|/)}i)
          title
        elsif url.starts_with?("mailto:") && url.delete_prefix("mailto:") == title
          "<#{url}>"
        elsif url.starts_with?("//") && title == url # protocol-relative url
          "<https:#{url}>"
        elsif url.starts_with?("//") && title != url # protocol-relative url
          %{"#{title.gsub('"', "&quot;")}":[https:#{url}]}
        elsif url.starts_with?("/") && base_url.present? && title == url
          "<#{File.join(base_url, url)}>"
        elsif url.starts_with?("/") && base_url.present? && title != url
          %{"#{title.gsub('"', "&quot;")}":[#{File.join(base_url, url)}]}
        elsif url.starts_with?("/")
          title
        elsif title == url
          "<#{url}>"
        else
          %{"#{title.gsub('"', "&quot;")}":[#{url}]}
        end
      in "img"
        alt_text = element["title"] || element["alt"] || ""
        src = element["src"]

        if inline
          escape(alt_text, allowed_shortlinks:)
        elsif alt_text.present? && src.present?
          %{"#{alt_text.gsub('"', "&quot;")}":[#{src}]\n\n}
        else
          ""
        end
      in "details"
        title = element.at("summary")&.text.to_s.strip.tr("\n", " ").delete("]")
        content = html_to_dtext(element, **options, &block).strip

        if title.present? && content.present?
          "[expand=#{title}]\n#{content}\n[/expand]\n\n"
        elsif content.present?
          "[expand]\n#{content}\n[/expand]\n\n"
        end
      in "comment" | "script" | "summary"
        element.content = nil
      else
        html_to_dtext(element, **options, &block)
      end
    end.join
  end

  # Escape a piece of plain text so that special characters aren't interpreted as DText.
  #
  # @param allowed_shortlinks [Array<String>] The list of shortlinks to allow in the text (e.g. ["pixiv"] to not escape `pixiv #1234` shortlinks).
  def self.escape(text, allowed_shortlinks: [])
    text.gsub(/(#{Regexp.union(SHORTLINKS - allowed_shortlinks)}) #(\d+)/i, '\1 &num;\2') # post #1234 -> post &num;1234
  end

  # Return the first paragraph the search string `needle` occurs in.
  #
  # @param needle [String] the string to search for
  # @return [String] the first paragraph mentioning the search string
  def extract_mention(needle)
    ActionController::Base.helpers.excerpt(dtext.gsub(/\r\n|\r|\n/, "\n"), needle, separator: "\n\n", radius: 1, omission: "")
  end

  # Generate a short plain text excerpt from a DText string.
  #
  # @param length [Integer] the max length of the output
  # @return [String] a plain text string
  def excerpt(length: 160)
    strip_dtext.split(/\r\n|\r|\n/).first.to_s.truncate(length)
  end

  # Parse a string of HTML to a document object.
  # @param html [String]
  # @return [Nokogiri::HTML5::DocumentFragment]
  def self.parse_html(html)
    Nokogiri::HTML5.fragment(html, max_tree_depth: -1)
  end

  def to_s
    dtext
  end
end
