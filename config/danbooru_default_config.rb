require 'socket'

module Danbooru
  class Configuration
    # The version of this Danbooru.
    def version
      "2.0.0"
    end
    
    # The name of this Danbooru.
    def app_name
      "Danbooru"
    end
    
    # The hostname of the server.
    def hostname
      Socket.gethostname
    end
    
    # Contact email address of the admin.
    def contact_email
      "webmaster@#{server_host}"
    end
    
    # Stripped of any special characters.
    def safe_app_name
      app_name.gsub(/[^a-zA-Z0-9_-]/, "_")
    end
    
    # The default name to use for anyone who isn't logged in.
    def default_guest_name
      "Anonymous"
    end
    
    # This is a salt used to make dictionary attacks on account passwords harder.
    def password_salt
      "choujin-steiner"
    end
    
    # Set to true to allow new account signups.
    def enable_signups?
      true
    end
    
    # Set to true to give all new users privileged access.
    def start_as_privileged?
      false
    end
    
    # Set to true to give all new users contributor access.
    def start_as_contributor?
      false
    end
    
    # What method to use to store images.
    # local_flat: Store every image in one directory.
    # local_hierarchy: Store every image in a hierarchical directory, based on the post's MD5 hash. On some file systems this may be faster.
    def image_store
      :local_flat
    end
    
    # Thumbnail size
    def small_image_width
      150
    end
    
    # Medium resize image width. Set to nil to disable.
    def medium_image_width
      480
    end
    
    # Large resize image width. Set to nil to disable.
    def large_image_width
      960
    end
    
    # When calculating statistics based on the posts table, gather this many posts to sample from.
    def post_sample_size
      300
    end
    
    # If a solid state drive is availble, cache the thumbnails on the SSD to reduce disk seek times.
    def ssd_path
      nil
    end
    
    # List of memcached servers
    def memcached_servers
      %w(localhost:11211)
    end
    
    # After a post receives this many comments, new comments will no longer bump the post in comment/index.
    def comment_threshold
      40
    end
    
    # Members cannot post more than X comments in an hour.
    def member_comment_limit
      2
    end

    # Determines who can see ads.
    def can_see_ads?(user)
      false
    end
    
    # This is required for Rails 2.0.
    def session_secret_key
      "This should be at least 30 characters long"
    end
    
    # Users cannot search for more than X regular tags at a time.
    def tag_query_limit
      6
    end
    
    # Max number of posts to cache
    def tag_subscription_post_limit
      200
    end
    
    # After this many pages, the paginator will switch to sequential mode.
    def max_numbered_pages
      10
    end
    
    # Max number of tag subscriptions per user
    def max_tag_subscriptions
      5
    end
    
    # Maximum size of an upload.
    def max_file_size
      5.megabytes
    end
    
    # The name of the server the app is hosted on.
    def server_host
      Socket.gethostname
    end
    
    # Names of all Danbooru servers which serve out of the same common database.
    # Used in conjunction with load balancing to distribute files from one server to
    # the others. This should match whatever gethostname returns on the other servers.
    def all_server_hosts
      []
    end
    
    # Names of other Danbooru servers.
    def other_server_hosts
      all_server_hosts.reject {|x| x == server_host}
    end

    def remote_server_login
      "albert"
    end
    
    # Returns a hash mapping various tag categories to a numerical value.
    # Be sure to update the reverse_tag_category_mapping also.
    def tag_category_mapping
      @tag_category_mapping ||= {
        "general" => 0,
        "gen" => 0,

        "artist" => 1,
        "art" => 1,

        "copyright" => 3,
        "copy" => 3,
        "co" => 3,

        "character" => 4,
        "char" => 4,
        "ch" => 4
      }
    end
    
    def canonical_tag_category_mapping
      @canonical_tag_category_mapping ||= {
        "General" => 0,
        "Artist" => 1,
        "Copyright" => 2,
        "Character" => 3
      }
    end
    
    # Returns a hash maping numerical category values to their
    # string equivalent. Be sure to update the tag_category_mapping also.
    def reverse_tag_category_mapping
      @reverse_tag_category_mapping ||= {
        0 => "General",
        1 => "Artist",
        3 => "Copyright",
        4 => "Character"
      }
    end
    
    # If enabled, users must verify their email addresses.
    def enable_email_verification?
      false
    end
    
    # Any custom code you want to insert into the default layout without
    # having to modify the templates.
    def custom_html_header_content
      nil
    end
    
    # The number of posts displayed per page.
    def posts_per_page
      20
    end

    def is_post_restricted?(post)
      false
    end
    
    def is_user_restricted?(user)
      !user.is_privileged?
    end
    
    def is_user_advertiser?(user)
      user.is_admin?
    end
    
    def can_user_see_post?(user, post)
      if is_user_restricted?(user) && is_post_restricted?(post)
        false
      else
        true
      end
    end
    
    def select_posts_visible_to_user(user, posts)
      posts.select {|x| can_user_see_post?(x)}
    end
    
    def pixiv_login
      nil
    end
    
    def pixiv_password
      nil
    end
    
    def tinami_login
      nil
    end
    
    def tinami_password
      nil
    end
    
    def nico_seiga_login
      nil
    end
    
    def nico_seiga_password
      nil
    end
    
    def pixa_login
      nil
    end
    
    def pixa_password
      nil
    end
  end
end
