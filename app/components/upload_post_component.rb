# frozen_string_literal: true

class UploadPostComponent < ApplicationComponent
  extend Memoist

  delegate :edit_form_for, :embed_wiki, :exclamation_icon, :help_tooltip, :link_to_media_asset, :link_to_wiki, :render_source_data, to: :helpers

  attr_reader :upload_media_asset, :post, :current_user, :upload_edit_panel_dock, :upload_edit_container_width, :upload, :media_asset, :source, :source_site

  def initialize(upload_media_asset:, post:, current_user:, upload_edit_panel_dock: nil, upload_edit_container_width: nil)
    @upload_media_asset = upload_media_asset
    @post = post
    @current_user = current_user
    @upload_edit_panel_dock = upload_edit_panel_dock
    @upload_edit_container_width = upload_edit_container_width

    @upload = upload_media_asset.upload
    @media_asset = upload_media_asset.media_asset
    @source = upload_media_asset.source_extractor
    @source_site = upload_media_asset.parsed_canonical_url&.source_site

    super
  end

  # @return [Boolean] True if the upload rules should be shown to the user.
  def show_upload_rules?
    current_user.post_upload_count < 10
  end

  # @return [Boolean] True if the upload rules have been updated since the user's last post.
  def help_updated?
    WikiPage.find_by_title("help:upload_notice")&.updated_at.to_i > current_user.posts.maximum(:created_at).to_i
  end

  # @return [String, nil] The title of the wiki page for the site corresponding to the source URL ("help:pixiv", etc).
  memoize def source_site_wiki
    title = source_site&.name.to_s.downcase.gsub(/[^a-z0-9._]+/, "_").squeeze("_")

    "help:#{title}" if source_site.present?
  end

  # @return [String] The position of the edit panel: "auto", "right", "bottom", "left"
  memoize def dock_position
    Danbooru::JSON.parse(upload_edit_panel_dock).presence || "auto"
  end

  # @return [Array<Post>] The list of pixel-perfect duplicates.
  memoize def duplicates
    Post.joins(:media_asset).where("media_assets.pixel_hash": media_asset.pixel_hash).load
  end
end
