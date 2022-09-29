# frozen_string_literal: true
#
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
#     DANBOORU_CONTACT_EMAIL=admin@booru.example.com
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

    # A list of alternate hostnames where safe mode will automatically be enabled.
    def safe_mode_hostnames
      ["safebooru.donmai.us"]
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

    # The email address of the admin user. This email will be publicly displayed on the contact page.
    def contact_email
      "webmaster@#{Danbooru.config.hostname}"
    end

    # The email address to use for Dmail notifications.
    def notification_email
      "notifications@#{Danbooru.config.hostname}"
    end

    # The email address to use for password reset and email verification emails.
    def account_security_email
      "security@#{Danbooru.config.hostname}"
    end

    # The email address to use for new user signup emails.
    def welcome_user_email
      "welcome@#{Danbooru.config.hostname}"
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

    # Maximum duration of an video in seconds.
    def max_video_duration
      # 2:20m
      140
    end

    # How long pending posts stay in the modqueue before being deleted.
    def moderation_period
      3.days
    end

    # Upload points can be earned or lost by users. They punish and reward users by adding and removing upload slots.
    # 1000 points is enough for 10 uploads. See app/logical/upload_limit.rb for details on the level system.
    def initial_upload_points
      1000
    end

    # The cap on how many upload points a user can earn.
    def maximum_upload_points
      10_000
    end

    # These slots are added to the ones earned by upload levels and guaranteed to all users, even those at level 0.
    def extra_upload_slots
      5
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
    end

    # The method to use for backing up image files.
    def backup_storage_manager
      # Don't perform any backups.
      StorageManager::Null.new

      # Backup files to /mnt/backup on the local filesystem.
      # StorageManager::Local.new(base_dir: "/mnt/backup")
    end

    # Any custom code you want to insert into the default layout without
    # having to modify the templates.
    def custom_html_header_content
      nil
    end

    # The HTML that should go on the contact page.
    def contact_page_html
    end

    # The number of posts displayed per page.
    def posts_per_page
      20
    end

    # Tags that are not visible in safe mode.
    def safe_mode_restricted_tags
      []
    end

    # If present, the 404 page will show a random post from this pool.
    def page_not_found_pool_id
      nil
    end

    # Tags that are only visible to Gold+ users.
    def restricted_tags
      []
    end

    # Tag searches with less than this many results will be considered "small
    # searches" and optimized specially. This is unnecessary unless you have a
    # Danbooru-sized database.
    def small_search_threshold
      nil
    end

    # Your Pixiv PHPSESSID cookie. Get this by logging in to Pixiv and using
    # the devtools to find the PHPSESSID cookie. This is need for Pixiv upload
    # support.
    def pixiv_phpsessid
      nil
    end

    # Your Newgrounds "vmkIdu5l8m" cookie. Login to Newgrounds then use the
    # devtools to find the "vmkIdu5l8m" cookie.
    def newgrounds_session_cookie
      nil
    end

    # Your NicoSeiga "user_session" cookie. Login to NicoSeiga then use the
    # devtools to find the "user_session" cookie.
    def nico_seiga_user_session
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

    # Your Tinami "Tinami2SESSID" cookie. Login to Tinami then use the devtools to find the "Tinami2SESSID" cookie.
    def tinami_session_id
      nil
    end

    # 1. Register app at https://www.tumblr.com/oauth/register.
    # 2. Copy "OAuth Consumer Key" from https://www.tumblr.com/oauth/apps.
    def tumblr_consumer_key
      nil
    end

    # Your Fantia "_session_id" cookie. Login to Fantia then use the
    # devtools to find the "_session_id" cookie.
    def fantia_session_id
    end

    # Your Furaffinity "a" cookie. Login to Furaffinity then use the
    # devtools to find the "a" cookie.
    # !!WARNING!! logging out of furaffinity will expire this cookie too!
    def furaffinity_cookie_a
    end

    # Your Furaffinity "b" cookie. Login to Furaffinity then use the
    # devtools to find the "b" cookie.
    def furaffinity_cookie_b
    end

    # A list of tags that should be removed when a post is replaced. Regexes allowed.
    def post_replacement_tag_removals
      %w[replaceme .*_sample resized upscaled downscaled md5_mismatch
      jpeg_artifacts corrupted_image missing_image missing_sample missing_thumbnail
      resolution_mismatch source_larger source_smaller source_request non-web_source]
    end

    # Posts with these tags will be highlighted in the modqueue.
    def modqueue_warning_tags
      %w[hard_translated nude_filter third-party_edit screenshot
      anime_screencap duplicate image_sample md5_mismatch resized upscaled downscaled
      resolution_mismatch source_larger source_smaller ai-generated]
    end

    # Whether the Gold account upgrade page should be enabled.
    def user_upgrades_enabled?
      true
    end

    # Whether to enable API rate limits.
    def rate_limits_enabled?
      true
    end

    # Whether to enable comments.
    def comments_enabled?
      true
    end

    # Whether to enable the forum.
    def forum_enabled?
      true
    end

    # Whether to enable autocomplete.
    def autocomplete_enabled?
      true
    end

    # The URL of the Shopify checkout page where account upgrades are sold.
    def shopify_checkout_url
    end

    # The secret used to verify webhooks from Shopify. Get it from the https://xxx.myshopify.com/admin/settings/notifications page.
    def shopify_webhook_secret
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

    # The login ID for Authorize.net. Used for accepting payments for user upgrades.
    # Signup for a test account at https://developer.authorize.net/hello_world/sandbox.html.
    def authorize_net_login_id
    end

    # The transaction key for Authorize.net. This is the API secret for API calls.
    def authorize_net_transaction_key
    end

    # The signature key for Authorize.net. Used for verifying webhooks sent by Authorize.net.
    # Generate at Account > Settings > Security Settings > General Security Settings > API Credentials and Keys
    def authorize_net_signature_key
    end

    # Whether to use the test environment or the live environment for Authorize.net. The test environment
    # allows testing payments without using real credit cards.
    def authorize_net_test_mode
      true
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

    # The URL for the Danbooru Autotagger service (https://github.com/danbooru/autotagger). Optional.
    #
    # Used for the AI tagging feature. Set this to http://localhost:3000/mock/autotagger
    # to enable a fake server for development purposes, or do
    # `docker run --rm -p 5000:5000 ghcr.io/danbooru/autotagger` to run a real server.
    def autotagger_url
      # "http://localhost:3000/mock/autotagger"
      # "http://localhost:5000"
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

    # Optional. The URL of the Elastic APM server. Used for application performance monitoring.
    #
    # https://www.elastic.co/observability/application-performance-monitoring
    def elastic_apm_server_url
      # "http://localhost:8200"
    end

    # True if the Winter Sale is active.
    def is_promotion?
      false
    end

    # The end date of the Winter Sale.
    def winter_sale_end_date
    end

    # The forum topic linked to in the Winter Sale notice.
    def winter_sale_forum_topic_id
    end
  end

  EnvironmentConfiguration = Struct.new(:config) do
    def method_missing(method, *args)
      var = ENV["DANBOORU_#{method.to_s.upcase.chomp("?")}"]

      var.presence || config.send(method, *args)
    end
  end
end
