module Downloads
  module Strategies
    class Moebooru < Base
      DOMAINS = '(?:[^.]+\.)?yande\.re|konachan\.com'

      def rewrite(url, headers)
        if url =~ %r{https?://(?:#{DOMAINS})}
          url, headers = rewrite_jpeg_versions(url, headers)
        end

        return [url, headers]
      end

    protected
      def rewrite_jpeg_versions(url, headers)
        # example: https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg 

        if url =~ %r{\A(https?://(?:#{DOMAINS}))/jpeg/([a-f0-9]+/.+)\.jpg\Z}
          url = $1 + "/image/" + $2 + ".png"
        end

        return [url, headers]
      end
    end
  end
end
