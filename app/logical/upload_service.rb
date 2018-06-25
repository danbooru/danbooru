class UploadService
  module ControllerHelper
    def self.prepare(url: nil, file: nil, ref: nil)
      upload = Upload.new

      if Utils.is_downloadable?(url) && file.nil?
        download = Downloads::File.new(url)
        normalized_url, _, _ = download.before_download(url, {})
        post = if normalized_url.nil?
          Post.where("SourcePattern(lower(posts.source)) = ?", url).first
        else
          Post.where("SourcePattern(lower(posts.source)) IN (?)", [url, normalized_url]).first
        end

        if post.nil?
          # this gets called from UploadsController#new so we need
          # to preprocess async
          Preprocessor.new(source: url).delay(queue: "default").start!(CurrentUser.user.id)
        end

        begin
          source = Sources::Site.new(url, :referer_url => ref)
          remote_size = download.size
        rescue Exception
        end

        return [upload, post, source, normalized_url, remote_size]
      elsif file
        # this gets called via XHR so we can process sync
        Preprocessor.new(file: file).start!((CurrentUser.user.id))
      end

      return [upload]
    end

    def self.batch(url, ref = nil)
      if url
        source = Sources::Site.new(url, :referer_url => ref)
        source.get
        return source
      end
    end
  end

  module Utils
    def self.file_header_to_file_ext(file)
      case File.read(file.path, 16)
      when /^\xff\xd8/n
        "jpg"
      when /^GIF87a/, /^GIF89a/
        "gif"
      when /^\x89PNG\r\n\x1a\n/n
        "png"
      when /^CWS/, /^FWS/, /^ZWS/
        "swf"
      when /^\x1a\x45\xdf\xa3/n
        "webm"
      when /^....ftyp(?:isom|3gp5|mp42|MSNV|avc1)/
        "mp4"
      when /^PK\x03\x04/
        "zip"
      else
        "bin"
      end
    end

    def self.delete_file(md5, file_ext, upload_id = nil)
      if Post.where(md5: md5).exists?
        if upload_id
          CurrentUser.as_system do
            Upload.find(upload_id).update(status: "completed")
          end
        end

        return
      end

      if upload_id
        CurrentUser.as_system do
          Upload.find(upload_id).update(status: "preprocessed + deleted")
        end
      end

      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :original)
      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :large)
      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :preview)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :original)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :large)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :preview)
    end

    def self.calculate_ugoira_dimensions(source_path)
      folder = Zip::File.new(source_path)
      Tempfile.open("ugoira-dim-") do |tempfile|
        folder.first.extract(tempfile.path) { true }
        image_size = ImageSpec.new(tempfile.path)
        return [image_size.width, image_size.height]
      end
    end

    def self.calculate_dimensions(upload, file)
      if upload.is_video?
        video = FFMPEG::Movie.new(file.path)
        yield(video.width, video.height)

      elsif upload.is_ugoira?
        w, h = calculate_ugoira_dimensions(file.path)
        yield(w, h)

      else
        image_size = ImageSpec.new(file.path)
        yield(image_size.width, image_size.height)
      end
    end

    def self.distribute_files(file, record, type)
      # need to do this for hybrid storage manager
      post = Post.new
      post.md5 = record.md5
      post.file_ext = record.file_ext
      [Danbooru.config.storage_manager, Danbooru.config.backup_storage_manager].each do |sm|
        sm.store_file(file, post, type)
      end
    end

    def self.is_downloadable?(source)
      source =~ /^https?:\/\//
    end

    def self.generate_resizes(file, upload)
      if upload.is_video?
        video = FFMPEG::Movie.new(file.path)
        crop_file = generate_video_preview_for(video, Danbooru.config.small_image_width, Danbooru.config.small_image_width)
        preview_file = generate_video_preview_for(video, Danbooru.config.small_image_width, Danbooru.config.small_image_width)

      elsif upload.is_ugoira?
        preview_file = PixivUgoiraConverter.generate_preview(file)
        crop_file = PixivUgoiraConverter.generate_crop(file)
        sample_file = PixivUgoiraConverter.generate_webm(file, upload.context["ugoira"]["frame_data"])

      elsif upload.is_image?
        preview_file = DanbooruImageResizer.resize(file, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 85)
        crop_file = DanbooruImageResizer.crop(file, Danbooru.config.small_image_width, 85)
        if upload.image_width > Danbooru.config.large_image_width
          sample_file = DanbooruImageResizer.resize(file, Danbooru.config.large_image_width, upload.image_height, 90)
        end
      end

      [preview_file, crop_file, sample_file]
    end

    def self.generate_video_preview_for(video, width, height)
      dimension_ratio = video.width.to_f / video.height
      if dimension_ratio > 1
        height = (width / dimension_ratio).to_i
      else
        width = (height * dimension_ratio).to_i
      end

      output_file = Tempfile.new(["video-preview", ".jpg"], binmode: true)
      video.screenshot(output_file.path, {:seek_time => 0, :resolution => "#{width}x#{height}"})
      output_file
    end

    def self.process_file(upload, file)
      upload.file = file
      upload.file_ext = Utils.file_header_to_file_ext(file)
      upload.file_size = file.size
      upload.md5 = Digest::MD5.file(file.path).hexdigest

      if Post.where(md5: upload.md5).exists?
        # abort early if this post already exists
        raise Upload::Error.new("Post with MD5 #{upload.md5} already exists")
      end

      Utils.calculate_dimensions(upload, file) do |width, height|
        upload.image_width = width
        upload.image_height = height
      end

      upload.tag_string = "#{upload.tag_string} #{Utils.automatic_tags(upload, file)}"

      preview_file, crop_file, sample_file = Utils.generate_resizes(file, upload)

      begin
        Utils.distribute_files(file, upload, :original)
        Utils.distribute_files(sample_file, upload, :large) if sample_file.present?
        Utils.distribute_files(preview_file, upload, :preview) if preview_file.present?
        Utils.distribute_files(crop_file, upload, :crop) if crop_file.present?
      ensure
        preview_file.try(:close!)
        crop_file.try(:close!)
        sample_file.try(:close!)
      end

      # in case this upload never finishes processing, we need to delete the
      # distributed files in the future
      Danbooru.config.other_server_hosts.each do |host|
        UploadService::Utils.delay(queue: host, run_at: 30.minutes.from_now).delete_file(upload.md5, upload.file_ext, upload.id)
      end
    end

    # these methods are only really used during upload processing even 
    # though logically they belong on upload. post can rely on the 
    # automatic tag that's added.
    def self.is_animated_gif?(upload, file)
      return false if upload.file_ext != "gif"

      # Check whether the gif has multiple frames by trying to load the second frame.
      result = Vips::Image.gifload(file.path, page: 1) rescue $ERROR_INFO
      if result.is_a?(Vips::Image)
        true
      elsif result.is_a?(Vips::Error) && result.message =~ /too few frames in GIF file/
        false
      else
        raise result
      end
    end

    def self.is_animated_png?(upload, file)
      upload.file_ext == "png" && APNGInspector.new(file.path).inspect!.animated?
    end

    def self.is_video_with_audio?(upload, file)
      video = FFMPEG::Movie.new(file.path)
      upload.is_video? && video.audio_channels.present?
    end

    def self.automatic_tags(upload, file)
      return "" unless Danbooru.config.enable_dimension_autotagging

      tags = []
      tags << "video_with_sound" if is_video_with_audio?(upload, file)
      tags << "animated_gif" if is_animated_gif?(upload, file)
      tags << "animated_png" if is_animated_png?(upload, file)
      tags.join(" ")
    end

    def self.download_from_source(source, referer_url: nil)
      download = Downloads::File.new(source, referer_url: referer_url)
      file = download.download!
      context = {
        downloaded_source: download.downloaded_source,
        source: download.source
      }

      if download.data[:is_ugoira]
        context[:ugoira] = {
          frame_data: download.data[:ugoira_frame_data],
          content_type: download.data[:ugoira_content_type]
        }
      end

      yield(context)

      return file
    end

    def self.download_for_upload(source, upload)
      file = download_from_source(source, referer_url: upload.referer_url) do |context|
        upload.downloaded_source = context[:downloaded_source]
        upload.source = context[:source]

        if context[:ugoira]
          upload.context = { ugoira: context[:ugoira] }
        end
      end

      return file
    end
  end

  class Preprocessor
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def source
      params[:source]
    end

    def md5
      params[:md5_confirmation]
    end

    def in_progress?
      if Utils.is_downloadable?(source)
        Upload.where(status: "preprocessing", source: source).exists?
      elsif md5.present?
        Upload.where(status: "preprocessing", md5: md5).exists?
      else
        false
      end
    end

    def predecessor
      if Utils.is_downloadable?(source)
        Upload.where(status: ["preprocessed", "preprocessing"], source: source).first
      elsif md5.present?
        Upload.where(status: ["preprocessed", "preprocessing"], md5: md5).first
      end
    end

    def completed?
      predecessor.present?
    end

    def start!(uploader_id)
      if Utils.is_downloadable?(source)
        CurrentUser.as_system do
          if Post.tag_match("source:#{source}").exists?
            raise ActiveRecord::RecordNotUnique.new("A post with source #{source} already exists")
          end
        end

        if Upload.where(source: source, status: "completed").exists?
          raise ActiveRecord::RecordNotUnique.new("A completed upload with source #{source} already exists")
        end

        if Upload.where(source: source).where("status like ?", "error%").exists?
          raise ActiveRecord::RecordNotUnique.new("An errored upload with source #{source} already exists")
        end
      end

      params[:rating] ||= "q"
      params[:tag_string] ||= "tagme"

      CurrentUser.as(User.find(uploader_id)) do
        begin
          upload = Upload.create!(params)
          upload.update(status: "preprocessing")

          if source.present?
            file = Utils.download_for_upload(source, upload)
          elsif params[:file].present?
            file = params[:file]
          end

          Utils.process_file(upload, file)

          upload.rating = params[:rating]
          upload.tag_string = params[:tag_string]
          upload.status = "preprocessed"
          upload.save!
        rescue Exception => x
          upload.update(status: "error: #{x.class} - #{x.message}", backtrace: x.backtrace.join("\n"))
        end

        return upload
      end
    end

    def finish!(upload = nil)
      pred = upload || self.predecessor()

      # regardless of who initialized the upload, credit should goto whoever submitted the form
      pred.initialize_attributes

      pred.attributes = self.params
      pred.status = "completed"
      pred.save
      return pred
    end
  end

  class Replacer
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

    def process!
      preprocessor = Preprocessor.new(
        rating: post.rating,
        tag_string: replacement.tags,
        source: replacement.replacement_url,
        file: replacement.replacement_file
      )
      upload = preprocessor.start!(CurrentUser.id)
      return if upload.is_errored?
      upload = preprocessor.finish!(upload)
      return if upload.is_errored?
      md5_changed = upload.md5 != post.md5
      
      if replacement.replacement_file.present?
        replacement.replacement_url = "file://#{replacement.replacement_file.original_filename}"
      elsif upload.downloaded_source.present?
        replacement.replacement_url = upload.downloaded_source
      end

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
      post.source = upload.downloaded_source || upload.source
      post.tag_string = upload.tag_string

      update_ugoira_frame_data(post, upload)

      if md5_changed
        CurrentUser.as(User.system) do
          post.comments.create!(body: comment_replacement_message(post, replacement), do_not_bump_post: true)
        end
      end

      if replacement.final_source.present?
        post.update(source: replacement.final_source)
      end

      replacement.save!
      post.save!

      rescale_notes(post)
    end

    def rescale_notes(post)
      x_scale = post.image_width.to_f  / post.image_width_before_last_save.to_f
      y_scale = post.image_height.to_f / post.image_height_before_last_save.to_f

      post.notes.each do |note|
        note.reload
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

  attr_reader :params, :post, :upload

  def initialize(params)
    @params = params
  end

  def start!
    preprocessor = Preprocessor.new(params)

    if preprocessor.in_progress?
      delay(queue: "default", run_at: 5.seconds.from_now).start!
      return preprocessor.predecessor
    end

    if preprocessor.completed?
      @upload = preprocessor.finish!
      create_post_from_upload(@upload)
      return @upload
    end

    params[:rating] ||= "q"
    params[:tag_string] ||= "tagme"
    @upload = Upload.create!(params)

    begin
      if @upload.invalid?
        return @upload
      end

      @upload.update(status: "processing")

      if @upload.file.nil? && Utils.is_downloadable?(source)
        @upload.file = Utils.download_for_upload(source, @upload)
      end

      if @upload.file.present?
        Utils.process_file(upload, @upload.file)
      end

      @upload.save!
      @post = create_post_from_upload(@upload)
      return @upload

    rescue Exception => x
      @upload.update(status: "error: #{x.class} - #{x.message}", backtrace: x.backtrace.join("\n"))
      @upload
    end
  end

  def warnings
    return [] if @post.nil?
    return @post.warnings.full_messages
  end

  def source
    params[:source]
  end

  def include_artist_commentary?
    params[:include_artist_commentary].to_s.truthy?
  end

  def create_post_from_upload(upload)
    @post = convert_to_post(upload)
    @post.save!

    upload.update(status: "error: " + @post.errors.full_messages.join(", "))

    if upload.context && upload.context["ugoira"]
      PixivUgoiraFrameData.create(
        post_id: @post.id,
        data: upload.context["ugoira"]["frame_data"],
        content_type: upload.context["ugoira"]["content_type"]
      )
    end

    if include_artist_commentary?
      @post.create_artist_commentary(
        :original_title => params[:artist_commentary_title],
        :original_description => params[:artist_commentary_desc]
      )
    end

    upload.update(status: "completed", post_id: @post.id)
    @post
  end

  def convert_to_post(upload)
    Post.new.tap do |p|
      p.has_cropped = true
      p.tag_string = upload.tag_string
      p.md5 = upload.md5
      p.file_ext = upload.file_ext
      p.image_width = upload.image_width
      p.image_height = upload.image_height
      p.rating = upload.rating
      p.source = upload.source
      p.file_size = upload.file_size
      p.uploader_id = upload.uploader_id
      p.uploader_ip_addr = upload.uploader_ip_addr
      p.parent_id = upload.parent_id

      if !upload.uploader.can_upload_free? || upload.upload_as_pending?
        p.is_pending = true
      end
    end
  end
end
