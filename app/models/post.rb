class Post < ActiveRecord::Base
  class Deletion < ActiveRecord::Base
    set_table_name "deleted_posts"
  end
  
  class Pending < ActiveRecord::Base
    class Error < Exception ; end
    
    class Download
      class Error < Exception ; end
      
      attr_accessible :source, :content_type
      
      def initialize(source, file_path)
        @source = source
        @file_path = file_path
      end

      # Downloads to @file_path
      def download!
        http_get_streaming(@source) do |response|
          self.content_type = response["Content-Type"]
          File.open(@file_path, "wb") do |out|
            response.read_body(out)
          end
        end
        @source = fix_image_board_sources(@source)
      end
  
    private
      def handle_pixiv(source, headers)
        if source =~ /pixiv\.net/
          headers["Referer"] = "http://www.pixiv.net"

          # Don't download the small version
          if source =~ %r!(/img/.+?/.+?)_m.+$!
            match = $1
            source.sub!(match + "_m", match)
          end
        end
      
        source
      end
    
      def http_get_streaming(source, options = {})
        max_size = options[:max_size] || Danbooru.config.max_file_size
        max_size = nil if max_size == 0 # unlimited
        limit = 4

        while true
          url = URI.parse(source)

          unless url.is_a?(URI::HTTP)
            raise Error.new("URL must be HTTP")
          end

          Net::HTTP.start(url.host, url.port) do |http|
            http.read_timeout = 10
            headers = {
              "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
            }
            source = handle_pixiv(source, headers)
            http.request_get(url.request_uri, headers) do |res|
              case res
              when Net::HTTPSuccess then
                if max_size
                  len = res["Content-Length"]
                  raise Error.new("File is too large (#{len} bytes)") if len && len.to_i > max_size
                end
                yield(res)
                return

              when Net::HTTPRedirection then
                if limit == 0 then
                  raise Error.new("Too many redirects")
                end
                source = res["location"]
                limit -= 1

              else
                raise Error.new("HTTP error code: #{res.code} #{res.message}")
              end
            end # http.request_get
          end # http.start
        end # while
      end # def
    
      def fix_image_board_sources(source)
        if source =~ /\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
          "Image board"
        else
          source
        end
      end
    end # download
    
    set_table_name "pending_posts"
    belongs_to :post
    attr_accessible :file, :image_width, :image_height
    
    def process!
      update_attribute(:status, "processing")
      
      if file
        convert_cgi_file(temp_file_path)
      elsif is_downloadable?
        download_from_source(temp_file_path)
      end
      
      calculate_hash(temp_file_path)
      move_file
      calculate_dimensions
      generate_resizes
      convert_to_post
      update_attribute(:status, "finished")
    end
    
  private
    def generate_resizes
      generate_resize_for(Danbooru.config.small_image_width)
      generate_resize_for(Danbooru.config.medium_image_width)
      generate_resize_for(Danbooru.config.large_image_width)
    end
  
    def create_resize_for(width)
      return if width.nil?
      return unless image_width > width

      unless File.exists?(final_file_path)
        raise Error.new("file not found")
      end

      size = Danbooru.reduce_to({:width => image_width, :height => image_height}, {:width => width})

      # If we're not reducing the resolution, only reencode if the source image larger than
      # 200 kilobytes.
      if size[:width] == width && size[:height] == height && File.size?(path) > 200.kilobytes
        return true
      end

      begin
        Danbooru.resize(file_ext, final_file_path, resize_file_path_for(width), size, 90)
      rescue Exception => x
        errors.add "sample", "couldn't be created: #{x}"
        return false
      end

      self.sample_width = size[:width]
      self.sample_height = size[:height]
      return true
    end
    
    def resize_file_path_for(width)
      case width
      when Danbooru.config.small_image_width
        "#{Rails.root}/public/data/preview"
        
      when Danbooru.config.medium_image_width
        "#{Rails.root}/public/data/medium"        
        
      when Danbooru.config.large_image_width
        "#{Rails.root}/public/data/large"
      end
    end
    
    def convert_to_post
      returning Post.new do |p|
        p.tag_string = tag_string
        p.md5 = md5
        p.file_ext = file_ext
        p.image_width = image_width
        p.image_height = image_height
        p.uploader_id = uploader_id
        p.uploader_ip_addr = uploader_ip_addr
        p.rating = rating
        p.source = source
      end
    end

    def calculate_dimensions(post)
      if has_dimensions?
        image_size = ImageSize.new(File.open(final_file_path, "rb"))
        self.image_width = image_size.get_width
        self.image_hegiht = image_hegiht.get_height
      end
    end
    
    def has_dimensions?
      %w(jpg gif png swf).include?(file_ext)
    end
    
    def move_file
      FileUtils.mv(temp_file_path, final_file_path)
    end
  
    def final_file_path
      "#{Rails.root}/public/data/original/#{md5}.#{file_ext}"
    end
  
    # Calculates the MD5 based on whatever is in temp_file_path
    def calculate_hash(file_path)
      self.md5 = Digest::MD5.file(file_path).hexdigest
    end
  
    # Moves the cgi file to file_path
    def convert_cgi_file(file_path)
      return if file.blank? || file.size == 0

      if file.local_path
        FileUtils.mv(file.local_path, file_path)
      else
        File.open(file_path, 'wb') do |out| 
          out.write(file.read)
        end
      end
      self.file_ext = content_type_to_file_ext(file.content_type) || find_ext(file.original_filename)
    end

    # Determines whether the source is downloadable
    def is_downloadable?
      source =~ /^http:\/\// && file.blank?
    end

    # Downloads the file to file_path
    def download_from_source(file_path)
      download = Download.new(source, file_path)
      download.download!
      self.file_ext = content_type_to_file_ext(download.content_type) || find_ext(source)
    end
    
    # Converts a content type string to a file extension
    def content_type_to_file_ext(content_type)
      case content_type
      when /jpeg/
        return "jpg"

      when /gif/
        return "gif"

      when /png/
        return "png"

      when /x-shockwave-flash/
        return "swf"

      else
        nil
      end
    end

    # Determines the file extention based on a path, normalizing if necessary
    def find_ext(file_path)
      ext = File.extname(file_path)
      if ext.blank?
        return "txt"
      else
        ext = ext[1..-1].downcase
        ext = "jpg" if ext == "jpeg"
        return ext
      end
    end
    
    # Path to a temporary file
    def temp_file_path
      @temp_file ||= Tempfile.new("danbooru-upload-#{$PROCESS_ID}")
      @temp_file.path
    end
  end
end
