# frozen_string_literal: true

class Tag < ApplicationRecord
  ABBREVIATION_REGEXP = /([a-z0-9])[a-z0-9']*($|[^a-z0-9']+)/

  # Tags that are permitted to have unbalanced parentheses, as a special exception to the normal rule that parentheses in tags must balanced.
  PERMITTED_UNBALANCED_TAGS = %w[:) :( ;) ;( >:) >:(]

  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :artist, :foreign_key => "name", :primary_key => "name"
  has_one :antecedent_alias, -> {active}, :class_name => "TagAlias", :foreign_key => "antecedent_name", :primary_key => "name"
  has_one :aliased_tag, through: :antecedent_alias, source: :consequent_tag
  has_many :consequent_aliases, -> {active}, :class_name => "TagAlias", :foreign_key => "consequent_name", :primary_key => "name"
  has_many :antecedent_implications, -> {active}, :class_name => "TagImplication", :foreign_key => "antecedent_name", :primary_key => "name"
  has_many :consequent_implications, -> {active}, :class_name => "TagImplication", :foreign_key => "consequent_name", :primary_key => "name"
  has_many :dtext_links, foreign_key: :link_target, primary_key: :name
  has_many :ai_tags

  validates :name, tag_name: true, uniqueness: true, on: :create
  validates :name, tag_name: true, on: :name
  validates :category, inclusion: { in: TagCategory.category_ids }

  before_create :create_character_tag_for_cosplay_tag, if: :is_cosplay_tag?
  before_save :create_mod_action
  after_save :update_category_cache, if: :saved_change_to_category?
  after_save :update_category_post_counts, if: :saved_change_to_category?

  scope :empty, -> { where("tags.post_count <= 0") }
  scope :nonempty, -> { where("tags.post_count > 0") }
  scope :deprecated, -> { where(is_deprecated: true) }
  scope :undeprecated, -> { where(is_deprecated: false) }

  module ApiMethods
    def to_legacy_json
      {
        name: name,
        id: id,
        created_at: created_at.try(:strftime, "%Y-%m-%d %H:%M"),
        count: post_count,
        type: category,
        ambiguous: false,
      }.to_json
    end
  end

  class CategoryMapping
    TagCategory.reverse_mapping.each do |value, category|
      define_method(category) do
        value
      end
    end

    def regexp
      @regexp ||= Regexp.compile(TagCategory.mapping.keys.sort_by {|x| -x.size}.join("|"))
    end

    def value_for(string)
      norm_string = string.to_s.downcase
      if norm_string =~ /\A#{TagCategory.category_ids_regex}\z/
        norm_string.to_i
      elsif TagCategory.mapping[string.to_s.downcase]
        TagCategory.mapping[string.to_s.downcase]
      else
        0
      end
    end
  end

  concerning :CountMethods do
    class_methods do
      # Lock the tags first in alphabetical order to avoid deadlocks under concurrent updates.
      #
      # https://stackoverflow.com/questions/44660368/postgres-update-with-order-by-how-to-do-it
      # https://www.postgresql.org/message-id/flat/freemail.20070030161126.43285%40fm10.freemail.hu
      # https://www.postgresql.org/message-id/flat/CAKOSWNkb3Zy_YFQzwyRw3MRrU10LrMj04%2BHdByfQu6M1S5B7mg%40mail.gmail.com#9dc514507357472bdf22d3109d9c7957
      def increment_post_counts(tag_names)
        Tag.where(name: tag_names).order(:name).lock("FOR UPDATE").pluck(1)
        Tag.where(name: tag_names).update_all("post_count = post_count + 1")
      end

      def decrement_post_counts(tag_names)
        Tag.where(name: tag_names).order(:name).lock("FOR UPDATE").pluck(1)
        Tag.where(name: tag_names).update_all("post_count = post_count - 1")
      end

      # fix tags where the post count is non-zero but the tag isn't present on any posts.
      def regenerate_nonexistent_post_counts!
        Tag.find_by_sql(<<~SQL.squish)
          UPDATE tags
          SET post_count = 0
          WHERE
            post_count != 0
            AND name NOT IN (
              SELECT DISTINCT tag
              FROM posts, unnest(string_to_array(tag_string, ' ')) AS tag
              GROUP BY tag
            )
          RETURNING tags.*
        SQL
      end

      # fix tags where the stored post count doesn't match the true post count.
      def regenerate_incorrect_post_counts!
        Tag.find_by_sql(<<~SQL.squish)
          UPDATE tags
          SET post_count = true_count
          FROM (
            SELECT tag, COUNT(*) AS true_count
            FROM posts, unnest(string_to_array(tag_string, ' ')) AS tag
            GROUP BY tag
          ) true_counts
          WHERE
            tags.name = tag AND tags.post_count != true_count
          RETURNING tags.*
        SQL
      end

      def regenerate_post_counts!
        tags = []
        tags += regenerate_incorrect_post_counts!
        tags += regenerate_nonexistent_post_counts!
        tags
      end
    end

    def empty?
      post_count <= 0
    end
  end

  concerning :CategoryMethods do
    class_methods do
      def categories
        @categories ||= CategoryMapping.new
      end

      def select_category_for(tag_name)
        Tag.where(name: tag_name).pick(:category).to_i
      end

      def categories_for(tag_names)
        Cache.get_multi(Array(tag_names), "tc") do |tag|
          Tag.select_category_for(tag)
        end
      end
    end

    # define artist?, general?, character?, copyright?, meta?
    TagCategory.categories.each do |category_name|
      define_method("#{category_name}?") do
        category == Tag.categories.send(category_name)
      end
    end

    def category_name
      TagCategory.reverse_mapping[category].capitalize
    end

    def update_category_post_counts
      Post.with_timeout(30_000) do
        Post.raw_tag_match(name).find_each do |post|
          post.update_tag_category_counts
          post.save!
        end
      end
    end

    def update_category_cache
      Cache.put("tc:#{Cache.hash(name)}", category, 3.hours)
    end
  end

  concerning :NameMethods do
    def name=(name)
      super(name)
      self.words = Tag.parse_words(name)
    end

    def pretty_name
      name.tr("_", " ")
    end

    def unqualified_name
      name.gsub(/_\(.*\)\z/, "").tr("_", " ")
    end

    class_methods do
      def normalize_name(name)
        name.to_s.downcase.strip.tr(" ", "_").to_s
      end

      def create_for_list(names)
        names.map {|x| find_or_create_by_name(x).name}
      end

      def find_or_create_by_name(name, creator: CurrentUser.user)
        name = normalize_name(name)
        category = nil

        if name =~ /\A(#{categories.regexp}):(.+)\Z/
          category = $1
          name = $2
        end

        tag = find_by_name(name)

        if tag
          if category
            category_id = categories.value_for(category)

            # in case a category change hasn't propagated to this server yet,
            # force an update the local cache. This may get overwritten in the
            # next few lines if the category is changed.
            tag.update_category_cache

            if Pundit.policy!(creator, tag).can_change_category?
              tag.update(category: category_id)
            end
          end

          tag
        else
          Tag.new.tap do |t|
            t.name = name
            t.category = categories.value_for(category)
            t.save
          end
        end
      end
    end
  end

  concerning :DeprecationMethods do
    def create_mod_action
      return if CurrentUser.user == User.system
      if is_deprecated_was == true and is_deprecated == false
        ModAction.log("marked the tag [[#{name}]] as not deprecated", :tag_undeprecate)
      elsif is_deprecated_was == false and is_deprecated == true
        ModAction.log("marked the tag [[#{name}]] as deprecated", :tag_deprecate)
      end
    end
  end

  concerning :WordMethods do
    # Characters that delimit words in tags.
    WORD_DELIMITERS = " _+:;!./()-"
    WORD_DELIMITER_REGEX = /([#{WORD_DELIMITERS}]+[^a-zA-Z0-9]*|[^a-zA-Z0-9]*[#{WORD_DELIMITERS}]+|\A[^[a-zA-Z0-9]]+|[^[a-zA-Z0-9]]+\z)/

    class_methods do
      # Split the tag at word boundaries.
      #
      # Tag.split_words("jeanne_d'arc_alter_(fate)") => ["jeanne", "_", "d'arc", "_", "alter", "_(", "fate", ")"]
      # Tag.split_words(%q{don't_say_"lazy"}) => ["don't", "_", "say", '_"', "lazy", '"']
      # Tag.split_words("jack-o'-lantern") => ["jack", "-", "o", "'-", "lantern"]
      # Tag.split_words("<o>_<o>") => ["<o>_<o>"]
      def split_words(name)
        return [name] if !parsable_into_words?(name)

        name.split(WORD_DELIMITER_REGEX).reject(&:empty?)
      end

      # Parse the tag into plain words, removing punctuation and delimiters.
      #
      # Tag.parse_words("jeanne_d'arc_alter_(fate)") => ["jeanne", "d'arc", "alter", "fate"]
      # Tag.parse_words(%q{don't_say_"lazy"}) => ["don't", "say", "lazy"]
      # Tag.parse_words("jack-o'-lantern") => ["jack", "o", "lantern"]
      # Tag.parse_words("<o>_<o>") => ["<o>_<o>"]
      def parse_words(name)
        return [name] if !parsable_into_words?(name)

        split_words(name).map do |word|
          word.remove(/\A[^a-zA-Z0-9]+|[^a-zA-Z0-9]+\z/)
        end.compact_blank
      end

      # True if the tag can be parsed into words (it contains at least 2 contiguous letters or numbers).
      #
      # Tag.parsable_into_words?("k-on!") => true
      # Tag.parsable_into_words?("<o>_<o>") => false
      # Tag.parsable_into_words?("m.u.g.e.n") => false
      def parsable_into_words?(name)
        name.match?(/[a-zA-Z0-9]{2}/)
      end

      # True if the `string` contains all the words in the `query`.
      #
      # Tag.includes_all_words?("holding_hands", ["hand*", "hold*"]) => true
      def includes_all_words?(string, query)
        words = parse_words(string)
        query.all? { |pattern| words.any? { |word| word.ilike?(pattern) }}
      end

      # Parse a string into a query for performing a word-based search.
      #
      # Tag.parse_query("holding_hand") => ["holding", "hand*"]
      # Tag.parse_query("looking_at_") => ["looking", "at"]
      def parse_query(string)
        query = parse_words(string)
        query[-1] += "*" unless string.match?(/[#{WORD_DELIMITERS}]\z/)
        query
      end
    end
  end

  module SearchMethods
    def autocorrect_matches(name)
      fuzzy_name_matches(name).order_similarity(name)
    end

    # ref: https://www.postgresql.org/docs/current/static/pgtrgm.html#idm46428634524336
    def order_similarity(name)
      order(Arel.sql("levenshtein(left(name, 255), #{connection.quote(name)}), tags.post_count DESC, tags.name ASC"))
    end

    # ref: https://www.postgresql.org/docs/current/static/pgtrgm.html#idm46428634524336
    def fuzzy_name_matches(name)
      max_distance = [name.size / 4, 3].max.floor.to_i
      where("tags.name % ?", name).where("levenshtein(left(name, 255), ?) < ?", name, max_distance)
    end

    def name_matches(name)
      where_like(:name, normalize_name(name))
    end

    def alias_matches(name)
      where(name: TagAlias.active.where_like(:antecedent_name, normalize_name(name)).select(:consequent_name))
    end

    def name_or_alias_matches(name)
      name_matches(name).or(alias_matches(name))
    end

    def wildcard_matches(tag)
      nonempty.name_matches(tag).order(post_count: :desc, name: :asc)
    end

    def abbreviation_matches(abbrev)
      abbrev = abbrev.downcase.delete_prefix("/")
      return none if abbrev !~ /\A[a-z0-9*]*\z/

      where("regexp_replace(tags.name, ?, '\\1', 'g') LIKE ?", ABBREVIATION_REGEXP.source, abbrev.to_escaped_for_sql_like)
    end

    def find_by_name_or_alias(name)
      find_by_name(TagAlias.to_aliased(normalize_name(name)))
    end

    def find_by_abbreviation(abbrev)
      abbreviation_matches(abbrev.escape_wildcards).order(post_count: :desc).first
    end

    def search(params)
      q = search_attributes(params, :id, :created_at, :updated_at, :is_deprecated, :category, :post_count, :name, :wiki_page, :artist, :antecedent_alias, :consequent_aliases, :antecedent_implications, :consequent_implications, :dtext_links)

      if params[:fuzzy_name_matches].present?
        q = q.fuzzy_name_matches(params[:fuzzy_name_matches])
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:name_normalize].present?
        q = q.where("tags.name": normalize_name(params[:name_normalize]).split(","))
      end

      if params[:name_or_alias_matches].present?
        q = q.name_or_alias_matches(params[:name_or_alias_matches])
      end

      if params[:is_empty].to_s.truthy?
        q = q.empty
      elsif params[:is_empty].to_s.falsy?
        q = q.nonempty
      end

      if params[:hide_empty].to_s.truthy?
        q = q.nonempty
      end

      case params[:order]
      when "name"
        q = q.order(name: :asc)
      when "date"
        q = q.order(id: :desc)
      when "count"
        q = q.order(post_count: :desc)
      when "similarity"
        q = q.order_similarity(params[:fuzzy_name_matches]) if params[:fuzzy_name_matches].present?
      else
        q = q.apply_default_order(params)
      end

      q
    end

    def names_matches_with_aliases(name, limit)
      name = normalize_name(name)
      wildcard_name = "#{name}*"

      query1 =
        Tag
        .nonempty
        .select("tags.name, tags.post_count, tags.category, null AS antecedent_name")
        .name_matches(wildcard_name)
        .order(post_count: :desc)
        .limit(limit)

      query2 =
        TagAlias
        .select("tags.name, tags.post_count, tags.category, tag_aliases.antecedent_name")
        .joins("INNER JOIN tags ON tags.name = tag_aliases.consequent_name")
        .where_like(:antecedent_name, wildcard_name)
        .active
        .where_not_like("tags.name", wildcard_name)
        .where("tags.post_count > 0")
        .order("tags.post_count desc")
        .limit(limit * 2) # Get extra records in case some duplicates get filtered out.

      sql_query = "((#{query1.to_sql}) UNION ALL (#{query2.to_sql})) AS unioned_query"
      tags = Tag.select("DISTINCT ON (name, post_count) *").from(sql_query).order("post_count desc").limit(limit)

      if tags.empty?
        tags = Tag.select("tags.name, tags.post_count, tags.category, null AS antecedent_name").fuzzy_name_matches(name).order_similarity(name).nonempty.limit(limit)
      end

      tags
    end
  end

  def self.automatic_tags_for(names)
    tags = []
    tags += names.grep(/\A(.+)_\(cosplay\)\z/i) { $1 }
    tags << "cosplay" if names.any?(/_\(cosplay\)\z/i)
    tags << "school_uniform" if names.any?(/_school_uniform\z/i)
    tags << "meme" if names.any?(/_\(meme\)\z/i)
    tags.uniq
  end

  concerning :CosplayTagMethods do
    def create_character_tag_for_cosplay_tag
      character_name = name.delete_suffix("_(cosplay)")
      Tag.find_or_create_by_name("char:#{character_name}")
    end

    def is_cosplay_tag?
      name.end_with?("_(cosplay)")
    end
  end

  def implied_tags
    TagImplication.tags_implied_by([name])
  end

  def implies?(tag_name)
    implied_tags.exists?(name: tag_name)
  end

  def posts
    Post.system_tag_match(name)
  end

  def abbreviation
    name.gsub(ABBREVIATION_REGEXP, "\\1")
  end

  def tag_alias_for_pattern(pattern)
    return nil if pattern.blank?

    consequent_aliases.find do |tag_alias|
      !name.ilike?(pattern) && tag_alias.antecedent_name.ilike?(pattern)
    end
  end

  # If this tag has aliases, find the shortest alias matching the given pattern.
  def tag_alias_for_word_pattern(query)
    query = Tag.parse_query(query)
    aliases = consequent_aliases.sort_by { |ca| [ca.antecedent_name.size, ca.antecedent_name] }

    aliases.find do |tag_alias|
      name_matches = Tag.includes_all_words?(name, query)
      antecedent_matches = Tag.includes_all_words?(tag_alias.antecedent_name, query)

      antecedent_matches && !name_matches
    end
  end

  def is_aliased?
    aliased_tag.present?
  end

  def metatag?
    name.match?(/\A#{PostQueryBuilder::METATAGS.join("|")}:/i)
  end

  def self.model_restriction(table)
    super.where(table[:post_count].gt(0))
  end

  def self.available_includes
    [:wiki_page, :artist, :antecedent_alias, :consequent_aliases, :antecedent_implications, :consequent_implications, :dtext_links]
  end

  include ApiMethods
  extend SearchMethods
end
