class Download
  class Error < Exception ; end
  
  attr_accessor :source, :content_type, :file_path
  
  def initialize(source, file_path)
    @source = source
    @file_path = file_path
  end
  
  def download!
    http_get_streaming do |response|
      self.content_type = response["Content-Type"]
      File.open(file_path, "wb") do |out|
        response.read_body(out)
      end
    end
    after_download
  end
  
  def pixiv_rewrite(headers)
    return unless source =~ /pixiv\.net/

    headers["Referer"] = "http://www.pixiv.net"
    
    # Don't download the small version
    if source =~ %r!(/img/.+?/.+?)_m.+$!
      match = $1
      source.sub!(match + "_m", match)
    end
    
    # Download the big version if it exists
    if source =~ %r!(\d+_p\d+)\.!
      match = $1
      repl = match.sub(/_p/, "_big_p")
      big_source = source.sub(match, repl)
      if pixiv_http_exists?(big_source)
        self.source = big_source
      end
    end
  end
  
  def pixiv_http_exists?
    # example: http://img01.pixiv.net/img/as-special/15649262_big_p2.jpg
    exists = false
    uri = URI.parse(source)
    Net::HTTP.start(uri.host, uri.port) do |http|
      headers = {"Referer" => "http://www.pixiv.net", "User-Agent" => "#{Danbooru.config.app_name}/#{Danbooru.config.version}"}
      http.request_head(uri.request_uri, headers) do |res|
        if res.is_a?(Net::HTTPSuccess)
          exists = true
        end
      end
    end
    exists
  end
  
  def before_download(headers)
    pixiv_rewrite(headers)
  end
  
  def after_download
    fix_image_board_sources
  end
  
  def http_get_streaming(options = {})
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
        before_download(headers)
        url = URI.parse(source)
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
  
  def fix_image_board_sources
    if source =~ /\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
      self.source = "Image board"
    end
  end
end
