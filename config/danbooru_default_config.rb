module Danbooru
  class Configuration
    # A secret key used to encrypt session cookies, among other things. If this
    # token is changed, existing login sessions will become invalid. If this
    # token is stolen, attackers will be able to forge session cookies and
    # login as any user.
    #
    # Must be specified. Use `rake secret` to generate a random secret token.
    def secret_key_base
      ENV["SECRET_TOKEN"].presence || File.read(File.expand_path("~/.danbooru/secret_token"))
    end

    # The name of this Danbooru.
    def app_name
      if CurrentUser.safe_mode?
        "Safebooru"
      else
        "Danbooru"
      end
    end

    def canonical_app_name
      "Danbooru"
    end

    # The canonical hostname for the site, e.g. danbooru.donmai.us.
    def hostname
      Socket.gethostname
    end

    # The canonical url for the site (e.g. https://danbooru.donmai.us)
    def canonical_url
      "https://#{hostname}"
    end

    # Contact email address of the admin.
    def contact_email
      "webmaster@#{hostname}"
    end

    # System actions, such as sending automated dmails, will be performed with
    # this account. This account must have Moderator privileges.
    #
    # Run `rake db:seed` to create this account if it doesn't already exist in your install.
    def system_user
      "DanbooruBot"
    end

    def source_code_url
      "https://github.com/danbooru/danbooru"
    end

    def issues_url
      "#{source_code_url}/issues"
    end

    # An array of regexes containing disallowed usernames.
    def user_name_blacklist
      []
    end

    # Thumbnail size
    def small_image_width
      150
    end

    # Large resize image width. Set to nil to disable.
    def large_image_width
      850
    end

    # After a post receives this many comments, new comments will no longer bump the post in comment/index.
    def comment_threshold
      40
    end

    # Members cannot post more than X comments in an hour.
    def member_comment_limit
      2
    end

    # Users cannot search for more than X regular tags at a time.
    def base_tag_query_limit
      6
    end

    # After this many pages, the paginator will switch to sequential mode.
    def max_numbered_pages
      1_000
    end

    # Maximum size of an upload. If you change this, you must also change
    # `client_max_body_size` in your nginx.conf.
    def max_file_size
      50.megabytes
    end

    # Maximum resolution (width * height) of an upload. Default: 441 megapixels (21000x21000 pixels).
    def max_image_resolution
      21000 * 21000
    end

    # Maximum width of an upload.
    def max_image_width
      40000
    end

    # Maximum height of an upload.
    def max_image_height
      40000
    end

    # How long pending posts stay in the modqueue before being deleted.
    def moderation_period
      3.days
    end

    # https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
    # https://guides.rubyonrails.org/configuring.html#configuring-action-mailer
    def mail_delivery_method
      # :smtp
      :sendmail
    end

    def mail_settings
      {
        # address: "example.com",
        # user_name: "user",
        # password: "pass",
        # authentication: :login
      }
    end

    # The method to use for storing image files.
    def storage_manager
      # Store files on the local filesystem.
      # base_dir - where to store files (default: under public/data)
      # base_url - where to serve files from (default: http://#{hostname}/data)
      # hierarchical: false - store files in a single directory
      # hierarchical: true - store files in a hierarchical directory structure, based on the MD5 hash
      StorageManager::Local.new(base_url: "#{CurrentUser.root_url}/data", base_dir: Rails.root.join("public/data"), hierarchical: false)

      # Store files on one or more remote host(s). Configure SSH settings in
      # ~/.ssh_config or in the ssh_options param (ref: http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start)
      # StorageManager::SFTP.new("i1.example.com", "i2.example.com", base_dir: "/mnt/backup", hierarchical: false, ssh_options: {})

      # Select the storage method based on the post's id and type (preview, large, or original).
      # StorageManager::Hybrid.new do |id, md5, file_ext, type|
      #   ssh_options = { user: "danbooru" }
      #
      #   if type.in?([:large, :original]) && id.in?(0..850_000)
      #     StorageManager::SFTP.new("raikou1.donmai.us", base_url: "https://raikou1.donmai.us", base_dir: "/path/to/files", hierarchical: true, ssh_options: ssh_options)
      #   elsif type.in?([:large, :original]) && id.in?(850_001..2_000_000)
      #     StorageManager::SFTP.new("raikou2.donmai.us", base_url: "https://raikou2.donmai.us", base_dir: "/path/to/files", hierarchical: true, ssh_options: ssh_options)
      #   elsif type.in?([:large, :original]) && id.in?(2_000_001..3_000_000)
      #     StorageManager::SFTP.new(*all_server_hosts, base_url: "https://hijiribe.donmai.us/data", ssh_options: ssh_options)
      #   else
      #     StorageManager::SFTP.new(*all_server_hosts, ssh_options: ssh_options)
      #   end
      # end
    end

    # The method to use for backing up image files.
    def backup_storage_manager
      # Don't perform any backups.
      StorageManager::Null.new

      # Backup files to /mnt/backup on the local filesystem.
      # StorageManager::Local.new(base_dir: "/mnt/backup", hierarchical: false)

      # Backup files to /mnt/backup on a remote system. Configure SSH settings
      # in ~/.ssh_config or in the ssh_options param (ref: http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start)
      # StorageManager::SFTP.new("www.example.com", base_dir: "/mnt/backup", ssh_options: {})
    end

    # TAG CONFIGURATION

    # Full tag configuration info for all tags
    def full_tag_config_info
      @full_tag_category_mapping ||= {
        "general" => {
          "category" => 0,
          "short" => "gen",
          "extra" => [],
          "relatedbutton" => "General",
          "css" => {
            "color" => "var(--general-tag-color)",
            "hover" => "var(--general-tag-hover-color)"
          }
        },
        "character" => {
          "category" => 4,
          "short" => "char",
          "extra" => ["ch"],
          "relatedbutton" => "Characters",
          "css" => {
            "color" => "var(--character-tag-color)",
            "hover" => "var(--character-tag-hover-color)"
          }
        },
        "copyright" => {
          "category" => 3,
          "short" => "copy",
          "extra" => ["co"],
          "relatedbutton" => "Copyrights",
          "css" => {
            "color" => "var(--copyright-tag-color)",
            "hover" => "var(--copyright-tag-hover-color)"
          }
        },
        "artist" => {
          "category" => 1,
          "short" => "art",
          "extra" => [],
          "relatedbutton" => "Artists",
          "css" => {
            "color" => "var(--artist-tag-color)",
            "hover" => "var(--artist-tag-hover-color)"
          }
        },
        "meta" => {
          "category" => 5,
          "short" => "meta",
          "extra" => [],
          "relatedbutton" => nil,
          "css" => {
            "color" => "var(--meta-tag-color)",
            "hover" => "var(--meta-tag-hover-color)"
          }
        }
      }
    end

    # TAG ORDERS

    # Sets the order of the split tag header list (presenters/tag_set_presenter.rb)
    def split_tag_header_list
      @split_tag_header_list ||= ["artist", "copyright", "character", "general", "meta"]
    end

    # Sets the order of the categorized tag string (presenters/post_presenter.rb)
    def categorized_tag_list
      @categorized_tag_list ||= ["artist", "copyright", "character", "meta", "general"]
    end

    # Sets the order of the related tag buttons (javascripts/related_tag.js)
    def related_tag_button_list
      @related_tag_button_list ||= ["general", "artist", "character", "copyright"]
    end

    # END TAG

    # Any custom code you want to insert into the default layout without
    # having to modify the templates.
    def custom_html_header_content
      nil
    end

    # The number of posts displayed per page.
    def posts_per_page
      20
    end

    # Tags that are not visible in safe mode.
    def safe_mode_restricted_tags
      restricted_tags + %w[censored condom nipples nude penis pussy sexually_suggestive]
    end

    # Tags that are only visible to Gold+ users.
    def restricted_tags
      []
    end

    def pixiv_login
      nil
    end

    def pixiv_password
      nil
    end

    def nico_seiga_login
      nil
    end

    def nico_seiga_password
      nil
    end

    def nijie_login
      nil
    end

    def nijie_password
      nil
    end

    # Register at https://www.deviantart.com/developers/
    def deviantart_client_id
      nil
    end

    def deviantart_client_secret
      nil
    end

    # http://tinysubversions.com/notes/mastodon-bot/
    def pawoo_client_id
      nil
    end

    def pawoo_client_secret
      nil
    end

    # 1. Register app at https://www.tumblr.com/oauth/register.
    # 2. Copy "OAuth Consumer Key" from https://www.tumblr.com/oauth/apps.
    def tumblr_consumer_key
      nil
    end

    # A list of tags that should be removed when a post is replaced. Regexes allowed.
    def post_replacement_tag_removals
      %w[replaceme .*_sample resized upscaled downscaled md5_mismatch
      jpeg_artifacts corrupted_image missing_image missing_sample missing_thumbnail
      resolution_mismatch source_larger source_smaller source_request non-web_source]
    end

    # Posts with these tags will be highlighted in the modqueue.
    def modqueue_warning_tags
      %w[hard_translated self_upload nude_filter third-party_edit screencap
      duplicate image_sample md5_mismatch resized upscaled downscaled
      resolution_mismatch source_larger source_smaller]
    end

    def stripe_secret_key
    end

    def stripe_publishable_key
    end

    def twitter_api_key
    end

    def twitter_api_secret
    end

    # you should override this
    def email_key
      "zDMSATq0W3hmA5p3rKTgD"
    end

    # The url of the Discord server associated with this site.
    def discord_server_url
      nil
    end

    # The twitter username associated with this site (username only, don't include the @-sign).
    def twitter_username
      nil
    end

    def twitter_url
      return nil unless Danbooru.config.twitter_username.present?
      "https://twitter.com/#{Danbooru.config.twitter_username}"
    end

    # include essential tags in image urls (requires nginx/apache rewrites)
    def enable_seo_post_urls
      false
    end

    # The URL for the Reportbooru server (https://github.com/evazion/reportbooru).
    # Optional. Used for tracking post views, popular searches, and missed searches.
    # Set to http://localhost/mock/reportbooru to enable a fake reportbooru
    # server for development purposes.
    def reportbooru_server
    end

    def reportbooru_key
    end

    # The URL for the IQDBs server (https://github.com/evazion/iqdbs).
    # Optional. Used for dupe detection and reverse image searches.
    # Set to http://localhost/mock/iqdbs to enable a fake iqdb server for
    # development purposes.
    def iqdbs_server
    end

    def aws_credentials
      Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    end

    def aws_access_key_id
    end

    def aws_secret_access_key
    end

    def aws_sqs_region
    end

    def aws_sqs_iqdb_url
    end

    def aws_sqs_archives_url
    end

    # Use a recaptcha on the signup page to protect against spambots creating new accounts.
    # https://developers.google.com/recaptcha/intro
    def enable_recaptcha?
      Rails.env.production? && Danbooru.config.recaptcha_site_key.present? && Danbooru.config.recaptcha_secret_key.present?
    end

    def recaptcha_site_key
    end

    def recaptcha_secret_key
    end

    # Akismet API key. Used for Dmail spam detection. http://akismet.com/signup/
    def rakismet_key
    end

    def rakismet_url
      "https://#{hostname}"
    end

    # API key for https://ipregistry.co. Used for looking up IP address
    # information and for detecting proxies during signup.
    def ip_registry_api_key
      nil
    end

    # The whitelist of email domains allowed for account verification purposes.
    # If a user signs up from a proxy, they must verify their account using an
    # email address from one of the domains on this list before they can do
    # anything on the site. This is meant to prevent users from using
    # disposable emails to create sockpuppet accounts.
    #
    # If this list is empty or nil, then there are no restrictions on which
    # email domains can be used to verify accounts.
    def email_domain_verification_list
      # ["gmail.com", "outlook.com", "yahoo.com"]
      []
    end

    # API key for Google Maps. Used for embedding maps on IP address lookup pages.
    # Generate at https://console.developers.google.com/apis/credentials
    def google_maps_api_key
      nil
    end

    # Cloudflare API token. Used to purge URLs from Cloudflare's cache when a
    # post is replaced. The token must have 'zone.cache_purge' permissions.
    # https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys
    def cloudflare_api_token
    end

    # The Cloudflare zone ID. This is the domain that cached URLs will be purged from.
    def cloudflare_zone
    end

    # The URL for the recommender server (https://github.com/evazion/recommender).
    # Optional. Used to generate post recommendations.
    # Set to http://localhost/mock/recommender to enable a fake recommender
    # server for development purposes.
    def recommender_server
    end

    def redis_url
      "redis://localhost:6379"
    end
  end

  EnvironmentConfiguration = Struct.new(:config) do
    def method_missing(method, *args)
      var = ENV["DANBOORU_#{method.to_s.upcase.chomp("?")}"]

      var.presence || config.send(method, *args)
    end
  end
end
