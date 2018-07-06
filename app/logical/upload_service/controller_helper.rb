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
          Preprocessor.new(source: url).delay(priority: -1, queue: "default").delayed_start(CurrentUser.id)
        end

        begin
          source = Sources::Site.new(url, :referer_url => ref)
          remote_size = download.size
        rescue Exception
        end

        return [upload, post, source, normalized_url, remote_size]
      elsif file
        # this gets called via XHR so we can process sync
        Preprocessor.new(file: file).delayed_start(CurrentUser.id)
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
end