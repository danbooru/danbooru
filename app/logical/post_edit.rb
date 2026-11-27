# frozen_string_literal: true

# A PostEdit represents a tag edit being performed on a post. It contains most
# of the logic for performing a tag edit, including methods for parsing the tag
# string into tags and metatags, methods for determining which tags were added
# or removed by the edit, and methods for calculating the final list of tags.
class PostEdit
  extend Memoist

  Tag = Struct.new(:name, :negated, keyword_init: true)
  Metatag = Struct.new(:name, :value, keyword_init: true) do
    def category
      TagCategory.mapping[name]
    end

    def to_s
      "#{name}:#{value}"
    end
  end

  # Metatags that change the tag's category: `art:bkub`, `char:chen`, `copy:touhou`, `gen:1girl`, `meta:animated`.
  CATEGORIZATION_METATAGS = TagCategory.mapping.keys

  # Pre-metatags affect the post itself, so they must be applied before the post is saved.
  PRE_METATAGS = %w[parent -parent rating source status] + CATEGORIZATION_METATAGS

  # Post-metatags rely on the post's ID, so they must be applied after the post is saved to ensure the ID has been created.
  POST_METATAGS = %w[newpool newfavgroup pool -pool favgroup -favgroup fav -fav child -child upvote downvote -upvote -downvote disapproved status -status]

  METATAGS = PRE_METATAGS + POST_METATAGS

  # Matches a metatag name, like `rating:` or `-pool:`, with an optional leading '-'. Don't use /i, because that matches Unicode characters.
  METATAG_NAME_REGEX = /-?[a-zA-Z0-9_]+:/

  private attr_reader :post, :current_tag_names, :old_tag_names, :new_tag_string, :user, :parser
  private delegate :accept, :expect, :error, :skip, :zero_or_more, :one_of, to: :parser

  # Parse a tag edit string without a Post (e.g. for bulk update requests).
  #
  # @param tag_string [String] The tag edit string to parse.
  # @return [PostEdit]
  def self.parse(tag_string)
    new(nil, new_tag_string: tag_string)
  end

  # @param post [Post, nil] The post being edited.
  # @param user [User, nil] The user performing the edit (required when `post` is present).
  # @param new_tag_string [String, nil] Override for the edited tag string (used by {.parse}).
  def initialize(post, user: nil, new_tag_string: post&.tag_string)
    raise ArgumentError, "user is required" if post.present? && user.nil?

    @post = post
    @user = user
    @current_tag_names = post&.tag_string_was.to_s.split
    @old_tag_names = (post&.old_tag_string || post&.tag_string_was).to_s.split
    @new_tag_string = new_tag_string.to_s.gsub(/[[:space:]]/, " ")
    @parser = StringParser.new(@new_tag_string)
  end

  concerning :EditMethods do
    def apply_pre_metatags
      pre_metatag_terms.each do |metatag|
        case [metatag.name, metatag.value]
        in "parent", ("none" | "0")
          post.parent_id = nil

        in "-parent", /^\d+$/ => new_parent_id
          if post.parent_id == new_parent_id.to_i
            post.parent_id = nil
          end

        in "parent", new_parent_id
          post.parent_id = new_parent_id

        in "rating", /\A([#{Post::RATINGS.keys.join}])/o
          post.rating = $1

        in "source", "none"
          post.source = ""

        in "source", value
          post.source = value

        in "status", "pending"
          post.is_pending = true if post.new_record?

        in category, name if category.in?(CATEGORIZATION_METATAGS)
          ::Tag.find_or_create_by_name(name, category: category, current_user: user)

        else
          nil

        end
      end

      post.parent.updater = user if post.parent&.changed?
    end

    def apply_post_metatags
      post_metatag_terms.each do |metatag|
        case [metatag.name, metatag.value]
        in "-pool", /^\d+$/ => pool_id
          pool = Pool.find_by_id(pool_id)
          pool&.remove!(post)

        in "-pool", name
          pool = Pool.find_by_name(name)
          pool&.remove!(post)

        in "pool", /^\d+$/ => pool_id
          pool = Pool.find_by_id(pool_id)
          pool&.add!(post)

        in "pool", "none"
          post.remove_from_all_pools

        in "pool", name
          pool = Pool.find_by_name(name)
          pool&.add!(post)

        in "newpool", name
          pool = Pool.find_by_name(name)

          # XXX race condition
          if pool.nil?
            Pool.create!(name: name, description: "This pool was automatically generated", post_ids: [post.id])
          else
            pool.add!(post)
          end

        in "newfavgroup", name
          favgroup = FavoriteGroup.find_by_name_or_id(name, user)

          # XXX race condition
          if favgroup.nil?
            raise User::PrivilegeError unless Pundit.policy!(user, FavoriteGroup).create?
            FavoriteGroup.create!(name: name, creator: user, post_ids: [post.id])
          else
            raise User::PrivilegeError unless Pundit.policy!(user, favgroup).update?
            favgroup.add(post)
          end

        in "fav", name
          raise User::PrivilegeError unless Pundit.policy!(user, Favorite).create?
          Favorite.create(post: post, user: user)

        in "-fav", name
          raise User::PrivilegeError unless Pundit.policy!(user, Favorite).create?
          Favorite.destroy_by(post: post, user: user)

        in "upvote", name
          post.vote!(1, user)

        in "downvote", name
          post.vote!(-1, user)

        in "-upvote", name
          post.unvote!(1, user)

        in "-downvote", name
          post.unvote!(-1, user)

        in "status", "active"
          raise User::PrivilegeError unless user.is_approver?
          post.approvals.create!(user: user)

        in "status", "banned"
          raise User::PrivilegeError unless user.is_approver?
          post.ban!(user)

        in "-status", "banned"
          raise User::PrivilegeError unless user.is_approver?
          post.unban!(user)

        in "disapproved", reason
          raise User::PrivilegeError unless user.is_approver?
          post.disapprovals.find_or_initialize_by(user: user).update!(reason: reason.downcase)

        in "child", "none"
          post.children.select { |child| Pundit.policy!(user, child).update? }.each do |child|
            child.update!(parent_id: nil, updater: user)
          end

        in "-child", ids
          next if ids.blank?

          post.children.where_numeric_matches(:id, ids).select { |child| Pundit.policy!(user, child).update? }.each do |child|
            child.update!(parent_id: nil, updater: user)
          end

        in "child", ids
          next if ids.blank?

          Post.where_numeric_matches(:id, ids).where.not(id: [post.id, post.parent_id].compact).limit(10).select { |child| Pundit.policy!(user, child).update? }.each do |child|
            child.update!(parent_id: post.id, updater: user)
          end

        in "-favgroup", name
          favgroup = FavoriteGroup.find_by_name_or_id!(name, user)
          raise User::PrivilegeError unless Pundit.policy!(user, favgroup).update?
          favgroup&.remove(post)

        in "favgroup", name
          favgroup = FavoriteGroup.find_by_name_or_id!(name, user)
          raise User::PrivilegeError unless Pundit.policy!(user, favgroup).update?
          favgroup&.add(post)

        end
      end
    rescue StandardError
      # XXX Silently ignore errors so that the edit doesn't fail. We can't let
      # the edit fail because then it will create a new post version even if
      # the edit didn't go through.
      nil
    end
  end

  concerning :HelperMethods do
    # @return [Array<String>] The final list of tags on the post after the edit.
    def tag_names
      tag_names = current_tag_names + effective_added_tag_names - user_removed_tag_names
      tag_names = add_automatic_tags(tag_names)
      tag_names += ::Tag.automatic_tags_for(tag_names)
      tag_names += TagImplication.tags_implied_by(tag_names).map(&:name)
      tag_names.uniq.sort
    end

    # @param tags [Array<String>] The list of tags to add automatic tags to.
    # @return [Array<String>] The list of tags with automatic tags added or removed.
    def add_automatic_tags(tags)
      tags -= %w[incredibly_absurdres absurdres highres lowres flash video ugoira animated_gif animated_png animated_webp exif_rotation non-repeating_animation non-web_source wide_image tall_image]

      if tags.size >= 30
        tags -= ["tagme"]
      elsif tags.empty?
        tags << "tagme"
      end

      tags = add_automatic_file_tags(tags)
      tags = add_automatic_source_tags(tags)
      tags
    end

    # @param tags [Array<String>] The list of tags to add automatic file tags to.
    # @return [Array<String>] The list of tags with automatic file tags added or removed.
    def add_automatic_file_tags(tags)
      if post.image_width >= 10_000 || post.image_height >= 10_000
        tags << "incredibly_absurdres"
      end
      if post.image_width >= 3200 || post.image_height >= 2400
        tags << "absurdres"
      end
      if post.image_width >= 1600 || post.image_height >= 1200
        tags << "highres"
      end
      if post.image_width <= 500 && post.image_height <= 500
        tags << "lowres"
      end

      if post.image_width >= 1024 && post.image_width.to_f / post.image_height >= 4
        tags << "wide_image"
      elsif post.image_height >= 1024 && post.image_height.to_f / post.image_width >= 4
        tags << "tall_image"
      end

      if post.is_flash?
        tags << "flash"
      end

      if post.is_video?
        tags << "video"
      end

      if post.is_ugoira?
        tags << "ugoira"
      end

      # Allow only Flash files to be manually tagged as `animated`; GIFs, PNGs, WebPs, videos, and ugoiras are automatically tagged.
      tags -= ["animated"] unless post.is_flash?
      tags << "animated" if post.media_asset.is_animated?
      tags << "animated_gif" if post.media_asset.is_animated_gif?
      tags << "animated_png" if post.media_asset.is_animated_png?
      tags << "animated_webp" if post.media_asset.is_animated_webp?

      tags << "greyscale" if post.media_asset.is_greyscale?
      tags << "exif_rotation" if post.media_asset.is_rotated?
      tags << "non-repeating_animation" if post.media_asset.is_non_repeating_animation?
      tags << "ai-generated" if post.media_asset.is_ai_generated?

      # Allow Flash files to be manually tagged as `sound`; other files are automatically tagged.
      tags -= ["sound"] unless post.is_flash?
      tags << "sound" if post.media_asset.has_sound?

      tags
    end

    # @param tags [Array<String>] The list of tags to add automatic source tags to.
    # @return [Array<String>] The list of tags with automatic source tags added or removed.
    def add_automatic_source_tags(tags)
      if post.source.present? && !post.web_source?
        tags << "non-web_source"
      end

      # A bad_link is an image URL from a recognized site that can't be converted to a page URL.
      case post.parsed_source&.bad_link?
      when true
        tags << "bad_link"
      when false
        tags -= ["bad_link"]
      when nil
        # it's unknown whether it's a bad link or not; don't add or remove the tag
      end

      # A bad_source is a source from a recognized site that isn't an image url or a page url.
      case post.parsed_source&.bad_source?
      when true
        tags << "bad_source"
      when false
        tags -= ["bad_source"]
      when nil
        # it's unknown whether it's a bad source or not; don't add or remove the tag
      end

      tags
    end

    # @return [Array<String>] The list of tags in the edited tag string, including regular tags and tags with a category prefix (e.g. `artist:bkub`)
    def new_tag_names
      tag_terms.reject(&:negated).map(&:name) + tag_categorization_terms.map(&:value)
    end

    # @return [Array<Tag>] The list of tags in the edited tag string. Includes negated and non-negated tags, but not tags with a category prefix.
    def tag_terms
      terms.grep(Tag)
    end

    # @return [Array<Metatag>] The list of metatags in the edited tag string.
    def metatag_terms
      terms.grep(Metatag)
    end

    # @return [Array<Metatag>] The list of pre-save metatags in the edit (metatags that are applied before the post is saved).
    def pre_metatag_terms
      metatag_terms.select { |term| term.name.in?(PRE_METATAGS) }
    end

    # @return [Array<Metatag>] The list of post-save metatags in the edit (metatags that are applied after the post is saved).
    def post_metatag_terms
      metatag_terms.select { |term| term.name.in?(POST_METATAGS) }
    end

    # @return [Array<Metatag>] The list of tags with a category prefix (e.g. `artist:bkub`).
    def tag_categorization_terms
      metatag_terms.select { |term| term.name.in?(TagCategory.categories) }
    end

    # @return [Metatag, nil] The single tag categorization term (e.g. `artist:bkub`) if the edit consists solely of one with a non-empty tag name.
    def single_categorization_term
      term = tag_categorization_terms.first
      term if terms.one? && term&.value.present?
    end

    # @return [Array<String>] The list of tags actually added by the user, excluding invalid or deprecated tags.
    def effective_added_tag_names
      user_added_tag_names - invalid_added_tags.map(&:name) - deprecated_added_tag_names
    end

    # @return [Array<String>] The list of tags the user is trying to add. Includes tags that won't
    #   actually be added, such as invalid or deprecated tags. Does not include tags not explicitly
    #   added by the user, such as implied or automatic tags.
    def user_added_tag_names
      TagAlias.to_aliased(new_tag_names - old_tag_names - user_removed_tag_names).uniq.sort
    end

    # @return [Array<String>] The list of tags the user is trying to remove. Includes tags that
    #   won't actually be removed, such as implied tags, automatic tags, and nonexistent tags.
    def user_removed_tag_names
      (explicit_removed_tag_names + implicit_removed_tag_names).uniq.sort
    end

    # @return [Array<String>] The list of tags explicitly removed using the '-' operator (e.g. `-tagme`).
    def explicit_removed_tag_names
      TagAlias.to_aliased(tag_terms.select(&:negated).map(&:name))
    end

    # @return [Array<String>] The list of tags implicitly removed by being deleted from the tag string (e.g. `1girl tagme` => `1girl`)
    def implicit_removed_tag_names
      old_tag_names - new_tag_names
    end

    # @return [Array<Tag>] The list of user-added tags that have invalid names.
    def invalid_added_tags
      user_added_tag_names.map { |name| ::Tag.new(name: name) }.select { |tag| tag.invalid?(:name) }
    end

    # @return [Array<String>] The list of user-added tags that are deprecated.
    def deprecated_added_tag_names
      ::Tag.deprecated.where(name: user_added_tag_names).map(&:name)
    end

    # @return [Array<String>] Metatags in the edit that aren't valid edit metatags (e.g. `score:5`, `-rating:s`, `-newpool:foo`).
    def invalid_metatags
      tag_terms.filter_map do |tag|
        prefix, colon, value = tag.name.partition(":")
        next unless colon.present? && (prefix.in?(METATAGS) || prefix.in?(PostQueryBuilder::METATAGS))

        name = tag.negated ? "-#{prefix}" : prefix
        name unless name.in?(METATAGS) && value.start_with?('"', "'")
      end.uniq
    end

    # @return [Array<String>] Valid edit metatags in the edit that failed to parse because of an unclosed quote (e.g. `pool:"foo`).
    def unclosed_metatags
      tag_terms.filter_map do |tag|
        prefix, colon, value = tag.name.partition(":")
        next unless colon.present? && value.start_with?('"', "'")

        name = tag.negated ? "-#{prefix}" : prefix
        name if name.in?(METATAGS)
      end.uniq
    end
  end

  concerning :ParserMethods do
    # @return [Array<Tag, Metatag>] The list of tags and metatags in the edit.
    def terms
      zero_or_more { skip(/[[:space:]]+/); term }
    end

    private def term
      one_of([method(:metatag), method(:tag)])
    end

    # Matches anything that isn't a valid metatag, so that a bad term never stops the rest of the tags from being parsed.
    private def tag
      negated = accept(/-(?=[^[:space:]])/).present? # Extract a leading `-` if followed by non-spaces
      name = expect(/[^[:space:]]+/)
      category, rest = name.split(":", 2)
      name = rest if negated && rest.present? && category.downcase(:ascii).in?(CATEGORIZATION_METATAGS) # `-char:chen` is the same as `-chen`

      Tag.new(name: name.downcase, negated: negated)
    end

    private def metatag
      name = expect(METATAG_NAME_REGEX).delete_suffix(":").downcase
      error { "Unknown metatag: #{name}" } unless name.in?(METATAGS)
      value = quoted_string

      name = TagCategory.reverse_mapping.fetch(TagCategory.mapping[name], name) # 'art:bkub' => 'artist:bkub'
      value = value.downcase unless name.in?(["newpool", "newfavgroup", "source"])
      value = value.gsub(/[[:space:]]/, "_") unless name == "source"

      Metatag.new(name: name, value: value)
    end

    private def quoted_string
      if accept('"')
        string = expect(/([^"\\]|\\.)*/).gsub(/\\(["\\])/, '\1') # handle backslash escaped quotes and backslashes
        expect('"')
        string
      elsif accept("'")
        string = expect(/([^'\\]|\\.)*/).gsub(/\\(['\\])/, '\1') # handle backslash escaped quotes and backslashes
        expect("'")
        string
      else
        expect(/(\\[[:space:]]|[^[:space:]])*/).gsub(/\\[[:space:]]/, " ") # handle backslash escaped spaces
      end
    end
  end

  memoize :tag_names, :new_tag_names, :user_added_tag_names, :user_removed_tag_names, :invalid_added_tags, :deprecated_added_tag_names, :invalid_metatags, :unclosed_metatags, :terms, :tag_terms, :metatag_terms
end
