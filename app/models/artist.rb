class Artist < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  before_create :initialize_creator
  before_save :normalize_name
  after_save :create_version
  after_save :commit_url_string
  validates_uniqueness_of :name
  validates_presence_of :updater_id, :updater_ip_addr
  belongs_to :updater, :class_name => "User"
  belongs_to :creator, :class_name => "User"
  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :artist_urls, :dependent => :destroy
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  accepts_nested_attributes_for :wiki_page
  attr_accessible :name, :url_string, :other_names, :group_name, :wiki_page_attributes, :updater_id, :updater_ip_addr
  
  module UrlMethods
    module ClassMethods
      def find_all_by_url(url)
        url = ArtistUrl.normalize(url)
        artists = []

        while artists.empty? && url.size > 10
          u = url.sub(/\/+$/, "") + "/"
          u = u.to_escaped_for_sql_like.gsub(/\*/, '%') + '%'
          artists += Artist.joins(:artist_urls).where(["artists.is_active = TRUE AND artist_urls.normalized_url LIKE ? ESCAPE E'\\\\'", u]).all(:order => "artists.name")
          url = File.dirname(url) + "/"
        end

        artists.uniq_by {|x| x.name}.slice(0, 20)
      end
    end
    
    def self.included(m)
      m.extend(ClassMethods)
    end

    def commit_url_string
      if @url_string
        artist_urls.clear

        @url_string.scan(/\S+/).each do |url|
          artist_urls.create(:url => url)
        end
      end
    end
    
    def url_string=(string)
      @url_string = string
    end
    
    def url_string
      @url_string || artist_urls.map {|x| x.url}.join("\n")
    end
  end

  module NameMethods
    module ClassMethods
      def normalize_name(name)
        name.downcase.strip.gsub(/ /, '_')
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
  
  module UpdaterMethods
    def updater_name
      User.find_name(updater_id).tr("_", " ")
    end
  end
  
  module SearchMethods
    def find_by_any_name(name)
      build_relation(:name => name).first
    end

    def build_relation(params)
      relation = Artist.where("is_active = TRUE")
      
      case params[:name]
      when /^http/
        relation = relation.where("id IN (?)", find_all_by_url(params[:name]).map(&:id))
        
      when /name:(.+)/
        escaped_name = Artist.normalize_name($1).to_escaped_for_sql_like
        relation = relation.where(["name LIKE ? ESCAPE E'\\\\'", escaped_name])
        
      when /other:(.+)/
        escaped_name = Artist.normalize_name($1)
        relation = relation.where(["other_names_index @@ to_tsquery('danbooru', ?)", escaped_name])
        
      when /group:(.+)/
        escaped_name = Artist.normalize_name($1).to_escaped_for_sql_like
        relation = relation.where(["group_name LIKE ? ESCAPE E'\\\\'", escaped_name])
        
      when /./
        normalized_name = Artist.normalize_name($1)
        escaped_name = normalized_name.to_escaped_for_sql_like
        relation = relation.where(["name LIKE ? ESCAPE E'\\\\' OR other_names_index @@ to_tsquery('danbooru', ?) OR group_name LIKE ? ESCAPE E'\\\\'", escaped_name, normalized_name, escaped_name])
      end

      if params[:id]
        relation = relation.where(["id = ?", params[:id]])
      end

      relation
    end
  end
  
  module VersionMethods
    def create_version
      ArtistVersion.create(
        :artist_id => id,
        :name => name,
        :updater_id => updater_id,
        :updater_ip_addr => updater_ip_addr,
        :url_string => url_string,
        :is_active => is_active,
        :other_names => other_names,
        :group_name => group_name
      )
    end
    
    def revert_to!(version, reverter_id, reverter_ip_addr)
      self.name = version.name
      self.url_string = version.url_string
      self.is_active = version.is_active
      self.other_names = version.other_names
      self.group_name = version.group_name
      self.updater_id = reverter_id
      self.updater_ip_addr = reverter_ip_addr
      save      
    end
  end

  include UrlMethods
  include NameMethods
  include GroupMethods
  include UpdaterMethods
  extend SearchMethods  
  include VersionMethods
  
  def initialize_creator
    if creator.nil?
      self.creator_id = updater_id
    end
  end
end

