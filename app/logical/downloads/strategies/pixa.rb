module Downloads
  module Strategies
    class Pixa < Base
      def rewrite(url, headers)
        if url =~ /https?:\/\/(?:\w+\.)?pixa\.cc/
          url, headers = rewrite_headers(url, headers)
        end
        
        return [url, headers]
      end
    
    protected
      def rewrite_headers(url, headers)
        headers["Referer"] = "http://www.pixa.cc"
        return [url, headers]
      end
    end
  end
end
