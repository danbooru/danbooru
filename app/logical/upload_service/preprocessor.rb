class UploadService
  class Preprocessor
    extend Memoist

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

    def referer_url
      params[:referer_url]
    end

    def in_progress?
      if md5.present?
        Upload.exists?(status: "preprocessing", md5: md5)
      elsif Utils.is_downloadable?(source)
        Upload.exists?(status: "preprocessing", source: source)
      else
        false
      end
    end

    def predecessor
      if md5.present?
        Upload.where(status: ["preprocessed", "preprocessing"], md5: md5).first
      elsif Utils.is_downloadable?(source)
        Upload.where(status: ["preprocessed", "preprocessing"], source: source).first
      end
    end

    def completed?
      predecessor.present?
    end

    def delayed_start(uploader)
      CurrentUser.scoped(uploader) do
        start!
      end
    rescue ActiveRecord::RecordNotUnique
    end

    def start!
      params[:rating] ||= "q"
      params[:tag_string] ||= "tagme"
      upload = Upload.create!(params)

      begin
        upload.update(status: "preprocessing")

        file = Utils.get_file_for_upload(upload.source_url, upload.referer_url, params[:file]&.tempfile)
        Utils.process_file(upload, file)

        upload.rating = params[:rating]
        upload.tag_string = params[:tag_string]
        upload.status = "preprocessed"
        upload.save!
      rescue Exception => e
        upload.update(file_ext: nil, status: "error: #{e.class} - #{e.message}", backtrace: e.backtrace.join("\n"))
      end

      upload
    end

    def finish!(upload = nil)
      pred = upload || predecessor

      # regardless of who initialized the upload, credit should
      # goto whoever submitted the form
      pred.initialize_attributes

      pred.attributes = params

      # if a file was uploaded after the preprocessing occurred,
      # then process the file and overwrite whatever the preprocessor
      # did
      Utils.process_file(pred, pred.file.tempfile) if pred.file.present?

      pred.status = "completed"
      pred.save
      pred
    end
  end
end
