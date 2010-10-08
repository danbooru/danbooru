class PostSet
  class Error < Exception ; end
  
  attr_accessor :tags, :page, :before_id, :errors, :count
  attr_accessor :wiki_page, :artist, :posts, :suggestions
  
  def initialize(tags, page, before_id = nil)
    @tags = Tag.normalize(tags)
    @page = page.to_i
    @before_id = before_id
    @errors = []
    load_associations
    load_posts
    load_suggestions
    validate
  end
  
  def use_sequential_paginator?
    !use_numbered_paginator?
  end
  
  def use_numbered_paginator?
    before_id.nil?
  end
  
  def has_errors?
    errors.any?
  end
  
  def offset
    x = (page - 1) * limit
    if x < 0
      x = 0
    end
    x
  end
  
  def limit
    Danbooru.config.posts_per_page
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
  
  def load_posts
    @count = Post.fast_count(tags)
    @posts = Post.find_by_tags(tags, :before_id => before_id).all(:order => "posts.id desc", :limit => limit, :offset => offset)
  end
  
  def load_suggestions
    if count < limit && is_single_tag?
      @suggestions = Tag.find_suggestions(tags)
    else
      @suggestions = []
    end
  end
  
  def tag_array
    @tag_array ||= Tag.scan_query(tags)
  end
  
  def validate
    validate_page
    validate_query_count
  rescue Error => x
    @errors << x.to_s
  end
  
  def validate_page
    if page > 1_000
      raise Error.new("You cannot explicitly specify the page after page 1000")
    end
  end
  
  def validate_query_count
    if !CurrentUser.user.is_privileged? && tag_array.size > 2
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
  
  def presenter
    @presnter ||= PostSetPresenter.new(self)
  end
end
