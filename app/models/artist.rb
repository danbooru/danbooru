class Artist < ActiveRecord::Base
  before_create :initialize_creator
  before_save :normalize_name
  after_save :create_version
  after_save :save_url_string
  after_save :commit_ban
  validates_uniqueness_of :name
  belongs_to :creator, :class_name => "User"
  has_many :members, :class_name => "Artist", :foreign_key => "group_name", :primary_key => "name"
  has_many :urls, :dependent => :destroy, :class_name => "ArtistUrl"
  has_many :versions, :order => "artist_versions.id ASC", :class_name => "ArtistVersion"
  has_one :wiki_page, :foreign_key => "title", :primary_key => "name"
  has_one :tag_alias, :foreign_key => "antecedent_name", :primary_key => "name"
  accepts_nested_attributes_for :wiki_page
  attr_accessible :body, :name, :url_string, :other_names, :other_names_comma, :group_name, :wiki_page_attributes, :notes, :is_active, :as => [:member, :privileged, :platinum, :contributor, :janitor, :moderator, :default, :admin]
  attr_accessible :is_banned, :as => :admin
  
  module UrlMethods
    extend ActiveSupport::Concern
    
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
    extend ActiveSupport::Concern
    
    module ClassMethods
      def normalize_name(name)
        name.to_s.downcase.strip.gsub(/ /, '_')
      end
    end

    def normalize_name
      self.name = Artist.normalize_name(name)
    end
    
    def other_names_array
      other_names.try(:split, / /)
    end
    
    def other_names_comma
      other_names_array.try(:join, ", ")
    end
    
    def other_names_comma=(string)
      self.other_names = string.split(/,/).map {|x| Artist.normalize_name(x)}.join(" ")
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
  
  module BanMethods
    def commit_ban
      if is_banned? && is_banned_changed?
        ban!
      end
      
      true
    end
    
    def ban!
      Post.transaction do
        begin
          Post.tag_match(name).each do |post|
            begin
              post.flag!("Artist requested removal")
            rescue PostFlag::Error
              # swallow
            end
            post.delete!
          end
        rescue Post::SearchError
          # swallow
        end
        
        # potential race condition but unlikely
        unless TagImplication.where(:antecedent_name => name, :consequent_name => "banned_artist").exists?
          tag_implication = TagImplication.create(:antecedent_name => name, :consequent_name => "banned_artist")
          tag_implication.delay.process!
        end
        
        update_column(:is_active, false)
        update_column(:is_banned, true)
      end
    end
  end
  
  module SearchMethods
    def active
      where("is_active = true")
    end
      
    def banned
      where("is_banned = true")
    end

    def url_matches(string)
      matches = find_all_by_url(string).map(&:id)

      if matches.any?
        where("id in (?)", matches)
      else
        where("false")
      end
    end
    
    def other_names_match(string)
      where("other_names_index @@ to_tsquery('danbooru', ?)", Artist.normalize_name(string))
    end
    
    def group_name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      where("group_name LIKE ? ESCAPE E'\\\\'", stripped_name)
    end
    
    def name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      where("name LIKE ? ESCAPE E'\\\\'", stripped_name)
    end
    
    def any_name_matches(name)
      stripped_name = normalize_name(name).to_escaped_for_sql_like
      where("(name LIKE ? ESCAPE E'\\\\' OR other_names_index @@ to_tsquery('danbooru', ?))", stripped_name, normalize_name(name))
    end
    
    def search(params)
      q = active
      return q if params.blank?

      case params[:name]
      when /^http/
        q = q.url_matches(params[:name])

      when /name:(.+)/
        q = q.name_matches($1)
        
      when /other:(.+)/
        q = q.other_names_match($1)

      when /group:(.+)/
        q = q.group_name_matches($1)

      when /status:banned/
        q = q.banned

      when /./
        q = q.any_name_matches(params[:name])
      end

      if params[:id].present?
        q = q.where("id = ?", params[:id])
      end
      
      q
    end
  end
  
  include UrlMethods
  include NameMethods
  include GroupMethods
  include VersionMethods
  extend FactoryMethods
  include NoteMethods
  include TagMethods
  include BanMethods
  extend SearchMethods
  
  def status
    if is_banned?
      "Banned"
    elsif is_active?
      "Active"
    else
      "Deleted"
    end
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.user.id
  end
end
