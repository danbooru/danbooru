module Danbooru
  class Http
    class Logger < HTTP::Feature
      HTTP::Options.register_feature :logger, self

      attr_reader :logger

      def initialize(logger: ::Logger.new(STDOUT))
        @logger = logger
      end

      def perform(request, &block)
        log_request(request)
        response = yield request
        log_response(request, response)
        response
      end

      def log_request(request)
        logger.info do
          verb = request.verb.to_s.upcase
          headers = request.headers.map { |name, value| "#{name}: #{value}" }.join("\n")
          "> #{verb} #{request.uri}\n#{headers}\n"
        end
      end

      def log_response(request, response)
        logger.info do
          headers = response.headers.map { |name, value| "#{name}: #{value}" }.join("\n")
          "< #{response.status.to_i} | #{request.uri}\n#{headers}\n"
        end
      end
    end
  end
end
