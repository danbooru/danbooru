require 'upload_service/controller_helper'
require 'upload_service/preprocessor'
require 'upload_service/replacer'
require 'upload_service/utils'

class UploadService
  attr_reader :params, :post, :upload

  def initialize(params)
    @params = params
  end

  def delayed_start(uploader_id)
    CurrentUser.as(uploader_id) do
      start!
    end
  rescue ActiveRecord::RecordNotUnique
  end

  def start!
    preprocessor = Preprocessor.new(params)

    if preprocessor.in_progress?
      UploadServiceDelayedStartJob.set(wait: 5.seconds).perform_later(params, CurrentUser.user)
      return preprocessor.predecessor
    end

    if preprocessor.completed?
      @upload = preprocessor.finish!

      begin
        create_post_from_upload(@upload)
      rescue Exception => e
        @upload.update(status: "error: #{e.class} - #{e.message}", backtrace: e.backtrace.join("\n"))
      end
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

      @upload.file = Utils.get_file_for_upload(@upload, file: @upload.file&.tempfile)
      Utils.process_file(upload, @upload.file)

      @upload.save!
      @post = create_post_from_upload(@upload)
      @upload
    rescue Exception => e
      @upload.update(status: "error: #{e.class} - #{e.message}", backtrace: e.backtrace.join("\n"))
      @upload
    end
  end

  def warnings
    return [] if @post.nil?
    @post.warnings.full_messages
  end

  def create_post_from_upload(upload)
    @post = convert_to_post(upload)
    @post.save!

    if upload.context && upload.context["ugoira"]
      PixivUgoiraFrameData.create(
        post_id: @post.id,
        data: upload.context["ugoira"]["frame_data"],
        content_type: upload.context["ugoira"]["content_type"]
      )
    end

    if upload.has_commentary?
      @post.create_artist_commentary(
        :original_title => upload.artist_commentary_title,
        :original_description => upload.artist_commentary_desc,
        :translated_title => upload.translated_commentary_title,
        :translated_description => upload.translated_commentary_desc
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
      if upload.source.present?
        p.source = Sources::Strategies.find(upload.source, upload.referer_url).canonical_url || upload.source
      end
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
