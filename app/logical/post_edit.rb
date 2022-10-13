# frozen_string_literal: true

# A PostEdit represents a tag edit being performed on a post. It contains most
# of the logic for performing a tag edit, including methods for parsing the tag
# string into tags and metatags, methods for determining which tags were added
# or removed by the edit, and methods for calculating the final list of tags.
class PostEdit
  extend Memoist

  Tag = Struct.new(:name, :negated, keyword_init: true)
  Metatag = Struct.new(:name, :value, keyword_init: true)

  # Metatags that change the tag's category: `art:bkub`, `char:chen`, `copy:touhou`, `gen:1girl`, `meta:animated`.
  CATEGORIZATION_METATAGS = TagCategory.mapping.keys

  # Pre-metatags affect the post itself, so they must be applied before the post is saved.
  PRE_METATAGS = %w[parent -parent rating source] + CATEGORIZATION_METATAGS

  # Post-metatags rely on the post's ID, so they must be applied after the post is saved to ensure the ID has been created.
  POST_METATAGS = %w[newpool pool -pool favgroup -favgroup fav -fav child -child upvote downvote disapproved status -status]

  METATAGS = PRE_METATAGS + POST_METATAGS
  METATAG_NAME_REGEX = /(#{METATAGS.join("|")}):/io

  private attr_reader :post, :current_tag_names, :old_tag_names, :new_tag_string, :parser
  private delegate :accept, :expect, :error, :skip, :zero_or_more, :one_of, to: :parser

  # @param post [Post] The post being edited.
  # @param current_tag_string [String] The space-separated list of tags currently on the post.
  # @param old_tag_string [String] The space-separated list of tags the user saw before the edit.
  # @param new_tag_string [String] The space-separated list of tags after the edit.
  def initialize(post, current_tag_string, old_tag_string, new_tag_string)
    @post = post
    @current_tag_names = current_tag_string.to_s.split
    @old_tag_names = old_tag_string.to_s.split
    @new_tag_string = new_tag_string.to_s.gsub(/[[:space:]]/, " ")
    @parser = StringParser.new(@new_tag_string)
  end

  concerning :HelperMethods do
    # @return [Array<String>] The final list of tags on the post after the edit.
    def tag_names
      tag_names = current_tag_names + effective_added_tag_names - user_removed_tag_names
      tag_names = post.add_automatic_tags(tag_names)
      tag_names += ::Tag.automatic_tags_for(tag_names)
      tag_names += TagImplication.tags_implied_by(tag_names).map(&:name)
      tag_names.uniq.sort
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
  end

  concerning :ParserMethods do
    # @return [Array<Tag, Metatag>] The list of tags and metatags in the edit.
    def terms
      zero_or_more { skip(/[[:space:]]+/); term }
    end

    private def term
      one_of([method(:tag), method(:metatag)])
    end

    private def tag
      negated = accept("-").present?
      error("Invalid tag name") if accept(METATAG_NAME_REGEX)
      name = expect(/[^[:space:]]+/)

      Tag.new(name: name.downcase, negated: negated)
    end

    private def metatag
      name = expect(METATAG_NAME_REGEX)
      value = quoted_string

      name = name.delete_suffix(":").downcase
      name = TagCategory.short_name_mapping.fetch(name, name) # 'art:bkub' => 'artist:bkub'
      value = value.downcase unless name.in?(["newpool", "source"])
      value = value.gsub(/[[:space:]]/, "_") unless name == "source"

      Metatag.new(name: name, value: value)
    end

    private def quoted_string
      if accept('"')
        string = expect(/(\\"|[^"])*/).gsub(/\\"/, '"') # handle backslash escaped quotes
        expect('"')
        string
      elsif accept("'")
        string = expect(/(\\'|[^'])*/).gsub(/\\'/, "'") # handle backslash escaped quotes
        expect("'")
        string
      else
        expect(/(\\ |[^ ])*/).gsub(/\\ /, " ") # handle backslash escaped spaces
      end
    end
  end

  memoize :tag_names, :new_tag_names, :user_added_tag_names, :user_removed_tag_names, :invalid_added_tags, :deprecated_added_tag_names, :terms, :tag_terms, :metatag_terms
end
