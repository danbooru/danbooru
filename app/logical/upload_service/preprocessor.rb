class UploadService
  class Preprocessor
    extend Memoist

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

    def referer_url
      params[:referer_url]
    end

    def strategy
      Sources::Strategies.find(source, referer_url)
    end
    memoize :strategy

    # When searching posts we have to use the canonical source
    def canonical_source
      strategy.canonical_url
    end
    memoize :canonical_source

    def in_progress?
      if md5.present?
        return Upload.where(status: "preprocessing", md5: md5).exists?
      end

      if Utils.is_downloadable?(source)
        return Upload.where(status: "preprocessing", source: source).exists?
      end

      false
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

    def delayed_start(uploader_id)
      CurrentUser.as(uploader_id) do
        start!
      end
    rescue ActiveRecord::RecordNotUnique
    end

    def start!
      raise NotImplementedError, "No login credentials configured for #{strategy.site_name}." unless strategy.class.enabled?

      if Utils.is_downloadable?(source)
        if Post.system_tag_match("source:#{canonical_source}").where.not(id: original_post_id).exists?
          raise ActiveRecord::RecordNotUnique, "A post with source #{canonical_source} already exists"
        end

        if Upload.where(source: source, status: "completed").exists?
          raise ActiveRecord::RecordNotUnique, "A completed upload with source #{source} already exists"
        end

        if Upload.where(source: source).where("status like ?", "error%").exists?
          raise ActiveRecord::RecordNotUnique, "An errored upload with source #{source} already exists"
        end
      end

      params[:rating] ||= "q"
      params[:tag_string] ||= "tagme"
      upload = Upload.create!(params)

      begin
        upload.update(status: "preprocessing")

        file = Utils.get_file_for_upload(upload, file: params[:file]&.tempfile)
        Utils.process_file(upload, file, original_post_id: original_post_id)

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
