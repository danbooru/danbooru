module Downloads
  module RewriteStrategies
    class Pawoo < Base
      attr_accessor :url, :source

      def initialize(url)
        @url  = url
      end

      def rewrite(url, headers, data = {})
        if PawooApiClient::Status.is_match?(url)
          client = PawooApiClient.new
          response = client.get_status(url)
          url = response.image_url
        end

        return [url, headers, data]
      end
    end
  end
end
