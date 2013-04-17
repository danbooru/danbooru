class Tag < ActiveRecord::Base
  METATAGS = "-user|user|-approver|approver|commenter|comm|noter|-pool|pool|-fav|fav|sub|md5|-rating|rating|-locked|locked|width|height|mpixels|score|favcount|filesize|source|id|date|age|order|-status|status|tagcount|gentags|arttags|chartags|copytags|parent|-parent|pixiv_id|pixiv"
  attr_accessible :category
  has_one :wiki_page, :foreign_key => "name", :primary_key => "title"

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
    Danbooru.config.reverse_tag_category_mapping.each do |value, category|
      define_method(category.downcase) do
        value
      end
    end

    def regexp
      @regexp ||= Regexp.compile(Danbooru.config.tag_category_mapping.keys.sort_by {|x| -x.size}.join("|"))
    end

    def value_for(string)
      Danbooru.config.tag_category_mapping[string.to_s.downcase] || 0
    end
  end

  module CountMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def counts_for(tag_names)
        select_all_sql("SELECT name, post_count FROM tags WHERE name IN (?)", tag_names)
      end
    end

    def real_post_count
      @real_post_count ||= Post.raw_tag_match(name).count
    end

    def fix_post_count
      update_column(:post_count, real_post_count)
    end
  end

  module ViewCountMethods
    def increment_view_count(name)
      Cache.incr("tvc:#{Cache.sanitize(name)}")
    end
  end

  module CategoryMethods
    module ClassMethods
      def categories
        @category_mapping ||= CategoryMapping.new
      end

      def select_category_for(tag_name)
        select_value_sql("SELECT category FROM tags WHERE name = ?", tag_name).to_i
      end

      def category_for(tag_name)
        Cache.get("tc:#{Cache.sanitize(tag_name)}") do
          select_category_for(tag_name)
        end
      end

      def categories_for(tag_names)
        Array(tag_names).inject({}) do |hash, tag_name|
          hash[tag_name] = category_for(tag_name)
          hash
        end
        # Cache.get_multi(tag_names, "tc") do |name|
        #   select_category_for(name)
        # end
      end
    end

    def self.included(m)
      m.extend(ClassMethods)
    end

    def category_name
      Danbooru.config.reverse_tag_category_mapping[category]
    end

    def update_category_cache_for_all
      update_category_cache
      Danbooru.config.other_server_hosts.each do |host|
        delay(:queue => host).update_category_cache
      end
      delay(:queue => "default").update_category_post_counts
    end

    def update_category_post_counts
      Post.with_timeout(30_000, nil) do
        Post.raw_tag_match(name).find_each do |post|
          post.reload
          post.set_tag_counts
          post.update_column(:tag_count, post.tag_count)
          post.update_column(:tag_count_general, post.tag_count_general)
          post.update_column(:tag_count_artist, post.tag_count_artist)
          post.update_column(:tag_count_copyright, post.tag_count_copyright)
          post.update_column(:tag_count_character, post.tag_count_character)
        end
      end
    end

    def update_category_cache
      Cache.put("tc:#{Cache.sanitize(name)}", category, 1.hour)
    end
  end

  module StatisticsMethods
    def trending
      raise NotImplementedError
    end
  end

  module NameMethods
    def normalize_name(name)
      name.mb_chars.downcase.tr(" ", "_").gsub(/\A[-~]+/, "").gsub(/\*/, "").to_s
    end

    def find_or_create_by_name(name, options = {})
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

          if category_id != tag.category && (CurrentUser.is_builder? || tag.post_count <= 50)
            tag.update_column(:category, category_id)
            tag.update_category_cache_for_all
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

  module ParseMethods
    def normalize(query)
      query.to_s.strip
    end

    def scan_query(query)
      normalize(query).scan(/\S+/).uniq
    end

    def scan_tags(tags)
      normalize(tags).gsub(/[%,]/, "").scan(/\S+/).uniq
    end

    def parse_cast(object, type)
      case type
      when :integer
        object.to_i

      when :float
        object.to_f

      when :date
        begin
          Time.zone.parse(object)
        rescue Exception
          nil
        end

      when :age
        object =~ /(\d+)(s(econds?)?|mi(nutes?)?|h(ours?)?|d(ays?)?|w(eeks?)?|mo(nths?)?|y(ears?)?)?/i

        size = $1.to_i
        unit = $2

        conversion_factor = case unit
        when /^s/i
          1.second
        when /^mi/i
          1.minute
        when /^h/i
          1.hour
        when /^d/i
          1.day
        when /^w/i
          1.week
        when /^mo/i
          1.month
        when /^y/i
          1.year
        else
          1.second
        end

        (size * conversion_factor).to_i

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

      when /,/
        return [:in, range.split(/,/)]

      else
        return [:eq, parse_cast(range, type)]

      end
    end

    def parse_tag(tag, output)
      if tag[0] == "-" && tag.size > 1
        output[:exclude] << tag[1..-1].mb_chars.downcase

      elsif tag[0] == "~" && tag.size > 1
        output[:include] << tag[1..-1].mb_chars.downcase

      elsif tag =~ /\*/
        matches = Tag.name_matches(tag.downcase).all(:select => "name", :limit => Danbooru.config.tag_query_limit, :order => "post_count DESC").map(&:name)
        matches = ["~no_matches~"] if matches.empty?
        output[:include] += matches

      else
        output[:related] << tag.mb_chars.downcase
      end
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
        q[:tag_count] += 1 unless token == "status:deleted"

        if token =~ /\A(#{METATAGS}):(.+)\Z/
          case $1
          when "-user"
            q[:uploader_id_neg] ||= []
            user_id = User.name_to_id($2)
            q[:uploader_id_neg] << user_id unless user_id.blank?

          when "user"
            q[:uploader_id] = User.name_to_id($2)
            q[:uploader_id] = -1 if q[:uploader_id].blank?

          when "-approver"
            q[:approver_id_neg] ||= []
            user_id = User.name_to_id($2)
            q[:approver_id_neg] << user_id unless user_id.blank?

          when "approver"
            q[:approver_id] = User.name_to_id($2)
            q[:approver_id] = -1 if q[:approver_id].blank?

          when "commenter", "comm"
            q[:commenter_id] = User.name_to_id($2)
            q[:commenter_id] = -1 if q[:commenter_id].blank?

          when "noter"
            q[:noter_id] = User.name_to_id($2)
            q[:noter_id] = -1 if q[:noter_id].blank?

          when "-pool"
            q[:tags][:exclude] << "pool:#{Pool.name_to_id($2)}"

          when "pool"
            q[:tags][:related] << "pool:#{Pool.name_to_id($2)}"

          when "-fav"
            q[:tags][:exclude] << "fav:#{User.name_to_id($2)}"

          when "fav"
            q[:tags][:related] << "fav:#{User.name_to_id($2)}"

          when "sub"
            q[:subscriptions] ||= []
            q[:subscriptions] << $2

          when "md5"
            q[:md5] = $2.downcase.split(/,/)

          when "-rating"
            q[:rating_negated] = $2

          when "rating"
            q[:rating] = $2

          when "-locked"
            q[:locked_negated] = $2

          when "locked"
            q[:locked] = $2

          when "id"
            q[:post_id] = parse_helper($2)

          when "width"
            q[:width] = parse_helper($2)

          when "height"
            q[:height] = parse_helper($2)

          when "mpixels"
            q[:mpixels] = parse_helper($2, :float)

          when "score"
            q[:score] = parse_helper($2)

          when "favcount"
            q[:fav_count] = parse_helper($2)

          when "filesize"
      	    q[:filesize] = parse_helper($2, :filesize)

          when "source"
            q[:source] = ($2.to_escaped_for_sql_like + "%").gsub(/%+/, '%')

          when "date"
            q[:date] = parse_helper($2, :date)

          when "age"
            q[:age] = parse_helper($2, :age)

          when "tagcount"
            q[:post_tag_count] = parse_helper($2)

          when "gentags"
            q[:general_tag_count] = parse_helper($2)

          when "arttags"
            q[:artist_tag_count] = parse_helper($2)

          when "chartags"
            q[:character_tag_count] = parse_helper($2)

          when "copytags"
            q[:copyright_tag_count] = parse_helper($2)

          when "parent"
            q[:parent] = $2.downcase

          when "-parent"
            q[:parent_neg] = $2.downcase

          when "order"
            q[:order] = $2.downcase

          when "-status"
            q[:status_neg] = $2.downcase

          when "status"
            q[:status] = $2.downcase

          when "pixiv_id", "pixiv"
            q[:pixiv_id] = parse_helper($2)

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

  module RelationMethods
    def update_related
      return unless should_update_related?
      CurrentUser.scoped(User.first, "127.0.0.1") do
        self.related_tags = RelatedTagCalculator.calculate_from_sample_to_array(name).join(" ")
      end
      self.related_tags_updated_at = Time.now
      save
    rescue ActiveRecord::StatementInvalid
    end

    def update_related_if_outdated
      if should_update_related? && Delayed::Job.count < 200
        delay(:queue => "default").update_related
      end
    end

    def related_cache_expiry
      base = Math.sqrt([post_count, 0].max)
      if base > 24 * 7
        24 * 7
      elsif base < 24
        24
      else
        base
      end
    end

    def should_update_related?
      related_tags.blank? || related_tags_updated_at.blank? || related_tags_updated_at < related_cache_expiry.hours.ago
    end

    def related_tag_array
      update_related_if_outdated
      related_tags.to_s.split(/ /).in_groups_of(2)
    end
  end

  module SuggestionMethods
    def find_suggestions(query)
      query_tokens = query.split(/_/)

      if query_tokens.size == 2
        search_for = query_tokens.reverse.join("_").to_escaped_for_sql_like
      else
        search_for = "%" + query.to_escaped_for_sql_like + "%"
      end

      Tag.where(["name LIKE ? ESCAPE E'\\\\' AND post_count > 0 AND name <> ?", search_for, query]).all(:order => "post_count DESC", :limit => 6, :select => "name").map(&:name).sort
    end
  end

  module SearchMethods
    def name_matches(name)
      where("name LIKE ? ESCAPE E'\\\\'", name.mb_chars.downcase.to_escaped_for_sql_like)
    end

    def named(name)
      where("name = ?", TagAlias.to_aliased([name]).join(""))
    end

    def search(params)
      q = scoped
      params = {} if params.blank?

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches].strip.tr(" ", "_"))
      end

      if params[:category].present?
        q = q.where("category = ?", params[:category])
      end

      if params[:hide_empty].blank? || params[:hide_empty] != "no"
        q = q.where("post_count > 0")
      end

      if params[:limit].present?
        q = q.limit(params[:limit].to_i)
      end

      if params[:order] == "name"
        q = q.reorder("name")

      elsif params[:order] == "date"
        q = q.reorder("id desc")

      elsif params[:sort] == "date"
        q = q.reorder("id desc")

      elsif params[:sort] == "name"
        q = q.reorder("name")

      else
        q = q.reorder("post_count desc")
      end

      q
    end
  end

  include ApiMethods
  include CountMethods
  extend ViewCountMethods
  include CategoryMethods
  extend StatisticsMethods
  extend NameMethods
  extend ParseMethods
  include RelationMethods
  extend SuggestionMethods
  extend SearchMethods
end
