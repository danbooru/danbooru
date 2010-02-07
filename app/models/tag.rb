class Tag < ActiveRecord::Base
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
      Danbooru.config.tag_category_mapping[string.downcase] || 0
    end
  end
  
  attr_accessible :category
  
  after_save {|rec| Cache.put("tag_type:#{cache_safe_name}", rec.category_name)}
  
  
  ### Category Methods ###
  def self.categories
    @category_mapping ||= CategoryMapping.new
  end
  
  def category_name
    Danbooru.config.reverse_tag_category_mapping[category]
  end
  
  
  ### Statistics Methods ###
  def self.trending
    raise NotImplementedError
  end
  
  
  ### Name Methods ###
  def self.normalize_name(name)
    name.downcase.tr(" ", "_").gsub(/\A[-~*]+/, "")
  end
  
  def self.find_or_create_by_name(name, options = {})
    name = normalize_name(name)
    category = categories.general
    
    if name =~ /\A(#{categories.regexp}):(.+)\Z/
      category = categories.value_for($1)
      name = $2
    end
    
    tag = find_by_name(name)

    if tag
      if category > 0 && !(options[:user] && !options[:user].is_privileged? && tag.post_count > 10)
        tag.update_attribute(:category, category)
      end
      
      tag
    else
      returning Tag.new do |tag|
        tag.name = name
        tag.category = category
        tag.save
      end
    end
  end
  
  def cache_safe_name
    name.gsub(/[^a-zA-Z0-9_-]/, "_")
  end
  
  
  ### Update methods ###
  def self.mass_edit(start_tags, result_tags, updater_id, updater_ip_addr)
    raise NotImplementedError
    
    Post.find_by_tags(start_tags).each do |p|
      start = TagAlias.to_aliased(scan_tags(start_tags))
      result = TagAlias.to_aliased(scan_tags(result_tags))
      tags = (p.cached_tags.scan(/\S+/) - start + result).join(" ")
      p.update_attributes(:updater_user_id => updater_id, :updater_ip_addr => updater_ip_addr, :tags => tags)
    end    
  end
  
  
  ### Parse Methods ###
  def self.scan_query(query)
    query.to_s.downcase.scan(/\S+/).uniq
  end
  
  def self.scan_tags(tags)
    tags.to_s.downcase.gsub(/[,;*]/, "_").scan(/\S+/).uniq
  end
  
  def self.parse_cast(object, type)
    case type
    when :integer
      object.to_i
      
    when :float
      object.to_f
      
    when :date
      begin
        object.to_date
      rescue Exception
        nil
      end
      
    when :filesize
      object =~ /^(\d+(?:\.\d*)?|\d*\.\d+)([kKmM]?)[bB]?$/

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
  
  def self.parse_helper(range, type = :integer)
    # "1", "0.5", "5.", ".5":
    # (-?(\d+(\.\d*)?|\d*\.\d+))
    case range
    when /^(.+?)\.\.(.+)/
      return [:between, parse_cast($1, type), parse_cast($2, type)]

    when /^<=(.+)/, /^\.\.(.+)/
      return [:lte, parse_cast($1, type)]

    when /^<(.+)/
      return [:lt, parse_cast($1, type)]

    when /^>=(.+)/, /^(.+)\.\.$/
      return [:gte, parse_cast($1, type)]

    when /^>(.+)/
      return [:gt, parse_cast($1, type)]

    else
      return [:eq, parse_cast(range, type)]

    end
  end
  
  def self.parse_query(query, options = {})
    q = Hash.new {|h, k| h[k] = []}

    scan_query(query).each do |token|
      if token =~ /^(sub|md5|-rating|rating|width|height|mpixels|score|filesize|source|id|date|order|change|status|tagcount|gentagcount|arttagcount|chartagcount|copytagcount):(.+)$/
        if $1 == "sub"
          q[:subscriptions] = $2
        elsif $1 == "md5"
          q[:md5] = $2
        elsif $1 == "-rating"
          q[:rating_negated] = $2
        elsif $1 == "rating"
          q[:rating] = $2
        elsif $1 == "id"
          q[:post_id] = parse_helper($2)
        elsif $1 == "width"
          q[:width] = parse_helper($2)
        elsif $1 == "height"
          q[:height] = parse_helper($2)
        elsif $1 == "mpixels"
          q[:mpixels] = parse_helper($2, :float)
        elsif $1 == "score"
          q[:score] = parse_helper($2)
    	  elsif $1 == "filesize"
    	    q[:filesize] = parse_helper($2, :filesize)
        elsif $1 == "source"
          q[:source] = $2.to_escaped_for_sql_like + "%"
        elsif $1 == "date"
          q[:date] = parse_helper($2, :date)
        elsif $1 == "tagcount"
          q[:tag_count] = parse_helper($2)
        elsif $1 == "gentagcount"
          q[:general_tag_count] = parse_helper($2)
        elsif $1 == "arttagcount"
          q[:artist_tag_count] = parse_helper($2)
        elsif $1 == "chartagcount"
          q[:character_tag_count] = parse_helper($2)
        elsif $1 == "copytagcount"
          q[:copyright_tag_count] = parse_helper($2)
        elsif $1 == "order"
          q[:order] = $2
        elsif $1 == "change"
          q[:change] = parse_helper($2)
        elsif $1 == "status"
          q[:status] = $2
        end
      elsif token[0] == "-" && token.size > 1
        q[:exclude] << token[1..-1]
      elsif token[0] == "~" && token.size > 1
        q[:include] << token[1..-1]
      elsif token.include?("*")
        matches = where(["name LIKE ? ESCAPE E'\\\\'", token.to_escaped_for_sql_like]).all(:select => "name", :limit => 25, :order => "post_count DESC").map(&:name)
        matches = ["~no_matches~"] if matches.empty?
        q[:include] += matches
      else
        q[:related] << token
      end
    end

    normalize_tags_in_query(q)

    return q
  end
  
  def self.normalize_tags_in_query(query_hash)
    query_hash[:exclude] = TagAlias.to_aliased(query_hash[:exclude], :strip_prefix => true) if query_hash.has_key?(:exclude)
    query_hash[:include] = TagAlias.to_aliased(query_hash[:include], :strip_prefix => true) if query_hash.has_key?(:include)
    query_hash[:related] = TagAlias.to_aliased(query_hash[:related]) if query_hash.has_key?(:related)
  end
end
