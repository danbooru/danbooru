class PostSet
  class Error < Exception ; end
  
  attr_accessor :tags, :page, :current_user, :before_id, :errors
  attr_accessor :wiki_page, :artist, :posts, :suggestions
  
  def initialize(tags, page, current_user, before_id = nil)
    @tags = Tag.normalize(tags)
    @page = page.to_i
    @current_user = current_user
    @before_id = before_id
    @errors = []
    load_associations
    load_paginator
    validate
  end
  
  def has_errors?
    errors.any?
  end
  
  def offset
    x = (page - 1) * 20
    if x < 0
      x = 0
    end
    x
  end
  
  def limit
    20
  end
  
  def is_single_tag?
    tag_array.size == 1
  end
  
  def load_associations
    if is_single_tag?
      @wiki_page = WikiPage.find_by_title(tags)
      @artist = Artist.find_by_name(tags)
    end
  end
  
  def load_paginator
    if before_id
      load_sequential_paginator
    else
      load_paginated_paginator
    end
  end
  
  def load_paginated_paginator
    @posts = Post.find_by_tags(tags, :before_id => before_id).all(:order => "posts.id desc", :limit => limit, :offset => offset)
  end
  
  def load_sequential_paginator
    count = Post.fast_count(tags)
    @posts = WillPaginate::Collection.create(page, limit, count) do |pager|
      pager.replace(Post.find_by_sql(tags).all(:order => "posts.id desc", :limit => pager.per_page, :offset => pager.offset))
    end
    load_suggestions(count)
  end
  
  def load_suggestions(count)
    @suggestions = Tag.find_suggestions(tags) if count < 20 && is_single_tag?
  end
  
  def tag_array
    @tag_arary ||= Tag.scan_query(tags)
  end
  
  def validate
    begin
      validate_page
      validate_query_count
    rescue Error => x
      @errors << x.to_s
    end
  end
  
  def validate_page
    if page > 1_000
      raise Error.new("You cannot explicitly specify the page after page 1000")
    end
  end
  
  def validate_query_count
    if !current_user.is_privileged? && tag_array.size > 2
      raise Error.new("You can only search up to two tags at once with a basic account")
    end
    
    if tag_array.size > 6
      raise Error.new("You can only search up to six tags at once")
    end
  end
  
  def to_xml
    posts.to_xml
  end
  
  def to_json
    posts.to_json
  end
end
