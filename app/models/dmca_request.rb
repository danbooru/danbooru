# frozen_string_literal: true

# A DMCA takedown request submitted through the form at /dmca. Only visible to superadmins.
#
# The personal info is encrypted in the database, and is purged once the request has been handled or rejected
# and is older than PERSONAL_INFO_RETENTION.
class DmcaRequest < ApplicationRecord
  PERSONAL_INFO_RETENTION = 90.days

  attr_accessor :updater

  attribute :public_id, :string, default: -> { SecureRandom.alphanumeric(16, chars: [*"0".."9", *"a".."z"]) }

  encrypts :name, :email, deterministic: true
  encrypts :address, :proof, :signature

  has_many :mod_actions, as: :subject, dependent: :destroy

  normalizes :name, :email, :address, :infringing_urls, :original_urls, :proof, :signature, with: ->(value) { value.strip }

  validates :name, :email, :signature, presence: true, length: { maximum: 200 }
  validate { errors.add(:email, "is invalid") if email.present? && !Danbooru::EmailAddress.is_valid?(email) }
  validates :address, length: { maximum: 1000 }
  validates :infringing_urls, :original_urls, presence: true, length: { maximum: 50_000 }
  validates :proof, length: { maximum: 10_000 }

  enum :status, {
    pending: 0,
    rejected: 1,
    handled: 2,
  }, validate: true

  validates :status, exclusion: { in: %w[pending], message: "can't be set back to pending" }, on: :update, if: :status_changed?

  before_create :parse_danbooru_urls
  after_update :create_modaction

  # Save the infringing URLs that point to this site, and the IDs of the existing posts they point to. URLs count as
  # this site's if they're on the canonical domain, an alternate domain, or the domain images are served from.
  #
  # https://danbooru.donmai.us/posts/1234 => 1234
  # https://danbooru.donmai.us/media_assets/5678 => the post with media asset 5678
  # https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg => the post with MD5 8d819da4871c3ca39f428999df8220ce
  def parse_danbooru_urls
    site_hosts = [Danbooru.config.canonical_url, Danbooru.config.storage_manager.base_url].filter_map { |url| Danbooru::URL.parse(url)&.host }
    site_hosts = (site_hosts + Danbooru.config.alternate_domains).map(&:downcase)

    urls = infringing_urls.split.filter_map { |url| Danbooru::URL.parse(url) }.select { |url| url.host.downcase.in?(site_hosts) }
    urls = urls.map { |url| Source::URL::Danbooru2.new(url) } # Parse the URL as a Danbooru URL, even if the site isn't on donmai.us.
    self.danbooru_urls = urls.map(&:original_url)

    md5s = urls.filter_map(&:md5) + MediaAsset.where(id: urls.filter_map(&:media_asset_id)).pluck(:md5)
    self.post_ids = Post.where(id: urls.filter_map(&:post_id)).or(Post.where(md5: md5s)).order(:id).pluck(:id)
  end

  def posts
    Post.where(id: post_ids)
  end

  def self.prune!
    where.not(status: :pending).where(created_at: ...PERSONAL_INFO_RETENTION.ago).where.not(name: nil).update_all(name: nil, email: nil, address: nil, proof: nil, signature: nil, updated_at: Time.zone.now)
  end

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)
    q.apply_default_order(params)
  end

  def purged?
    name.nil?
  end

  def create_modaction
    return unless saved_change_to_status?

    ModAction.log(%{#{status} "DMCA request ##{id}":#{Routes.dmca_request_path(self)}}, :"dmca_request_#{status}", subject: self, user: updater)
  end
end
