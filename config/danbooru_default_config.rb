# This file contains all the configuration settings for Danbooru.
#
# Don't edit this file. Instead, to configure your Danbooru instance, copy this
# file to config/danbooru_local_config.rb and edit that. Remove all settings you
# don't need to change, and edit only the settings you do need to change.
#
# You can also use environment variables to change settings on the command line.
# For example, to change the site name, you could do:
#
#     DANBOORU_APP_NAME=MyBooru bin/rails server
#
# This works with nearly any setting. Just take the setting name, uppercase it,
# and add DANBOORU_ to the front. More examples:
#
#     DANBOORU_CANONICAL_URL=https://booru.example.com
#     DANBOORU_CONTACT_EMAIL=admin@borou.example.com
#     DANBOORU_DISCORD_SERVER_URL=https://discord.gg/yourbooru
#
# Settings from environment variables will override those from the config file.
#
# You can also set these environment variables in an envfile instead of the
# command line. See the .env file in the root project directory for details.
#
module Danbooru
  class Configuration
    # A secret key used to encrypt session cookies, among other things.
    #
    # If this key is changed, existing login sessions will become invalid and
    # all users will be logged out.
    #
    # If this key is stolen, attackers will be able to forge session cookies
    # and login as any user.
    #
    # Must be specified. If this is not specified, then a new secret key will
    # generated every time the server starts, which will log out all users on
    # every restart.
    #
    # Use `rake secret` to generate a random secret key.
    def secret_key_base
      SecureRandom.uuid
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

    # The public domain name of your site, e.g. "danbooru.donmai.us". If your
    # site were called `www.mybooru.com`, then you would set this to "www.mybooru.com"
    #
    # By default, this is set to the machine hostname. You can use `hostnamectl`
    # to change the machine hostname.
    #
    # You can set this to "localhost" if your site doesn't have a public domain name.
    def hostname
      Socket.gethostname
    end

    # The URL of your site, e.g. https://danbooru.donmai.us.
    #
    # If you support HTTPS, change this to "https://www.mybooru.com". If you set
    # this to https://, then you *must* use https:// to access your site. You can't
    # use http:// because in HTTPS mode session cookies won't be sent over HTTP.
    #
    # Images will be served from this URL by default. See the `base_url` option
    # for the `storage_manager` below if you want to serve images from a
    # different domain.
    #
    # Protip: use ngrok.com for easy HTTPS support during development.
    def canonical_url
      "http://#{Danbooru.config.hostname}"
    end

    # Contact email address of the admin.
    def contact_email
      "webmaster@#{Danbooru.config.hostname}"
    end

    # System actions, such as sending automated dmails, will be performed with
    # this account. This account must have Moderator privileges.
    #
    # Run `rake db:seed` to create this account if it doesn't already exist in your install.
    def system_user
      "DanbooruBot"
    end

    # The name of the cookie that stores the current user's login session.
    # Changing this will force all users to login again.
    def session_cookie_name
      "_danbooru2_session"
    end

    # Debug mode does some things to make testing easier. It disables parallel
    # testing and it replaces Danbooru's custom exception page with the default
    # Rails exception page. This is only useful during development and testing.
    #
    # Usage: `DANBOORU_DEBUG_MODE=true bin/rails test
    def debug_mode
      false
    end

    def source_code_url
      "https://github.com/danbooru/danbooru"
    end

    def issues_url
      "#{source_code_url}/issues"
    end

    # If true, new accounts will require email verification if they seem
    # suspicious (they were created using a proxy, multiple accounts were
    # created by the same IP, etc).
    #
    # This doesn't apply to personal or development installs running on
    # localhost or the local network.
    #
    # Disable this if you're running a public booru and you don't want email
    # verification for new accounts.
    def new_user_verification?
      true
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
      # base_url - where to serve files from (default: https://#{hostname}/data)
      StorageManager::Local.new(base_url: "#{Danbooru.config.canonical_url}/data", base_dir: Rails.root.join("public/data"))

      # Store files on one or more remote host(s). Configure SSH settings in
      # ~/.ssh_config or in the ssh_options param (ref: http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start)
      # StorageManager::SFTP.new("i1.example.com", "i2.example.com", base_dir: "/mnt/backup", ssh_options: {})

      # Select the storage method based on the post's id and type (preview, large, or original).
      # StorageManager::Hybrid.new do |id, md5, file_ext, type|
      #   ssh_options = { user: "danbooru" }
      #
      #   if type.in?([:large, :original]) && id.in?(0..850_000)
      #     StorageManager::SFTP.new("raikou1.donmai.us", base_url: "https://raikou1.donmai.us", base_dir: "/path/to/files", ssh_options: ssh_options)
      #   elsif type.in?([:large, :original]) && id.in?(850_001..2_000_000)
      #     StorageManager::SFTP.new("raikou2.donmai.us", base_url: "https://raikou2.donmai.us", base_dir: "/path/to/files", ssh_options: ssh_options)
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
      # StorageManager::Local.new(base_dir: "/mnt/backup")

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

    # If present, the 404 page will show a random post from this pool.
    def page_not_found_pool_id
      nil
    end

    # Tags that are only visible to Gold+ users.
    def restricted_tags
      []
    end

    # Your Pixiv PHPSESSID cookie. Get this by logging in to Pixiv and using
    # the devtools to find the PHPSESSID cookie. This is need for Pixiv upload
    # support.
    def pixiv_phpsessid
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

    def baraag_client_id
      nil
    end

    def baraag_client_secret
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

    def stripe_webhook_secret
    end

    def stripe_gold_usd_price_id
    end

    def stripe_platinum_usd_price_id
    end

    def stripe_gold_to_platinum_usd_price_id
    end

    def stripe_gold_eur_price_id
    end

    def stripe_platinum_eur_price_id
    end

    def stripe_gold_to_platinum_eur_price_id
    end

    def stripe_promotion_discount_id
    end

    def twitter_api_key
    end

    def twitter_api_secret
    end

    # If defined, Danbooru will automatically post new forum posts to the
    # Discord channel belonging to this webhook.
    def discord_webhook_id
    end

    def discord_webhook_secret
    end

    # Settings used for Discord slash commands.
    #
    # * Go to https://discord.com/developers/applications
    # * Create an application.
    # * Copy the client ID and public key.
    # * Create a bot user.
    # * Copy the bot token.
    # * Go to the OAuth2 page, select the `bot` and `applications.commands`
    #   scopes, and the `Administrator` permission, then follow the oauth2
    #   link to add the bot to the Discord server.
    def discord_application_client_id
    end

    def discord_application_public_key
    end

    def discord_bot_token
    end

    # The ID of the Discord server to register slash commands for.
    def discord_guild_id
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

    def http_proxy_host
    end

    def http_proxy_port
    end

    def http_proxy_username
    end

    def http_proxy_password
    end

    # The URL for the Reportbooru server (https://github.com/evazion/reportbooru).
    # Optional. Used for tracking post views, popular searches, and missed searches.
    # Set to http://localhost/mock/reportbooru to enable a fake reportbooru
    # server for development purposes.
    def reportbooru_server
    end

    def reportbooru_key
    end

    # The URL for the IQDB server (https://github.com/danbooru/iqdb). Optional.
    # Used for dupe detection and reverse image searches. Set this to
    # http://localhost:3000/mock/iqdb to enable a fake iqdb server for
    # development purposes.
    def iqdb_url
      # "http://localhost:3000/mock/iqdb"
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

    # Cloudflare API token. Used to purge URLs from Cloudflare's cache when a
    # post is replaced. The token must have 'zone.cache_purge' permissions.
    # https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys
    def cloudflare_api_token
    end

    # The Cloudflare zone ID. This is the domain that cached URLs will be purged from.
    def cloudflare_zone
    end

    # Google Cloud API key. Used for exporting data to BigQuery and to Google
    # Cloud Storage. Should be the JSON key object you get after creating a
    # service account. Must have the "BigQuery User" and "Storage Admin" roles.
    #
    # * Go to https://console.cloud.google.com/iam-admin/serviceaccounts and create a service account.
    # * Go to "Keys" and add a new key.
    # * Go to https://console.cloud.google.com/iam-admin/iam and add the
    #   BigQuery User and Storage Admin roles to the service account.
    # * Paste the JSON key file here.
    def google_cloud_credentials
    end

    # The URL for the recommender server (https://github.com/evazion/recommender).
    # Optional. Used to generate post recommendations.
    # Set to http://localhost/mock/recommender to enable a fake recommender
    # server for development purposes.
    def recommender_server
    end

    # Uncomment to enable the Redis cache store. Caching is optional for
    # small boorus but highly recommended for large multi-user boorus. Redis is
    # required to enable saved searches.
    def redis_url
      # "redis://localhost:6379"
    end

    # Optional. The license key for your New Relic account.
    # https://newrelic.com/
    # https://docs.newrelic.com/docs/accounts/accounts-billing/account-setup/new-relic-license-key/
    def new_relic_license_key
    end
  end

  EnvironmentConfiguration = Struct.new(:config) do
    def method_missing(method, *args)
      var = ENV["DANBOORU_#{method.to_s.upcase.chomp("?")}"]

      var.presence || config.send(method, *args)
    end
  end
end
