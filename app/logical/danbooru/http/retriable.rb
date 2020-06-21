# A HTTP::Feature that automatically retries requests that return a 429 error
# or a Retry-After header. Usage: `Danbooru::Http.use(:retriable).get(url)`.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After

module Danbooru
  class Http
    class Retriable < HTTP::Feature
      HTTP::Options.register_feature :retriable, self

      attr_reader :max_retries, :max_delay

      def initialize(max_retries: 2, max_delay: 5.seconds)
        @max_retries = max_retries
        @max_delay = max_delay
      end

      def perform(request, &block)
        response = yield request

        retries = max_retries
        while retriable?(response) && retries > 0 && retry_delay(response) <= max_delay
          DanbooruLogger.info "Retrying url=#{request.uri} status=#{response.status} retries=#{retries} delay=#{retry_delay(response)}"

          retries -= 1
          sleep(retry_delay(response))
          response = yield request
        end

        response
      end

      def retriable?(response)
        response.status == 429 || response.headers["Retry-After"].present?
      end

      def retry_delay(response, current_time: Time.zone.now)
        retry_after = response.headers["Retry-After"]

        if retry_after.blank?
          0.seconds
        elsif retry_after =~ /\A\d+\z/
          retry_after.to_i.seconds
        else
          retry_at = Time.zone.parse(retry_after)
          return 0.seconds if retry_at.blank?

          [retry_at - current_time, 0].max.seconds
        end
      end
    end
  end
end
