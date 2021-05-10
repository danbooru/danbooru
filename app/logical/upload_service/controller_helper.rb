class UploadService
  module ControllerHelper
    def self.prepare(url: nil, file: nil, ref: nil)
      upload = Upload.new

      if Utils.is_downloadable?(url) && file.nil?
        # this gets called from UploadsController#new so we need to preprocess async
        UploadPreprocessorDelayedStartJob.perform_later(url, ref, CurrentUser.user)

        strategy = Sources::Strategies.find(url, ref)
        remote_size = strategy.remote_size

        return [upload, remote_size]
      end

      if file
        # this gets called via XHR so we can process sync
        Preprocessor.new(file: file).delayed_start(CurrentUser.id)
      end

      [upload]
    end
  end
end
