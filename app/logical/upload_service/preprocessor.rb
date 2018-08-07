class UploadService
  class Preprocessor
    attr_reader :params, :original_post_id

    def initialize(params)
      @original_post_id = params.delete(:original_post_id) || -1
      @params = params
    end

    def source
      params[:source]
    end

    def md5
      params[:md5_confirmation]
    end

    def referer
      params[:referer_url]
    end

    def normalized_source
      @normalized_source ||= begin
        Downloads::File.new(params[:source]).rewrite_url
      end
    end

    def in_progress?
      if Utils.is_downloadable?(source)
        Upload.where(status: "preprocessing", source: normalized_source).or(Upload.where(status: "preprocessing", alt_source: normalized_source)).exists?
      elsif md5.present?
        Upload.where(status: "preprocessing", md5: md5).exists?
      else
        false
      end
    end

    def predecessor
      if Utils.is_downloadable?(source)
        Upload.where(status: ["preprocessed", "preprocessing"]).where(source: normalized_source).or(Upload.where(status: ["preprocessed", "preprocessing"], alt_source: normalized_source)).first
      elsif md5.present?
        Upload.where(status: ["preprocessed", "preprocessing"], md5: md5).first
      end
    end

    def completed?
      predecessor.present?
    end

    def delayed_start(uploader_id)
      CurrentUser.as(uploader_id) do
        start!
      end

    rescue ActiveRecord::RecordNotUnique
      return
    end

    def start!
      if Utils.is_downloadable?(source)
        CurrentUser.as_system do
          if Post.tag_match("source:#{normalized_source}").where.not(id: original_post_id).exists?
            raise ActiveRecord::RecordNotUnique.new("A post with source #{normalized_source} already exists")
          end
        end

        if Upload.where(source: normalized_source, status: "completed").exists?
          raise ActiveRecord::RecordNotUnique.new("A completed upload with source #{normalized_source} already exists")
        end

        if Upload.where(source: normalized_source).where("status like ?", "error%").exists?
          raise ActiveRecord::RecordNotUnique.new("An errored upload with source #{normalized_source} already exists")
        end
      end

      params[:rating] ||= "q"
      params[:tag_string] ||= "tagme"

      upload = Upload.create!(params)
      begin
        upload.update(status: "preprocessing")

        if Utils.is_downloadable?(source)
          # preserve the original source (for twitter, the twimg:orig
          # source, while the status url is stored in upload.source)
          upload.alt_source = normalized_source 
          file = Utils.download_for_upload(source, upload)
        elsif params[:file].present?
          file = params[:file]
        end

        Utils.process_file(upload, file, original_post_id: original_post_id)

        upload.rating = params[:rating]
        upload.tag_string = params[:tag_string]
        upload.status = "preprocessed"
        upload.save!
      rescue Exception => x
        upload.update(status: "error: #{x.class} - #{x.message}", backtrace: x.backtrace.join("\n"))
      end

      return upload
    end

    def finish!(upload = nil)
      pred = upload || self.predecessor()

      # regardless of who initialized the upload, credit should 
      # goto whoever submitted the form
      pred.initialize_attributes

      # we went through a lot of trouble normalizing the source,
      # so don't overwrite it with whatever the user provided
      pred.source = "" if pred.source.nil?
      pred.attributes = self.params.except(:source)

      # if a file was uploaded after the preprocessing occurred,
      # then process the file and overwrite whatever the preprocessor
      # did
      Utils.process_file(pred, pred.file) if pred.file.present?

      pred.status = "completed"
      pred.save
      return pred
    end
  end

end
