class UploadService
  module ControllerHelper
    def self.prepare(url: nil, file: nil, ref: nil)
      upload = Upload.new

      if Utils.is_downloadable?(url) && file.nil?
        # this gets called from UploadsController#new so we need to preprocess async
        Preprocessor.new(source: url, referer_url: ref).delay(priority: -1, queue: "default").delayed_start(CurrentUser.id)

        begin
          download = Downloads::File.new(url, ref)
          remote_size = download.size
        rescue Exception
        end

        return [upload, remote_size]
      end

      if file
        # this gets called via XHR so we can process sync
        Preprocessor.new(file: file).delayed_start(CurrentUser.id)
      end

      return [upload]
    end
  end
end
