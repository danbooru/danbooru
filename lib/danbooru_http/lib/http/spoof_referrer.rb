# frozen_string_literal: true

module Danbooru
  class Http
    class SpoofReferrer < HTTP::Feature
      def self.register
        HTTP::Options.register_feature :spoof_referrer, self
      end

      def perform(request, &block)
        request.headers["Referer"] = request.uri unless request.headers["Referer"].present?
        response = yield request
        response
      end
    end
  end
end
