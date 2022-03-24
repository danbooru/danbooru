# frozen_string_literal: true

class PostReplacementProcessor
  attr_reader :post, :replacement

  def initialize(post:, replacement:)
    @post = post
    @replacement = replacement
  end

  def process!
    media_file, image_url = get_file_for_upload(replacement.replacement_url, nil, replacement.replacement_file&.tempfile)

    if Post.where.not(id: post.id).exists?(md5: media_file.md5)
      raise "Duplicate of post ##{Post.find_by_md5(media_file.md5).id}"
    end

    if media_file.md5 == post.md5
      media_asset = post.media_asset
    else
      media_asset = MediaAsset.upload!(media_file)
    end

    if replacement.replacement_file.present?
      canonical_url = "file://#{replacement.replacement_file.original_filename}"
    elsif Source::URL.page_url(image_url).present?
      canonical_url = image_url
    else
      canonical_url = replacement.replacement_url
    end

    replacement.replacement_url = canonical_url
    replacement.file_ext = media_asset.file_ext
    replacement.file_size = media_asset.file_size
    replacement.image_height = media_asset.image_height
    replacement.image_width = media_asset.image_width
    replacement.md5 = media_asset.md5

    post.lock!
    post.md5 = media_asset.md5
    post.file_ext = media_asset.file_ext
    post.image_width = media_asset.image_width
    post.image_height = media_asset.image_height
    post.file_size = media_asset.file_size
    post.source = replacement.final_source.presence || replacement.replacement_url
    post.tag_string = "#{post.tag_string} #{replacement.tags}"

    rescale_notes(post)
    post.save!
    post.update_iqdb
  rescue Exception => exception
    replacement.errors.add(:base, exception.message)
    raise ActiveRecord::Rollback
  end

  def rescale_notes(post)
    x_scale = post.image_width.to_f  / post.image_width_was.to_f
    y_scale = post.image_height.to_f / post.image_height_was.to_f

    post.notes.each do |note|
      note.rescale!(x_scale, y_scale)
    end
  end

  def get_file_for_upload(source_url, referer_url, file)
    return MediaFile.open(file) if file.present?
    raise "No file or source URL provided" if source_url.blank?

    strategy = Sources::Strategies.find(source_url, referer_url)
    raise NotImplementedError, "No login credentials configured for #{strategy.site_name}." unless strategy.class.enabled?

    image_urls = strategy.image_urls
    raise "#{source_url} contains multiple images" if image_urls.size > 1

    image_url = image_urls.first
    file = strategy.download_file!(image_url)

    [file, image_url]
  end
end
