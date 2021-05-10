module Danbooru
  class Http
    class SpoofReferrer < HTTP::Feature
      HTTP::Options.register_feature :spoof_referrer, self

      def perform(request, &block)
        request.headers["Referer"] = request.uri.origin unless request.headers["Referer"].present?
        response = yield request
        response
      end
    end
  end
end
