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

require_relative "../app/logical/current_user"

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

    # A list of alternate domains for your site, if your site is accessible under multiple domains. For example,
    # Danbooru is accessible under danbooru.donmai.us, betabooru.donmai.us, safebooru.donmai.us, etc.
    #
    # Used for converting direct links to these domains to shortlinks, e.g. `https://danbooru.donmai.us/posts/1234` to `post #1234`.
    #
    # Most people should leave this empty.
    def alternate_domains
      []
    end

    # A list of alternate hostnames where safe mode will automatically be enabled.
    def safe_mode_hostnames
      ["safebooru.donmai.us"]
    end

    # The URL for your site, if you have a custom domain name for your site.
    #
    # For example, if your domain name is `booru.example.com`, then you would set this to "http://booru.example.com".
    #
    # If your site supports HTTPS, then set this to `https://`. If you set this to https://, then you must use https://
    # to access your site, because in HTTPS mode session cookies aren't sent for http:// URLs.
    #
    # If your site is accessible under multiple domain names, then this should be the primary URL for your site. For
    # example, Danbooru is available at both https://danbooru.donmai.us and https://betabooru.donmai.us. The canonical
    # URL for Danbooru is https://danbooru.donmai.us because that's the main version of the site.
    #
    # This is used in various places when we need to know the URL of the site, such as when generating emails or when
    # generating links to images.
    #
    # The default is to determine the URL based on the current HTTP request. This means we use the same URL you see in
    # the browser address bar. We fall back to `http:/localhost:3000` in various situations when we're outside of a HTTP
    # request and we can't determine the URL (for example, when generating emails inside background jobs).
    #
    # If you're not running a public site, then you don't need to change this.
    def canonical_url
      CurrentUser.request&.base_url.presence || "http://localhost:#{ENV["DANBOORU_PORT"] || 3000}"
    end

    # The domain name to use for email addresses.
    def email_domain
      Danbooru::URL.parse!(Danbooru.config.canonical_url).host
    end

    # The email address of the admin user. This email will be publicly displayed on the contact page.
    def contact_email
      "webmaster@#{email_domain}"
    end

    # The email address where DMCA complaints should be sent.
    def dmca_email
      "dmca@#{email_domain}"
    end

    # The email address to use for Dmail notifications.
    def notification_email
      "notifications@#{email_domain}"
    end

    # The email address to use for password reset and email verification emails.
    def account_security_email
      "security@#{email_domain}"
    end

    # The email address to use for new user signup emails.
    def welcome_user_email
      "welcome@#{email_domain}"
    end

    # System actions, such as sending automated dmails, will be performed with
    # this account. This account must have Moderator privileges.
    #
    # Run `rake db:seed` to create this account if it doesn't already exist in your install.
    def system_user
      "DanbooruBot"
    end

    # The name of the cookie that stores the current user's login session.
    #
    # Changing this will force all users to login again.
    #
    # Normally the only reason to change this is if you're running multiple Danbooru instances on different subdomains,
    # for example booru.example.com and test.example.com, and you don't want them to share login cookies because they
    # don't share users.
    def session_cookie_name
      "_danbooru2_session"
    end

    # The domain of the cookie that stores the current user's login session.
    #
    # If you're running Danbooru on multiple subdomains, and you want to share cookies across subdomains so that users
    # stay logged in when they visit a different subdomain, then you can set this to the base domain.
    #
    # For example, if you have booru.example.com, beta.example.com, and test.example.com, then you can set this to
    # example.com so that cookies are shared between subdomains and users stay logged in if they switch subdomains.
    #
    # The default is to not share cookies across subdomains. Normally this should not be changed.
    def session_cookie_domain
    end

    # Debug mode does some things to make testing easier. It outputs more verbose logs, it disables parallel testing,
    # and it replaces Danbooru's custom exception page with the default Rails exception page. This is only useful during
    # development and testing.
    #
    # Usage: DANBOORU_DEBUG_MODE=true bin/rails test
    def debug_mode
      false
    end

    # The log level for the application. Valid values are "debug", "info", "warn", "error", or "fatal". "debug" is the
    # most verbose and "fatal" is the least verbose.
    #
    # The default log level is taken from the RAILS_LOG_LEVEL environment variable, otherwise it's "debug" if debug mode
    # is enabled, otherwise it's "error" in production, "info" in development, or "fatal" in testing.
    def log_level
      if ENV["RAILS_LOG_LEVEL"].present?
        ENV["RAILS_LOG_LEVEL"]
      elsif debug_mode
        :debug
      elsif Rails.env.production?
        :error
      elsif Rails.env.development?
        :info
      else
        :fatal
      end
    end

    def source_code_url
      "https://github.com/danbooru/danbooru"
    end

    def issues_url
      "#{source_code_url}/issues"
    end

    # The maximum number of threads to use for certain operations, such as generating thumbnails or processing bulk
    # update requests.
    #
    # The default is to use 1 thread per CPU core.
    #
    # Set this to 0 to disable multithreading. This may save memory at the cost of reduced performance.
    def max_concurrency
      Concurrent.available_processor_count.to_i.clamp(1..)
    end

    # If true, allow web crawlers such as Google to crawl your site.
    #
    # If false, don't allow crawlers to crawl your site. This means your site won't be indexed by search engines.
    #
    # Setting this to false disallows crawlers in /robots.txt. This will only block crawlers that actually respect
    # robots.txt, mainly search engines, not other bots.
    def allow_web_crawlers?
      true
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

    # An array of regexes containing disallowed words in comments and forum posts.
    def comment_blacklist
      []
    end

    # Large resize image width. Set to nil to disable.
    def large_image_width
      850
    end

    # After a post receives this many comments, new comments will no longer bump the post in comment/index.
    def comment_threshold
      40
    end

    # Maximum size of an upload. If you change this, you must also change `client_max_body_size` in your nginx.conf.
    def max_file_size
      100.megabytes
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

    # Set mail_delivery_url to configure how emails are sent. The format is "smtp://username:password@example.com:587".
    #
    # If this is not set, then sending emails will be disabled. Emails are used for sending password resets, verifying
    # accounts that sign up from a proxy, and for sending notifications when a user receives a private message (Dmail).
    #
    # If emails aren't being sent, check the /jobs page for errors.
    #
    # For local email testing, you can use MailHog: https://github.com/mailhog/MailHog.
    #
    # https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
    # https://guides.rubyonrails.org/configuring.html#configuring-action-mailer
    # https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb
    def mail_delivery_url
      # For Gmail. Replace `username@gmail.com` with your Gmail address.
      # You'll need to enable 2FA and use an app password: https://myaccount.google.com/apppasswords.
      # "smtps://username@gmail.com:password@smtp.gmail.com:587"

      # For Amazon SES. https://docs.aws.amazon.com/ses/latest/dg/send-email-smtp.html
      # "smtps://username:password@email.us-east-1.amazonaws.com"

      # You can set `authentication` to login, plain, or cram_md5 if your server requires LOGIN, PLAIN, or CRAM-MD5 authentication.
      # "smtp://username:password@example.com:587?authentication=login"

      # You can set `enable_starttls` if your server requires STARTTLS.
      # "smtp://username:password@example.com:587?enable_starttls=true&authentication=login"

      # You can set `openssl_verify_mode` to `none` to disable verification of the server's SSL certificate if you have a self-signed certificate.
      # "smtps://username:password@example.com?openssl_verify_mode=none"
    end

    # Deprecated. Use `mail_delivery_url` instead.
    def mail_delivery_method
    end

    # Deprecated. Use `mail_delivery_url` instead.
    def mail_settings
    end

    # The path to where uploaded files are stored. You can change this to change where files are
    # stored. By default, files are stored like this:
    #
    # * /original/94/43/944364e77f56183e2ebd75de757488e2.jpg
    # * /sample/94/43/sample-944364e77f56183e2ebd75de757488e2.jpg
    # * /180x180/94/43/944364e77f56183e2ebd75de757488e2.jpg
    #
    # A variant is a thumbnail or other alternate version of an uploaded file; see the Variant class
    # in app/models/media_asset.rb for details.
    #
    # This path is relative to the `base_dir` option in the storage manager (see the `storage_manager` option below).
    def media_asset_file_path(variant)
      md5 = variant.md5
      file_prefix = "sample-" if variant.type == :sample
      "/#{variant.type}/#{md5[0..1]}/#{md5[2..3]}/#{file_prefix}#{md5}.#{variant.file_ext}"

      # To store files in this format: `/original/944364e77f56183e2ebd75de757488e2.jpg`
      # "/#{variant.type}/#{variant.md5}.#{variant.file_ext}"
      #
      # To store files in this format: `/original/iuQRl7d7n.jpg`
      # "/#{variant.type}/#{variant.file_key}.#{variant.file_ext}"
      #
      # To store files in this format: `/original/12345.jpg`
      # "/#{variant.type}/#{variant.id}.#{variant.file_ext}"
    end

    # The URL where uploaded files are served from. You can change this to customize how images are
    # served. By default, files are served from the same location where they're stored.
    #
    # `custom_filename` is an optional tag string that may be included in the URL. It requires Nginx
    # rewrites to work (see below), so it's ignored by default.
    #
    # The URL is relative to the `base_url` option in the storage manager (see the `storage_manager` option below).
    def media_asset_file_url(variant, custom_filename)
      media_asset_file_path(variant)

      # To serve files in this format:
      #
      #     /original/d3/4e/__kousaka_tamaki_to_heart_2_drawn_by_kyogoku_shin__d34e4cf0a437a5d65f8e82b7bcd02606.jpg.
      #
      # Uncomment the code below and add the following to Nginx:
      #
      #     # Strip tags from filenames (/original/d3/4e/__kousaka_tamaki_to_heart_2_drawn_by_kyogoku_shin__d34e4cf0a437a5d65f8e82b7bcd02606.jpg => /original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg)
      #     location ~ (.*)/__.+?__(.+)$ {
      #       rewrite (.*)/__.+?__(.+)$ $1/$2;
      #     }
      #
      # custom_filename = "__#{custom_filename}__" if custom_filename.present?
      # file_prefix = "sample-" if variant.type == :sample
      # "/#{variant.type}/#{variant.md5[0..1]}/#{variant.md5[2..3]}/#{custom_filename}#{file_prefix}#{variant.md5}.#{variant.file_ext}"
    end

    # The location where images should be stored. By default, images are stored under `public/data`.
    def image_storage_path
      Rails.root.join("public/data")
    end

    # The method to use for storing uploaded files.
    def storage_manager
      # Store files on the local filesystem.
      # base_dir - where to store files (default: under public/data)
      # base_url - where to serve files from (default: #{canonical_url}/data)
      StorageManager::Local.new(base_url: "#{Danbooru.config.canonical_url}/data", base_dir: Danbooru.config.image_storage_path)
    end

    # The method to use for backing up image files.
    def backup_storage_manager
      # Don't perform any backups.
      StorageManager::Null.new

      # Backup files to /mnt/backup on the local filesystem.
      # StorageManager::Local.new(base_dir: "/mnt/backup")
    end

    # A short description of your site that goes in the <meta name="description"> tag. Used by search engines.
    #
    # https://developers.google.com/search/docs/crawling-indexing/special-tags#meta-tags
    # https://developers.google.com/search/docs/appearance/snippet
    def site_description
    end

    # A short tagline for your site that goes in the page title on the front page. Used by search engines.
    def site_tagline
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
    def pawoo_access_token
      nil
    end

    def baraag_access_token
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

    # Your ArtStreet (medibang.com) "MSID" cookie. Needed to view R-18 works.
    #
    # After you create an account, go to https://medibang.com/myProfile/myProfileModifyForm/ to set your age to 18+,
    # then enable mature content. After you login, use the devtools to find the "MSID" cookie.
    def art_street_session_cookie
    end

    # Your Twitter "auth_token" cookie. A 40-character hex string.
    #
    # Login to Twitter, open the devtools, open a tweet, then use the devtools to find the /TweetDetail request and look for the auth_token cookie.
    def twitter_auth_token
    end

    # Your Twitter "ct0" cookie. Also available in the X-CSRF-Token HTTP Header. A 160-character hex string.
    #
    # Login to Twitter, open the devtools, open a tweet, then use the devtools to find the /TweetDetail request and look for the ct0 cookie or the x-csrf-request header.
    def twitter_csrf_token
    end

    # Your Xfolio "xfolio_session" cookie. Login to Xfolio then use the
    # devtools to find the "xfolio_session" cookie.
    def xfolio_session
    end

    # Your Ci-En "ci_en_session" cookie. Login to Ci-En then use the
    # devtools to find the "ci_en_session" cookie.
    def ci_en_session_cookie
    end

    # Your Poipiku "POIPIKU_LK" cookie. Login to Poipiku then use the
    # devtools to find the "POIPIKU_LK" cookie.
    def poipiku_session_cookie
    end

    # Your Zerochan user ID. Login to Zerochan then use the devtools to find the "z_id" cookie.
    def zerochan_user_id
    end

    # Your Zerochan "z_hash" cookie. Login to Zerochan then use the devtools to find the "z_hash" cookie.
    def zerochan_session_cookie
    end

    # Your Inkbunny username and password. After creating your account, go to https://inkbunny.net/account.php and
    # enable the "Enable API access" option, then go to https://inkbunny.net/userrate.php and enable all ratings to see
    # all content.
    def inkbunny_username
    end

    def inkbunny_password
    end

    # Your Bluesky identifier and password.
    def bluesky_identifier
    end

    def bluesky_password
    end

    # Your Postype "PSE3" cookie. Login to Postype then use the devtools to find the "PSE3" cookie.
    # After creating your account, go to https://www.postype.com/account/settings and enable the "Viewing adult content
    # by foreigners" setting to see all content.
    def postype_session_cookie
    end

    # Your Behance "iat0" cookie. Login to Behance then use the devtools to find the "iat0" cookie.
    def behance_session_cookie
    end

    # Your Piapro.jp "piapro_s" cookie. Login to Piapro then use the devtools to find the "piapro_s" cookie.
    def piapro_session_cookie
    end

    # Your Plurk "plurktokena" cookie. Login to Plurk then use the devtools to find the "plurktokena" cookie.
    def plurk_session_cookie
    end

    # Your Google Blogger API key. Go to https://developers.google.com/blogger/docs/3.0/using#APIKey to create an API key.
    # You can also use gallery-dl's API key, but you might get rate-limited if others are using it.
    # https://github.com/mikf/gallery-dl/blob/07d962d60aed598f0ee8578df914c38e5fc939aa/gallery_dl/extractor/blogger.py#L162
    def blogger_api_key
    end

    # A list of tags that should be removed when a post is replaced. Regexes allowed.
    def post_replacement_tag_removals
      %w[replaceme .*_sample resized upscaled downscaled md5_mismatch
      jpeg_artifacts corrupted_image missing_image missing_sample missing_thumbnail
      resolution_mismatch source_larger source_smaller source_request non-web_source]
    end

    # Posts with these tags will be highlighted in the modqueue.
    def modqueue_warning_tags
      %w[ai-generated ai-assisted anime_screencap bad_source duplicate hard_translated image_sample md5_mismatch
      nude_filter off-topic paid_reward resized third-party_edit]
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

    # The proxy to use for outgoing HTTP requests.
    #
    # If you use a proxy and you're running a public-facing site, you should be careful to configure the proxy to block
    # HTTP requests to the local network. That is, block requests to e.g. 127.0.0.1 and 192.168.0.1/24 so that users
    # can't upload URLs like `http://192.168.0.1.nip.io/` to trigger HTTP requests to servers inside your local network.
    def http_proxy
      # "http://username:password@proxy.example.com:1080"
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

    # If `captcha_site_key` and `captcha_secret_key` are set, then captchas will be enabled on the signup page to
    # protect the site against spambots. This uses the free Cloudflare Turnstile service.
    #
    # By default in development mode, we use a dummy captcha that always passes.
    #
    # https://developers.cloudflare.com/turnstile/get-started/#get-a-sitekey-and-secret-key
    def captcha_site_key
      # https://developers.cloudflare.com/turnstile/reference/testing/#dummy-sitekeys-and-secret-keys
      "3x00000000000000000000FF" if Rails.env.development? # A dummy key that always forces an interactive challenge
    end

    def captcha_secret_key
      # https://developers.cloudflare.com/turnstile/reference/testing/#dummy-sitekeys-and-secret-keys
      "1x0000000000000000000000000000000AA" if Rails.env.development? # A dummy key that always passes
    end

    # Akismet API key. Used for Dmail spam detection. http://akismet.com/signup/
    def rakismet_key
    end

    def rakismet_url
      Danbooru.config.canonical_url
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

    # A list of emojis supported in DText.
    def dtext_emojis
      @dtext_emojis ||= {
        # This defines an emoji called :smile: that is replaced with 😄.
        "smile" => "😄",
      }
    end

    def reactions
      {}
    end
  end

  EnvironmentConfiguration = Struct.new(:config) do
    def method_missing(method, *args)
      var = ENV["DANBOORU_#{method.to_s.upcase.chomp("?")}"]

      var.presence || config.send(method, *args)
    end
  end
end
