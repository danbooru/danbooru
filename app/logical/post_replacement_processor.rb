# frozen_string_literal: true

class PostReplacementProcessor
  class Error < StandardError; end

  attr_reader :post, :replacement

  def initialize(post:, replacement:)
    @post = post
    @replacement = replacement
  end

  def process!
    media_file, image_url = get_file_for_upload(replacement.replacement_url, nil, replacement.replacement_file&.tempfile)

    if Post.where.not(id: post.id).exists?(md5: media_file.md5)
      raise Error, "Duplicate of post ##{Post.find_by_md5(media_file.md5).id}"
    end

    if media_file.md5 == post.md5
      media_asset = post.media_asset
    else
      MediaAsset.validate_media_file!(media_file, replacement.creator)
      media_asset = MediaAsset.upload!(media_file)
    end

    if replacement.replacement_file.present?
      replacement_url = "file://#{replacement.replacement_file.original_filename}"
    elsif Source::URL.page_url(image_url).present?
      replacement_url = image_url
    else
      replacement_url = replacement.replacement_url.strip
    end

    replacement.replacement_url = replacement_url
    replacement.file_ext = media_asset.file_ext
    replacement.file_size = media_asset.file_size
    replacement.image_height = media_asset.image_height
    replacement.image_width = media_asset.image_width
    replacement.md5 = media_asset.md5
    replacement.media_asset = media_asset

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
  ensure
    media_file&.close
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
    raise Error, "No file or source URL provided" if source_url.blank?

    extractor = Source::Extractor.find(source_url, referer_url)
    raise Error, "No login credentials configured for #{extractor.site_name}." unless extractor.class.enabled?

    image_urls = extractor.image_urls
    raise Error, "#{source_url} has multiple images. Enter the URL of a single image" if image_urls.size > 1
    raise Error, "#{source_url} has no images" if image_urls.size == 0

    image_url = image_urls.first
    file = extractor.download_file!(image_url)

    [file, image_url]
  end
end
