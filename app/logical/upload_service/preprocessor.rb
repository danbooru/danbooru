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
        return Upload.where(status: ["preprocessed", "preprocessing"], md5: md5).first
      end

      if Utils.is_downloadable?(source)
        return Upload.where(status: ["preprocessed", "preprocessing"], source: source).first
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
          if Post.tag_match("source:#{canonical_source}").where.not(id: original_post_id).exists?
            raise ActiveRecord::RecordNotUnique.new("A post with source #{canonical_source} already exists")
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
      upload = Upload.create!(params)

      begin
        upload.update(status: "preprocessing")

        file = Utils.get_file_for_upload(upload, file: params[:file])
        Utils.process_file(upload, file, original_post_id: original_post_id)

        upload.rating = params[:rating]
        upload.tag_string = params[:tag_string]
        upload.status = "preprocessed"
        upload.save!
      rescue Exception => x
        upload.update(file_ext: nil, status: "error: #{x.class} - #{x.message}", backtrace: x.backtrace.join("\n"))
      end

      return upload
    end

    def finish!(upload = nil)
      pred = upload || self.predecessor

      # regardless of who initialized the upload, credit should
      # goto whoever submitted the form
      pred.initialize_attributes

      pred.attributes = self.params

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
