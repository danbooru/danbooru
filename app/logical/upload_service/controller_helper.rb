class UploadService
  module ControllerHelper
    def self.prepare(url: nil, file: nil, ref: nil)
      upload = Upload.new

      if Utils.is_downloadable?(url) && file.nil?
        strategy = Sources::Strategies.find(url, ref)
        post = Post.where("SourcePattern(lower(posts.source)) IN (?)", [url, strategy.canonical_url]).first

        if post.nil?
          # this gets called from UploadsController#new so we need
          # to preprocess async
          Preprocessor.new(source: url, referer_url: ref).delay(priority: -1, queue: "default").delayed_start(CurrentUser.id)
        end

        begin
          download = Downloads::File.new(url, ref)
          remote_size = download.size
        rescue Exception
        end

        return [upload, post, strategy, remote_size]
      end

      if file
        # this gets called via XHR so we can process sync
        Preprocessor.new(file: file).delayed_start(CurrentUser.id)
      end

      return [upload]
    end

    def self.batch(url, ref = nil)
      if url
        return Sources::Strategies.find(url, ref)
      end
    end
  end
end