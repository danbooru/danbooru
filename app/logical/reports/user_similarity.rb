module Reports
  class UserSimilarity
    NOT_READY_STRING = "not ready"

    attr_reader :user_id, :result

    def initialize(user_id)
      @user_id = user_id
    end

    def user
      User.find(user_id)
    end

    def prime(endpoint = "user_similarity")
      10.times do
        @result = fetch_similar_user_ids(endpoint)
        if @result == NOT_READY_STRING
          sleep(60)
        else
          break
        end
      end
    end

    def fetch_similar_user_ids(endpoint = "user_similarity")
      raise NotImplementedError.new("the Reportbooru service isn't configured. User similarity is not available.") unless Danbooru.config.reportbooru_server

      params = {
        "key" => Danbooru.config.reportbooru_key,
        "user_id" => user_id
      }
      uri = URI.parse("#{Danbooru.config.reportbooru_server}/reports/#{endpoint}")
      uri.query = URI.encode_www_form(params)

      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
        resp = http.request_get(uri.request_uri)
        if resp.is_a?(Net::HTTPSuccess)
          resp.body
        else
          raise "HTTP error code: #{resp.code} #{resp.message}"
        end
      end
    end
  end
end
