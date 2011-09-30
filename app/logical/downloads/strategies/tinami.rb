module Downloads
  module Strategies
    class Tinami < Base
      def rewrite(url, headers)
        if url =~ /https?:\/\/(?:\w+\.)?tinami\.com/
          url, headers = rewrite_headers(url, headers)
        end
        
        return [url, headers]
      end
    
    protected
      def rewrite_headers(url, headers)
        headers["Referer"] = "http://www.tinami.com/view"
        return [url, headers]
      end
    end
  end
end
