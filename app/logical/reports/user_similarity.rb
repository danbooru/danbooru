module Reports
  class UserSimilarity
    NOT_READY_STRING = "not ready"

    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def user
      User.find(user_id)
    end

    def prime
      10.times do
        if fetch_similar_user_ids == NOT_READY_STRING
          sleep(60)
        else
          break
        end
      end
    end

    def fetch_similar_user_ids
      return NotImplementedError unless Danbooru.config.report_server

      params = {
        "key" => Danbooru.config.shared_remote_key,
        "user_id" => user_id
      }
      uri = URI.parse("#{Danbooru.config.report_server}/reports/user_similarity")
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
