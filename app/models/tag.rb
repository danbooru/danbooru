class Tag < ApplicationRecord
  COUNT_METATAGS = %w[
    comment_count deleted_comment_count active_comment_count
    note_count deleted_note_count active_note_count
    flag_count resolved_flag_count unresolved_flag_count
    child_count deleted_child_count active_child_count
    pool_count deleted_pool_count active_pool_count series_pool_count collection_pool_count
    appeal_count approval_count replacement_count
  ]

  # allow e.g. `deleted_comments` as a synonym for `deleted_comment_count`
  COUNT_METATAG_SYNONYMS = COUNT_METATAGS.map { |str| str.delete_suffix("_count").pluralize }

  METATAGS = %w[
    -user user -approver approver commenter comm noter noteupdater artcomm
    -pool pool ordpool -favgroup favgroup -fav fav ordfav md5 -rating rating
    -locked locked width height mpixels ratio score favcount filesize source
    -source id -id date age order limit -status status tagcount parent -parent
    child pixiv_id pixiv search upvote downvote filetype -filetype flagger
    -flagger appealer -appealer disapproval -disapproval embedded
  ] + TagCategory.short_name_list.map {|x| "#{x}tags"} + COUNT_METATAGS + COUNT_METATAG_SYNONYMS

  SUBQUERY_METATAGS = %w[commenter comm noter noteupdater artcomm flagger -flagger appealer -appealer]

  ORDER_METATAGS = %w[
    id id_desc
    score score_asc
    favcount favcount_asc
    created_at created_at_asc
    change change_asc
    comment comment_asc
    comment_bumped comment_bumped_asc
    note note_asc
    artcomm artcomm_asc
    mpixels mpixels_asc
    portrait landscape
    filesize filesize_asc
    tagcount tagcount_asc
    rank
    random
    custom
  ] +
    COUNT_METATAGS +
    COUNT_METATAG_SYNONYMS.flat_map { |str| [str, "#{str}_asc"] } +
    TagCategory.short_name_list.flat_map { |str| ["#{str}tags", "#{str}tags_asc"] }

  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :artist, :foreign_key => "name", :primary_key => "name"
  has_one :antecedent_alias, -> {active}, :class_name => "TagAlias", :foreign_key => "antecedent_name", :primary_key => "name"
  has_many :consequent_aliases, -> {active}, :class_name => "TagAlias", :foreign_key => "consequent_name", :primary_key => "name"
  has_many :antecedent_implications, -> {active}, :class_name => "TagImplication", :foreign_key => "antecedent_name", :primary_key => "name"
  has_many :consequent_implications, -> {active}, :class_name => "TagImplication", :foreign_key => "consequent_name", :primary_key => "name"

  validates :name, tag_name: true, uniqueness: true, on: :create
  validates :name, tag_name: true, on: :name
  validates_inclusion_of :category, in: TagCategory.category_ids

  before_save :update_category_cache, if: :category_changed?
  before_save :update_category_post_counts, if: :category_changed?

  module ApiMethods
    def to_legacy_json
      return {
        "name" => name,
        "id" => id,
        "created_at" => created_at.try(:strftime, "%Y-%m-%d %H:%M"),
        "count" => post_count,
        "type" => category,
        "ambiguous" => false
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
      TagCategory.mapping[string.to_s.downcase] || 0
    end
  end

  module CountMethods
    extend ActiveSupport::Concern

    module ClassMethods
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
        Tag.find_by_sql(<<~SQL)
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
        Tag.find_by_sql(<<~SQL)
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
  end

  module CategoryMethods
    module ClassMethods
      def categories
        @categories ||= CategoryMapping.new
      end

      def select_category_for(tag_name)
        select_value_sql("SELECT category FROM tags WHERE name = ?", tag_name).to_i
      end

      def category_for(tag_name, options = {})
        return Tag.categories.general if tag_name.blank?

        if options[:disable_caching]
          select_category_for(tag_name)
        else
          Cache.get("tc:#{Cache.hash(tag_name)}") do
            select_category_for(tag_name)
          end
        end
      end

      def categories_for(tag_names, options = {})
        if options[:disable_caching]
          Array(tag_names).inject({}) do |hash, tag_name|
            hash[tag_name] = select_category_for(tag_name)
            hash
          end
        else
          Cache.get_multi(Array(tag_names), "tc") do |tag|
            Tag.select_category_for(tag)
          end
        end
      end
    end

    def self.included(m)
      m.extend(ClassMethods)
    end

    def category_name
      TagCategory.reverse_mapping[category].capitalize
    end

    def update_category_post_counts
      Post.with_timeout(30_000, nil, :tags => name) do
        Post.raw_tag_match(name).where("true /* Tag#update_category_post_counts */").find_each do |post|
          post.reload
          post.set_tag_counts(false)
          args = TagCategory.categories.map {|x| ["tag_count_#{x}", post.send("tag_count_#{x}")]}.to_h.update(:tag_count => post.tag_count)
          Post.where(:id => post.id).update_all(args)
        end
      end
    end

    def update_category_cache
      Cache.put("tc:#{Cache.hash(name)}", category, 3.hours)
    end
  end

  concerning :NameMethods do
    def pretty_name
      name.tr("_", " ")
    end

    def unqualified_name
      name.gsub(/_\(.*\)\z/, "").tr("_", " ")
    end

    class_methods do
      def normalize_name(name)
        name.to_s.mb_chars.downcase.strip.tr(" ", "_").to_s
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

            if tag.editable_by?(creator)
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

  module ParseMethods
    def normalize(query)
      query.to_s.gsub(/\u3000/, " ").strip
    end

    def normalize_query(query, normalize_aliases: true, sort: true)
      tags = Tag.scan_query(query.to_s)
      tags = tags.map { |t| Tag.normalize_name(t) }
      tags = TagAlias.to_aliased(tags) if normalize_aliases
      tags = tags.sort if sort
      tags = tags.uniq
      tags.join(" ")
    end

    def scan_query(query)
      tagstr = normalize(query)
      list = tagstr.scan(/-?source:".*?"/) || []
      list + tagstr.gsub(/-?source:".*?"/, "").scan(/[^[:space:]]+/).uniq
    end

    def scan_tags(tags, options = {})
      tagstr = normalize(tags)
      list = tagstr.scan(/source:".*?"/) || []
      list += tagstr.gsub(/source:".*?"/, "").scan(/[^[:space:]]+/).uniq
      if options[:strip_metatags]
        list = list.map {|x| x.sub(/^[-~]/, "")}
      end
      list
    end

    def parse_cast(object, type)
      case type
      when :integer
        object.to_i

      when :float
        object.to_f

      when :date, :datetime
        Time.zone.parse(object) rescue nil

      when :age
        DurationParser.parse(object).ago

      when :ratio
        object =~ /\A(\d+(?:\.\d+)?):(\d+(?:\.\d+)?)\Z/i

        if $1 && $2.to_f != 0.0
          ($1.to_f / $2.to_f).round(2)
        else
          object.to_f.round(2)
        end

      when :filesize
        object =~ /\A(\d+(?:\.\d*)?|\d*\.\d+)([kKmM]?)[bB]?\Z/

        size = $1.to_f
        unit = $2

        conversion_factor = case unit
        when /m/i
          1024 * 1024
        when /k/i
          1024
        else
          1
        end

        (size * conversion_factor).to_i
      end
    end

    def parse_helper(range, type = :integer)
      # "1", "0.5", "5.", ".5":
      # (-?(\d+(\.\d*)?|\d*\.\d+))
      case range
      when /\A(.+?)\.\.(.+)/
        return [:between, parse_cast($1, type), parse_cast($2, type)]

      when /\A<=(.+)/, /\A\.\.(.+)/
        return [:lte, parse_cast($1, type)]

      when /\A<(.+)/
        return [:lt, parse_cast($1, type)]

      when /\A>=(.+)/, /\A(.+)\.\.\Z/
        return [:gte, parse_cast($1, type)]

      when /\A>(.+)/
        return [:gt, parse_cast($1, type)]

      when /[, ]/
        return [:in, range.split(/[, ]+/).map {|x| parse_cast(x, type)}]

      else
        return [:eq, parse_cast(range, type)]

      end
    end

    def parse_helper_fudged(range, type)
      result = parse_helper(range, type)
      # Don't fudge the filesize when searching filesize:123b or filesize:123.
      if result[0] == :eq && type == :filesize && range !~ /[km]b?\Z/i
        result
      elsif result[0] == :eq
        new_min = (result[1] * 0.95).to_i
        new_max = (result[1] * 1.05).to_i
        [:between, new_min, new_max]
      else
        result
      end
    end

    def reverse_parse_helper(array)
      case array[0]
      when :between
        [:between, *array[1..-1].reverse]

      when :lte
        [:gte, *array[1..-1]]

      when :lt
        [:gt, *array[1..-1]]

      when :gte
        [:lte, *array[1..-1]]

      when :gt
        [:lt, *array[1..-1]]

      else
        array
      end
    end

    def parse_tag(tag, output)
      if tag[0] == "-" && tag.size > 1
        output[:exclude] << tag[1..-1].mb_chars.downcase

      elsif tag[0] == "~" && tag.size > 1
        output[:include] << tag[1..-1].mb_chars.downcase

      elsif tag =~ /\*/
        matches = Tag.name_matches(tag).select("name").limit(Danbooru.config.tag_query_limit).order("post_count DESC").map(&:name)
        matches = ["~no_matches~"] if matches.empty?
        output[:include] += matches

      else
        output[:related] << tag.mb_chars.downcase
      end
    end

    # true if query is a single "simple" tag (not a metatag, negated tag, or wildcard tag).
    def is_simple_tag?(query)
      is_single_tag?(query) && !is_metatag?(query) && !is_negated_tag?(query) && !is_optional_tag?(query) && !is_wildcard_tag?(query)
    end

    def is_single_tag?(query)
      scan_query(query).size == 1
    end

    def is_metatag?(tag)
      has_metatag?(tag, *METATAGS)
    end

    def is_negated_tag?(tag)
      tag.starts_with?("-")
    end

    def is_optional_tag?(tag)
      tag.starts_with?("~")
    end

    def is_wildcard_tag?(tag)
      tag.include?("*")
    end

    def has_metatag?(tags, *metatags)
      return nil if tags.blank?

      tags = scan_query(tags.to_str) if tags.respond_to?(:to_str)
      tags.grep(/\A(?:#{metatags.map(&:to_s).join("|")}):(.+)\z/i) { $1 }.first
    end

    def parse_query(query, options = {})
      q = {}

      q[:tag_count] = 0

      q[:tags] = {
        :related => [],
        :include => [],
        :exclude => []
      }

      scan_query(query).each do |token|
        q[:tag_count] += 1 unless Danbooru.config.is_unlimited_tag?(token)

        if token =~ /\A(#{METATAGS.join("|")}):(.+)\z/i
          g1 = $1.downcase
          g2 = $2
          case g1
          when "-user"
            q[:uploader_id_neg] ||= []
            user_id = User.name_to_id(g2)
            q[:uploader_id_neg] << user_id unless user_id.blank?

          when "user"
            user_id = User.name_to_id(g2)
            q[:uploader_id] = user_id unless user_id.blank?

          when "-approver"
            if g2 == "none"
              q[:approver_id] = "any"
            elsif g2 == "any"
              q[:approver_id] = "none"
            else
              q[:approver_id_neg] ||= []
              user_id = User.name_to_id(g2)
              q[:approver_id_neg] << user_id unless user_id.blank?
            end

          when "approver"
            if g2 == "none"
              q[:approver_id] = "none"
            elsif g2 == "any"
              q[:approver_id] = "any"
            else
              user_id = User.name_to_id(g2)
              q[:approver_id] = user_id unless user_id.blank?
            end

          when "flagger"
            q[:flagger_ids] ||= []

            if g2 == "none"
              q[:flagger_ids] << "none"
            elsif g2 == "any"
              q[:flagger_ids] << "any"
            else
              user_id = User.name_to_id(g2)
              q[:flagger_ids] << user_id unless user_id.blank?
            end

          when "-flagger"
            if g2 == "none"
              q[:flagger_ids] ||= []
              q[:flagger_ids] << "any"
            elsif g2 == "any"
              q[:flagger_ids] ||= []
              q[:flagger_ids] << "none"
            else
              q[:flagger_ids_neg] ||= []
              user_id = User.name_to_id(g2)
              q[:flagger_ids_neg] << user_id unless user_id.blank?
            end

          when "appealer"
            q[:appealer_ids] ||= []

            if g2 == "none"
              q[:appealer_ids] << "none"
            elsif g2 == "any"
              q[:appealer_ids] << "any"
            else
              user_id = User.name_to_id(g2)
              q[:appealer_ids] << user_id unless user_id.blank?
            end

          when "-appealer"
            if g2 == "none"
              q[:appealer_ids] ||= []
              q[:appealer_ids] << "any"
            elsif g2 == "any"
              q[:appealer_ids] ||= []
              q[:appealer_ids] << "none"
            else
              q[:appealer_ids_neg] ||= []
              user_id = User.name_to_id(g2)
              q[:appealer_ids_neg] << user_id unless user_id.blank?
            end

          when "commenter", "comm"
            q[:commenter_ids] ||= []

            if g2 == "none"
              q[:commenter_ids] << "none"
            elsif g2 == "any"
              q[:commenter_ids] << "any"
            else
              user_id = User.name_to_id(g2)
              q[:commenter_ids] << user_id unless user_id.blank?
            end

          when "noter"
            q[:noter_ids] ||= []

            if g2 == "none"
              q[:noter_ids] << "none"
            elsif g2 == "any"
              q[:noter_ids] << "any"
            else
              user_id = User.name_to_id(g2)
              q[:noter_ids] << user_id unless user_id.blank?
            end

          when "noteupdater"
            q[:note_updater_ids] ||= []
            user_id = User.name_to_id(g2)
            q[:note_updater_ids] << user_id unless user_id.blank?

          when "artcomm"
            q[:artcomm_ids] ||= []
            user_id = User.name_to_id(g2)
            q[:artcomm_ids] << user_id unless user_id.blank?

          when "disapproval"
            q[:disapproval] ||= []
            q[:disapproval] << g2

          when "-disapproval"
            q[:disapproval_neg] ||= []
            q[:disapproval_neg] << g2

          when "-pool"
            q[:pool_neg] ||= []
            q[:pool_neg] << g2

          when "pool"
            q[:pool] ||= []
            q[:pool] << g2

          when "ordpool"
            pool_id = Pool.name_to_id(g2)
            q[:ordpool] = pool_id

          when "-favgroup"
            favgroup = FavoriteGroup.find_by_name_or_id!(g2, CurrentUser.user)
            raise User::PrivilegeError unless favgroup.viewable_by?(CurrentUser.user)

            q[:favgroups_neg] ||= []
            q[:favgroups_neg] << favgroup

          when "favgroup"
            favgroup = FavoriteGroup.find_by_name_or_id!(g2, CurrentUser.user)
            raise User::PrivilegeError unless favgroup.viewable_by?(CurrentUser.user)

            q[:favgroups] ||= []
            q[:favgroups] << favgroup

          when "-fav"
            favuser = User.find_by_name(g2)

            if favuser.hide_favorites?
              raise User::PrivilegeError.new
            end

            q[:tags][:exclude] << "fav:#{User.name_to_id(g2)}"

          when "fav"
            favuser = User.find_by_name(g2)

            if favuser.hide_favorites?
              raise User::PrivilegeError.new
            end

            q[:tags][:related] << "fav:#{User.name_to_id(g2)}"

          when "ordfav"
            user_id = User.name_to_id(g2)
            favuser = User.find(user_id)

            if favuser.hide_favorites?
              raise User::PrivilegeError.new
            end

            q[:tags][:related] << "fav:#{user_id}"
            q[:ordfav] = user_id

          when "search"
            q[:saved_searches] ||= []
            q[:saved_searches] << g2

          when "md5"
            q[:md5] = g2.downcase.split(/,/)

          when "-rating"
            q[:rating_negated] = g2.downcase

          when "rating"
            q[:rating] = g2.downcase

          when "-locked"
            q[:locked_negated] = g2.downcase

          when "locked"
            q[:locked] = g2.downcase

          when "id"
            q[:post_id] = parse_helper(g2)

          when "-id"
            q[:post_id_negated] = g2.to_i

          when "width"
            q[:width] = parse_helper(g2)

          when "height"
            q[:height] = parse_helper(g2)

          when "mpixels"
            q[:mpixels] = parse_helper_fudged(g2, :float)

          when "ratio"
            q[:ratio] = parse_helper(g2, :ratio)

          when "score"
            q[:score] = parse_helper(g2)

          when "favcount"
            q[:fav_count] = parse_helper(g2)

          when "filesize"
            q[:filesize] = parse_helper_fudged(g2, :filesize)

          when "source"
            q[:source] = g2.gsub(/\A"(.*)"\Z/, '\1')

          when "-source"
            q[:source_neg] = g2.gsub(/\A"(.*)"\Z/, '\1')

          when "date"
            q[:date] = parse_helper(g2, :date)

          when "age"
            q[:age] = reverse_parse_helper(parse_helper(g2, :age))

          when "tagcount"
            q[:post_tag_count] = parse_helper(g2)

          when /(#{TagCategory.short_name_regex})tags/
            q["#{TagCategory.short_name_mapping[$1]}_tag_count".to_sym] = parse_helper(g2)

          when "parent"
            q[:parent] = g2.downcase

          when "-parent"
            if g2.downcase == "none"
              q[:parent] = "any"
            elsif g2.downcase == "any"
              q[:parent] = "none"
            else
              q[:parent_neg_ids] ||= []
              q[:parent_neg_ids] << g2.downcase
            end

          when "child"
            q[:child] = g2.downcase

          when "order"
            g2 = g2.downcase

            order, suffix, _tail = g2.partition(/_(asc|desc)\z/i)
            if order.in?(COUNT_METATAG_SYNONYMS)
              g2 = order.singularize + "_count" + suffix
            end

            q[:order] = g2

          when "limit"
            # Do nothing. The controller takes care of it.

          when "-status"
            q[:status_neg] = g2.downcase

          when "status"
            q[:status] = g2.downcase

          when "embedded"
            q[:embedded] = g2.downcase

          when "filetype"
            q[:filetype] = g2.downcase

          when "-filetype"
            q[:filetype_neg] = g2.downcase

          when "pixiv_id", "pixiv"
            if g2.downcase == "any" || g2.downcase == "none"
              q[:pixiv_id] = g2.downcase
            else
              q[:pixiv_id] = parse_helper(g2)
            end

          when "upvote"
            if CurrentUser.user.is_admin?
              q[:upvote] = User.find_by_name(g2)
            elsif CurrentUser.user.is_voter?
              q[:upvote] = CurrentUser.user
            end

          when "downvote"
            if CurrentUser.user.is_admin?
              q[:downvote] = User.find_by_name(g2)
            elsif CurrentUser.user.is_voter?
              q[:downvote] = CurrentUser.user
            end

          when *COUNT_METATAGS
            q[g1.to_sym] = parse_helper(g2)

          when *COUNT_METATAG_SYNONYMS
            g1 = "#{g1.singularize}_count"
            q[g1.to_sym] = parse_helper(g2)

          end

        else
          parse_tag(token, q[:tags])
        end
      end

      normalize_tags_in_query(q)

      return q
    end

    def normalize_tags_in_query(query_hash)
      query_hash[:tags][:exclude] = TagAlias.to_aliased(query_hash[:tags][:exclude])
      query_hash[:tags][:include] = TagAlias.to_aliased(query_hash[:tags][:include])
      query_hash[:tags][:related] = TagAlias.to_aliased(query_hash[:tags][:related])
    end
  end

  module SearchMethods
    def empty
      where("tags.post_count <= 0")
    end

    def nonempty
      where("tags.post_count > 0")
    end

    # ref: https://www.postgresql.org/docs/current/static/pgtrgm.html#idm46428634524336
    def order_similarity(name)
      # trunc(3 * sim) reduces the similarity score from a range of 0.0 -> 1.0 to just 0, 1, or 2.
      # This groups tags first by approximate similarity, then by largest tags within groups of similar tags.
      order(Arel.sql("trunc(3 * similarity(name, #{connection.quote(name)})) DESC"), "post_count DESC", "name DESC")
    end

    # ref: https://www.postgresql.org/docs/current/static/pgtrgm.html#idm46428634524336
    def fuzzy_name_matches(name)
      where("tags.name % ?", name)
    end

    def name_matches(name)
      where_like(:name, normalize_name(name))
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :is_locked, :category, :post_count, :name)

      if params[:fuzzy_name_matches].present?
        q = q.fuzzy_name_matches(params[:fuzzy_name_matches])
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:name_normalize].present?
        q = q.where("tags.name": normalize_name(params[:name_normalize]).split(","))
      end

      if params[:hide_empty].blank? || params[:hide_empty].to_s.truthy?
        q = q.where("post_count > 0")
      end

      if params[:has_wiki].to_s.truthy?
        q = q.joins(:wiki_page).where("wiki_pages.is_deleted = false")
      elsif params[:has_wiki].to_s.falsy?
        q = q.joins("LEFT JOIN wiki_pages ON tags.name = wiki_pages.title").where("wiki_pages.title IS NULL OR wiki_pages.is_deleted = true")
      end

      if params[:has_artist].to_s.truthy?
        q = q.joins("INNER JOIN artists ON tags.name = artists.name").where("artists.is_active = true")
      elsif params[:has_artist].to_s.falsy?
        q = q.joins("LEFT JOIN artists ON tags.name = artists.name").where("artists.name IS NULL OR artists.is_active = false")
      end

      case params[:order]
      when "name"
        q = q.order("name")
      when "date"
        q = q.order("id desc")
      when "count"
        q = q.order("post_count desc")
      when "similarity"
        q = q.order_similarity(params[:fuzzy_name_matches]) if params[:fuzzy_name_matches].present?
      else
        q = q.apply_default_order(params)
      end

      q
    end

    def names_matches_with_aliases(name, limit)
      name = normalize_name(name)
      wildcard_name = name + '*'

      query1 =
        Tag
        .select("tags.name, tags.post_count, tags.category, null AS antecedent_name")
        .search(:name_matches => wildcard_name, :order => "count").limit(limit)

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

  def self.convert_cosplay_tags(tags)
    cosplay_tags, other_tags = tags.partition {|tag| tag.match(/\A(.+)_\(cosplay\)\Z/) }
    cosplay_tags.grep(/\A(.+)_\(cosplay\)\Z/) { "#{TagAlias.to_aliased([$1]).first}_(cosplay)" } + other_tags
  end

  def editable_by?(user)
    return true if user.is_admin?
    return true if !is_locked? && user.is_builder? && post_count < 1_000
    return true if !is_locked? && user.is_member? && post_count < 50
    return false
  end

  def posts
    Post.tag_match(name)
  end

  def self.available_includes
    [:wiki_page, :artist, :antecedent_alias, :consequent_aliases, :antecedent_implications, :consequent_implications]
  end

  include ApiMethods
  include CountMethods
  include CategoryMethods
  extend ParseMethods
  extend SearchMethods
end
