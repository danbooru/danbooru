# frozen_string_literal: true

# A new feature that users can turn on or off in the Beta tab of their settings, to help test it before it's enabled for
# everyone. Beta features are stored in a `beta_feature_<name>` cookie instead of the database, so they're easy to
# remove once the feature is finished.
#
# Each feature is released to a stage. It only exists on sites at that stage or an earlier one, as set by
# `Danbooru.config.release_stage`. On testbooru and betabooru, features are on by default. On production, they're off
# by default.
#
# | released_to  | testbooru     | betabooru     | production     |
# |--------------|---------------|---------------|----------------|
# | "testbooru"  | on by default | hidden        | hidden         |
# | "betabooru"  | on by default | on by default | hidden         |
# | "production" | on by default | on by default | off by default |
#
# To add a beta feature, add it to `BetaFeature.features`. Check whether it's enabled with
# `BetaFeature.find("name")&.enabled?(cookies)` in Ruby, `BetaFeature.enabled("name")` in Javascript, or
# `body[data-beta-features~="name"]` in CSS.
#
# Rules for beta features:
#
# * Users control their own cookies, so anyone can turn on any feature released to their site, or turn off one that's
#   on by default. Only use beta features to choose between UI versions. Never use them to decide permissions, rate
#   limits, validations, or anything else that has to be enforced.
# * Hidden features are only hidden from the page. Their Javascript and CSS are still in the bundle on every site, so
#   don't merge anything that has to stay secret. Check `BetaFeature.find("name")&.enabled?(cookies)` in every
#   controller action a feature adds, and return a 404 if it's off.
# * Never reuse the name of a removed feature. Old cookies would turn the new feature on or off.
#
# The cookies of removed or unreleased features are deleted on the next page load (see `delete_stale_cookies`).
class BetaFeature
  # The release stages, from earliest to latest.
  STAGES = %w[testbooru betabooru production].freeze

  COOKIE_PREFIX = "beta_feature_"

  # The cookies we set, e.g. `beta_feature_new_uploader`. Other names are ignored, because we can't delete them safely:
  # Rack raises an error when it writes a cookie name with a space in it, which breaks every page.
  COOKIE_NAME_REGEX = /\A#{COOKIE_PREFIX}[a-z0-9_]+\z/

  attr_reader :name, :label, :description, :released_to

  # @return [Array<BetaFeature>] Every beta feature, including ones that aren't released to this site yet.
  def self.features
    []
  end

  # @return [Array<BetaFeature>] The beta features released to this site. The Beta tab is hidden when there aren't any.
  def self.all
    features.select(&:available?)
  end

  # @param cookies [Hash] The request's cookies.
  # @return [Array<BetaFeature>] The beta features that are on for this user.
  def self.enabled(cookies)
    all.select { |feature| feature.enabled?(cookies) }
  end

  # @param name [String] The name of the feature, e.g. "new_feature".
  # @return [BetaFeature, nil] The feature, or nil if it doesn't exist or isn't released to this site.
  def self.find(name)
    all.find { |feature| feature.name == name }
  end

  # Delete the cookies of features that were removed or aren't released to this site. The list of features is only built
  # if the user has a beta cookie, so this is cheap for everyone else.
  #
  # @param cookies [ActionDispatch::Cookies::CookieJar] The request's cookies.
  def self.delete_stale_cookies(cookies)
    beta_cookies = cookies.to_hash.keys.grep(COOKIE_NAME_REGEX)
    return if beta_cookies.empty?

    (beta_cookies - all.map(&:cookie_name)).each { |name| cookies.delete(name) }
  end

  # @return [String] This site's release stage. An unknown stage is treated as production, so features stay hidden.
  def self.release_stage
    Danbooru.config.release_stage.presence_in(STAGES) || "production"
  end

  # @param name [String] A short name for the feature, used in the cookie name, e.g. "new_feature". It's also
  #   used in HTML and Javascript, so it can only contain lowercase letters, numbers, and underscores.
  # @param label [String] The name shown in the settings, e.g. "New feature".
  # @param description [String] The description shown in the settings.
  # @param released_to [String] The latest stage the feature is available on: "testbooru", "betabooru", or "production".
  def initialize(name:, label:, description:, released_to:)
    raise ArgumentError, "invalid beta feature name: #{name.inspect}" unless name.match?(/\A[a-z0-9_]+\z/)
    raise ArgumentError, "invalid release stage: #{released_to.inspect}" unless released_to.in?(STAGES)

    @name = name
    @label = label
    @description = description
    @released_to = released_to
  end

  # @return [Boolean] Whether the feature is released to this site.
  def available?
    STAGES.index(BetaFeature.release_stage) <= STAGES.index(released_to)
  end

  # @return [String] The name of the cookie that turns the feature on or off.
  def cookie_name
    "#{COOKIE_PREFIX}#{name}"
  end

  # @param cookies [Hash] The request's cookies.
  # @return [Boolean] Whether the feature is on, either because the user turned it on, or because it's on by default.
  def enabled?(cookies)
    if cookies[cookie_name].present?
      cookies[cookie_name] == "true"
    else
      BetaFeature.release_stage != "production"
    end
  end
end
