# frozen_string_literal: true

class UploadService
  class Replacer
    class Error < StandardError; end

    attr_reader :post, :replacement

    def initialize(post:, replacement:)
      @post = post
      @replacement = replacement
    end

    def undo!
      undo_replacement = post.replacements.create(replacement_url: replacement.original_url)
      undoer = Replacer.new(post: post, replacement: undo_replacement)
      undoer.process!
    end

    def replacement_url
      if replacement.replacement_file.present?
        "file://#{replacement.replacement_file.original_filename}"
      else
        Sources::Strategies.find(replacement.replacement_url).canonical_url
      end
    end

    def process!
      media_file = Utils::get_file_for_upload(replacement.replacement_url, nil, replacement.replacement_file&.tempfile)

      if media_file.md5 == post.md5
        raise Error, "Can't replace a post with itself; regenerate the post instead"
      elsif Post.exists?(md5: media_file.md5)
        raise Error, "Duplicate: post with md5 #{media_file.md5} already exists"
      end

      media_asset = MediaAsset.upload!(media_file)

      replacement.replacement_url = replacement_url
      replacement.file_ext = media_asset.file_ext
      replacement.file_size = media_asset.file_size
      replacement.image_height = media_asset.image_height
      replacement.image_width = media_asset.image_width
      replacement.md5 = media_asset.md5

      post.md5 = media_asset.md5
      post.file_ext = media_asset.file_ext
      post.image_width = media_asset.image_width
      post.image_height = media_asset.image_height
      post.file_size = media_asset.file_size
      post.source = replacement.final_source.presence || replacement.replacement_url
      post.tag_string = replacement.tags

      rescale_notes(post)

      replacement.save!
      post.save!

      post.update_iqdb
    end

    def rescale_notes(post)
      x_scale = post.image_width.to_f  / post.image_width_was.to_f
      y_scale = post.image_height.to_f / post.image_height_was.to_f

      post.notes.each do |note|
        note.rescale!(x_scale, y_scale)
      end
    end
  end
end
