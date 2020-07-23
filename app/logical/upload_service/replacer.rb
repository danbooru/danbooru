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
      %("#{replacement.creator.name}":[/users/#{replacement.creator.id}] replaced this post with a new image:\n\n#{replacement_message(post, replacement)})
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
        %("#{truncated_source}":[#{source}])
      else
        truncated_source
      end
    end

    def undo!
      undo_replacement = post.replacements.create(replacement_url: replacement.original_url)
      undoer = Replacer.new(post: post, replacement: undo_replacement)
      undoer.process!
    end

    def source_strategy(upload)
      Sources::Strategies.find(upload.source, upload.referer_url)
    end

    def find_replacement_url(repl, upload)
      if repl.replacement_file.present?
        return "file://#{repl.replacement_file.original_filename}"
      end

      if !upload.source.present?
        raise "No source found in upload for replacement"
      end

      if source_strategy(upload).canonical_url.present?
        return source_strategy(upload).canonical_url
      end

      upload.source
    end

    def process!
      preprocessor = Preprocessor.new(
        rating: post.rating,
        tag_string: replacement.tags,
        source: replacement.replacement_url,
        file: replacement.replacement_file,
        replaced_post: post,
        original_post_id: post.id
      )
      upload = preprocessor.start!
      raise Error, upload.status if upload.is_errored?
      upload = preprocessor.finish!(upload)
      raise Error, upload.status if upload.is_errored?
      md5_changed = upload.md5 != post.md5

      replacement.replacement_url = find_replacement_url(replacement, upload)

      if md5_changed
        post.queue_delete_files(PostReplacement::DELETION_GRACE_PERIOD)
      end

      replacement.file_ext = upload.file_ext
      replacement.file_size = upload.file_size
      replacement.image_height = upload.image_height
      replacement.image_width = upload.image_width
      replacement.md5 = upload.md5

      post.md5 = upload.md5
      post.file_ext = upload.file_ext
      post.image_width = upload.image_width
      post.image_height = upload.image_height
      post.file_size = upload.file_size
      post.source = replacement.final_source.presence || replacement.replacement_url
      post.tag_string = upload.tag_string

      rescale_notes(post)
      update_ugoira_frame_data(post, upload)

      if md5_changed
        Comment.create!(post: post, creator: User.system, body: comment_replacement_message(post, replacement), do_not_bump_post: true, creator_ip_addr: "127.0.0.1")
      else
        purge_cached_urls(post)
      end

      replacement.save!
      post.save!

      post.update_iqdb_async
    end

    def purge_cached_urls(post)
      urls = [
        post.preview_file_url,
        post.large_file_url,
        post.file_url,
        post.tagged_large_file_url,
        post.tagged_file_url
      ]

      CloudflareService.new.purge_cache(urls)
    end

    def rescale_notes(post)
      x_scale = post.image_width.to_f  / post.image_width_was.to_f
      y_scale = post.image_height.to_f / post.image_height_was.to_f

      post.notes.each do |note|
        note.rescale!(x_scale, y_scale)
      end
    end

    def update_ugoira_frame_data(post, upload)
      post.pixiv_ugoira_frame_data.destroy if post.pixiv_ugoira_frame_data.present?

      unless post.is_ugoira?
        return
      end

      PixivUgoiraFrameData.create(
        post_id: post.id,
        data: upload.context["ugoira"]["frame_data"],
        content_type: upload.context["ugoira"]["content_type"]
      )
    end
  end
end
