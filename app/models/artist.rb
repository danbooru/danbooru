class Artist < ActiveRecord::Base
  before_create :initialize_creator
  before_save :normalize_name
  after_save :create_version
  after_save :save_url_string
  validates_uniqueness_of :name
  belongs_to :creator, :class_name => "User"
  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, :dependent => :destroy, :class_name => "ArtistUrl"
  has_many :versions, :order => "artist_versions.id ASC", :class_name => "ArtistVersion"
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  accepts_nested_attributes_for :wiki_page
  attr_accessible :name, :url_string, :other_names, :group_name, :wiki_page_attributes, :notes
  scope :url_match, lambda {|string| where(["id in (?)", Artist.find_all_by_url(string).map(&:id)])}
  scope :other_names_match, lambda {|string| where(["other_names_index @@ to_tsquery('danbooru', ?)", Artist.normalize_name(string)])}
  scope :name_equals, lambda {|string| where("name = ?", string)}
  search_methods :url_match, :other_names_match
  
  module UrlMethods
    module ClassMethods
      def find_all_by_url(url)
        url = ArtistUrl.normalize(url)
        artists = []

        while artists.empty? && url.size > 10
          u = url.sub(/\/+$/, "") + "/"
          u = u.to_escaped_for_sql_like.gsub(/\*/, '%') + '%'
          artists += Artist.joins(:urls).where(["artists.is_active = TRUE AND artist_urls.normalized_url LIKE ? ESCAPE E'\\\\'", u]).all(:order => "artists.name")
          url = File.dirname(url) + "/"
        end

        artists.uniq_by {|x| x.name}.slice(0, 20)
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
    end

    def save_url_string
      if @url_string
        urls.clear

        @url_string.scan(/\S+/).each do |url|
          urls.create(:url => url)
        end
      end
    end
    
    def url_string=(string)
      @url_string = string
    end
    
    def url_string
      @url_string || urls.map {|x| x.url}.join("\n")
    end
  end

  module NameMethods
    module ClassMethods
      def normalize_name(name)
        name.to_s.downcase.strip.gsub(/ /, '_')
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
    end

    def normalize_name
      self.name = Artist.normalize_name(name)
      if other_names
        self.other_names = other_names.split(/,/).map {|x| Artist.normalize_name(x)}.join(" ")
      end
    end
  end
  
  module GroupMethods
    def member_names
      members.map(&:name).join(", ")
    end
  end
  
  module VersionMethods
    def create_version
      ArtistVersion.create(
        :artist_id => id,
        :name => name,
        :updater_id => CurrentUser.user.id,
        :updater_ip_addr => CurrentUser.ip_addr,
        :url_string => url_string,
        :is_active => is_active,
        :other_names => other_names,
        :group_name => group_name
      )
    end
    
    def revert_to!(version)
      self.name = version.name
      self.url_string = version.url_string
      self.is_active = version.is_active
      self.other_names = version.other_names
      self.group_name = version.group_name
      save      
    end
  end

  module FactoryMethods
    def new_with_defaults(params)
      Artist.new.tap do |artist|
        if params[:name]
          artist.name = params[:name]
          post = Post.tag_match("source:http* #{artist.name}").first
          unless post.nil? || post.source.blank?
            artist.url_string = post.source
          end
        end
        
        if params[:other_names]
          artist.other_names = params[:other_names]
        end
        
        if params[:urls]
          artist.url_string = params[:urls]
        end
      end
    end
  end

  module NoteMethods
    def notes
      if wiki_page
        wiki_page.body
      else
        nil
      end
    end
    
    def notes=(msg)
      if wiki_page
        wiki_page.title = name
        wiki_page.body = msg
        wiki_page.save
      else
        self.wiki_page = WikiPage.new(:title => name, :body => msg)
      end
    end
  end
  
  module TagMethods
    def has_tag_alias?
      TagAlias.exists?(["antecedent_name = ?", name])
    end

    def tag_alias_name
      TagAlias.find_by_antecedent_name(name).consequent_name
    end
  end
  
  include UrlMethods
  include NameMethods
  include GroupMethods
  include VersionMethods
  extend FactoryMethods
  include NoteMethods
  include TagMethods
  
  def ban!
    
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.user.id
  end
end

