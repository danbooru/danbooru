class UploadService
  class Replacer
    extend Memoist
    class Error < StandardError; end

    attr_reader :post, :replacement

    def initialize(post:, replacement:)
      @post = post
      @replacement = replacement
    end

    def comment_replacement_message(post, replacement)
      %{"#{replacement.creator.name}":[#{Routes.user_path(replacement.creator)}] replaced this post with a new file:\n\n#{replacement_message(post, replacement)}}
    end

    def replacement_message(post, replacement)
      linked_source = linked_source(replacement.replacement_url)
      linked_source_was = linked_source(post.source_was)

      <<-EOS.strip_heredoc
        [table]
          [tbody]
            [tr]
              [th]Old[/th]
              [td]#{linked_source_was}[/td]
              [td]#{post.md5_was}[/td]
              [td]#{post.file_ext_was}[/td]
              [td]#{post.image_width_was} x #{post.image_height_was}[/td]
              [td]#{post.file_size_was.to_s(:human_size, precision: 4)}[/td]
            [/tr]
            [tr]
              [th]New[/th]
              [td]#{linked_source}[/td]
              [td]#{post.md5}[/td]
              [td]#{post.file_ext}[/td]
              [td]#{post.image_width} x #{post.image_height}[/td]
              [td]#{post.file_size.to_s(:human_size, precision: 4)}[/td]
            [/tr]
          [/tbody]
        [/table]
      EOS
    end

    def linked_source(source)
      return nil if source.nil?

      # truncate long sources in the middle: "www.pixiv.net...lust_id=23264933"
      truncated_source = source.gsub(%r{\Ahttps?://}, "").truncate(64, omission: "...#{source.last(32)}")

      if source =~ %r{\Ahttps?://}i
        %{"#{truncated_source}":[#{source}]}
      else
        truncated_source
      end
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

      CurrentUser.scoped(User.system) { Comment.create!(post: post, creator: User.system, updater: User.system, body: comment_replacement_message(post, replacement), do_not_bump_post: true, creator_ip_addr: "127.0.0.1") }

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
