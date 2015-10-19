require 'socket'

module Danbooru
  class Configuration
    # The version of this Danbooru.
    def version
      "2.94.0"
    end

    # The name of this Danbooru.
    def app_name
      if CurrentUser.safe_mode?
        "Safebooru"
      else
        "Danbooru"
      end
    end

    # The hostname of the server.
    def hostname
      Socket.gethostname
    end

    # Contact email address of the admin.
    def contact_email
      "webmaster@#{server_host}"
    end

    def upgrade_account_email
      contact_email
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

    # Set to true to give all new users gold access.
    def start_as_gold?
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

    # Large resize image width. Set to nil to disable.
    def large_image_width
      850
    end

    def large_image_prefix
      "sample-"
    end

    # When calculating statistics based on the posts table, gather this many posts to sample from.
    def post_sample_size
      300
    end

    # Where the ad banners are stored in the file system
    def advertisement_path
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
      !user.is_gold?
    end

    # Users cannot search for more than X regular tags at a time.
    def base_tag_query_limit
      6
    end

    def tag_query_limit
      if CurrentUser.user.present?
        CurrentUser.user.tag_query_limit
      else
        base_tag_query_limit * 2
      end
    end

    # Max number of posts to cache
    def tag_subscription_post_limit
      200
    end

    # After this many pages, the paginator will switch to sequential mode.
    def max_numbered_pages
      1_000
    end

    # Max number of tag subscriptions per user
    def max_tag_subscriptions
      5
    end

    # Maximum size of an upload.
    def max_file_size
      30.megabytes
    end

    def member_comment_time_threshold
      1.week.ago
    end

    # The name of the server the app is hosted on.
    def server_host
      Socket.gethostname
    end

    # Names of all Danbooru servers which serve out of the same common database.
    # Used in conjunction with load balancing to distribute files from one server to
    # the others. This should match whatever gethostname returns on the other servers.
    def all_server_hosts
      [server_host]
    end

    # Names of other Danbooru servers.
    def other_server_hosts
      @other_server_hosts ||= all_server_hosts.reject {|x| x == server_host}
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
        "Copyright" => 3,
        "Character" => 4
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
      !user.is_gold?
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
      posts.select {|x| can_user_see_post?(user, x)}
    end

    def max_appeals_per_day
      1
    end

    # Counting every post is typically expensive because it involves a sequential scan on
    # potentially millions of rows. If this method returns a value, then blank searches
    # will return that number for the fast_count call instead.
    def blank_tag_search_fast_count
      nil
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

    def nijie_login
      nil
    end

    def nijie_password
      nil
    end

    def amazon_ses
      # {:smtp_server_name => "smtp server", :user_name => "user name", :ses_smtp_user_name => "smtp user name", :ses_smtp_password => "smtp password"}
      nil
    end

    def amazon_s3_bucket_name
      "danbooru"
    end

    def enable_dimension_autotagging
      true
    end

    def iqdb_hostname_and_port
      # ["localhost", 4000]
      nil
    end

    def iqdb_file
      # /var/www/danbooru2/shared/iqdb.db
      nil
    end

    def shared_dir_path
      "/var/www/danbooru2/shared"
    end

    def coinbase_secret
    end

    def coinbase_api_key
    end

    def coinbase_api_secret
    end

    def stripe_secret_key
    end
    
    def stripe_publishable_key
    end

    def twitter_api_key
    end

    def twitter_api_secret
    end

    def shared_remote_key
      "blah blah blah blah blah blah"
    end

    def report_server
      "https://isshiki.donmai.us"
    end

    def enable_post_search_counts
      false
    end

    def email_key
      "zDMSATq0W3hmA5p3rKTgD"
    end

    # For downloads, if the host matches any of these IPs, block it
    def banned_ip_for_download?(ip_addr)
      raise ArgumentError unless ip_addr.is_a?(IPAddr)

      if ip_addr.ipv4?
        if IPAddr.new("127.0.0.1") == ip_addr
          true
        elsif IPAddr.new("169.254.0.0/16").include?(ip_addr)
          true
        elsif IPAddr.new("10.0.0.0/8").include?(ip_addr)
          true
        elsif IPAddr.new("172.16.0.0/12").include?(ip_addr)
          true
        elsif IPAddr.new("192.168.0.0/16").include?(ip_addr)
          true
        else
          false
        end
      elsif ip_addr.ipv6?
        if IPAddr.new("::1") == ip_addr
          true
        elsif IPAddr.new("fe80::/10").include?(ip_addr)
          true
        elsif IPAddr.new("fd00::/8").include?(ip_addr)
          true
        else
          false
        end
      else
        false
      end
    end

    def twitter_site
      "@teruyo"
    end

    def addthis_key
      nil
    end
  end
end
