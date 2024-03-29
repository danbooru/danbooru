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

  attr_reader :dtext, :inline, :disable_mentions, :media_embeds, :base_url, :domain, :alternate_domains, :options

  # Preprocess a set of DText messages and collect all tag, artist, wiki page, post, and media asset references. Called
  # before rendering a collection of DText messages (e.g. comments or forum posts) to do all database lookups in one batch.
  #
  # @param [Array<String>] a list of DText strings
  # @return [Hash<Symbol, ActiveRecord::Relation>] The set of wiki pages, tags, artists, posts, and media assets.
  def self.preprocess(dtext_messages)
    references = dtext_messages.map { |message| parse_dtext_references(message) }
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
  def initialize(dtext, inline: false, disable_mentions: false, media_embeds: false, base_url: nil, domain: Danbooru::URL.parse!(Danbooru.config.canonical_url).host, alternate_domains: Danbooru.config.alternate_domains)
    @dtext = dtext
    @inline = inline
    @disable_mentions = disable_mentions
    @media_embeds = media_embeds
    @base_url = base_url
    @domain = domain
    @alternate_domains = alternate_domains
    @options = { inline:, disable_mentions:, media_embeds:, base_url:, domain:, alternate_domains: }
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

  # Return the DText parsed to HTML. This is before the HTML is rewritten to colorize wiki links and replace
  # <media-embed> and <tag-request-embed> tags.
  #
  # @return [String] The HTML.
  memoize def to_html
    DText.parse(dtext, inline: inline, disable_mentions: disable_mentions, media_embeds: media_embeds, base_url: base_url, domain: domain, internal_domains: [domain, *alternate_domains].compact_blank)
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

  # @return [Array<Integer>] The list of post IDs used by media embeds in this DText.
  memoize def embedded_post_ids
    parsed_html.css("media-embed").select { |node| node["data-type"] == "post" }.pluck("data-id").map(&:to_i).uniq
  end

  # @return [Array<Integer>] The list of media asset IDs used by media embeds in this DText.
  memoize def embedded_media_asset_ids
    parsed_html.css("media-embed").select { |node| node["data-type"] == "asset" }.pluck("data-id").map(&:to_i).uniq
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
    html = DText.parse(dtext)
    DText.to_plaintext(html)
  end

  # Remove all formatting from a string of HTML, converting it to plain text.
  #
  # @param html [String] the HTML input
  # @return [String] the plain text output
  def self.to_plaintext(html)
    text = from_html(html) do |node|
      case node.name
      when "a", "strong", "em", "u", "s", "h1", "h2", "h3", "h4", "h5", "h6"
        node.name = "span"
        node.content = node.text
      when "blockquote"
        node.name = "span"
        node.content = to_plaintext(node.inner_html).gsub(/^/, "> ")
      when "details"
        node.name = "span"
        node.content = to_plaintext(node.css("div").inner_html)
      end
    end

    text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
  end

  # Convert DText formatting to Markdown.
  #
  # @return [String] the Markdown output
  def to_markdown
    html_to_markdown(format_text)
  end

  # Convert HTML to Markdown.
  #
  # @param html [String] the HTML input
  # @return [String] the Markdown output
  def html_to_markdown(string)
    html = DText.parse_html(string)

    html.children.map do |node|
      case node.name
      when "a"
        if node.attributes["href"].present?
          href = node.attributes["href"].value
          if href.starts_with?("/")
            href = "#{Danbooru.config.canonical_url}#{href}"
          end
          %Q<[#{node.text}](#{href})>
        else
          node.text
        end
      when "blockquote"
        node.children.map do |child|
          "> " + html_to_markdown(child)
        end.join.strip.gsub("\n\n", "\n> \n") + "\n\n"
      when "div", "table"
        "" # strip [expand] and [table] tags
      when "br"
        "\n"
      when "text"
        node.text.gsub(/_/, '\_').gsub(/\*/, '\*')
      when "p", "h1", "h2", "h3", "h4", "h5", "h6"
        html_to_markdown(node.inner_html) + "\n\n"
      else
        html_to_markdown(node.inner_html)
      end
    end.join
  end

  # Convert HTML to DText.
  # @param html [String] the HTML input
  # @param inline [Boolean] if true, convert <img> tags to plaintext
  # @return [String] the DText output
  def self.from_html(text, inline: false, &block)
    html = DText.parse_html(text)

    dtext = html.children.map do |element|
      block.call(element) if block.present?

      case element.name
      when "text"
        element.content.gsub(/(?:\r|\n)+$/, "")
      when "br"
        "\n"
      when "p", "ul", "ol"
        from_html(element.inner_html, &block).strip + "\n\n"
      when "blockquote"
        "[quote]#{from_html(element.inner_html, &block).strip}[/quote]\n\n" if element.inner_html.present?
      when "small", "sub"
        "[tn]#{from_html(element.inner_html, &block)}[/tn]" if element.inner_html.present?
      when "b", "strong"
        "[b]#{from_html(element.inner_html, &block)}[/b]" if element.inner_html.present?
      when "i", "em"
        "[i]#{from_html(element.inner_html, &block)}[/i]" if element.inner_html.present?
      when "u"
        "[u]#{from_html(element.inner_html, &block)}[/u]" if element.inner_html.present?
      when "s", "strike"
        "[s]#{from_html(element.inner_html, &block)}[/s]" if element.inner_html.present?
      when "li"
        "* #{from_html(element.inner_html, &block)}\n" if element.inner_html.present?
      when "h1", "h2", "h3", "h4", "h5", "h6"
        hN = element.name
        title = from_html(element.inner_html, &block)
        "#{hN}. #{title}\n\n"
      when "a"
        title = from_html(element.inner_html, inline: true, &block).strip
        url = element["href"]

        if title.blank? || url.blank?
          ""
        elsif title == url
          "<#{url}>"
        else
          %("#{title}":[#{url}])
        end
      when "img"
        alt_text = element.attributes["title"] || element.attributes["alt"] || ""
        src = element["src"]

        if inline
          alt_text
        elsif alt_text.present? && src.present?
          %("#{alt_text}":[#{src}]\n\n)
        else
          ""
        end
      when "comment"
        # ignored
      else
        from_html(element.inner_html, &block)
      end
    end.join

    dtext
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
