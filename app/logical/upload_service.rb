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
    return
  end

  def start!
    preprocessor = Preprocessor.new(params)

    if preprocessor.in_progress?
      UploadServiceDelayedStartJob.set(wait: 5.seconds).perform_later(CurrentUser.user)
      return preprocessor.predecessor
    end

    if preprocessor.completed?
      @upload = preprocessor.finish!

      begin
        create_post_from_upload(@upload)
      rescue Exception => x
        @upload.update(status: "error: #{x.class} - #{x.message}", backtrace: x.backtrace.join("\n"))
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

      @upload.file = Utils.get_file_for_upload(@upload, file: @upload.file)
      Utils.process_file(upload, @upload.file)

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

  def include_artist_commentary?
    params[:include_artist_commentary].to_s.truthy?
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
