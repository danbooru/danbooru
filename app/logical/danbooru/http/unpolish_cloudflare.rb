# frozen_string_literal: true

# Detect sites using Cloudflare Polish and bypass it by adding a random
# cache-busting URL param.
#
# @see https://support.cloudflare.com/hc/en-us/articles/360000607372-Using-Cloudflare-Polish-to-compress-images
module Danbooru
  class Http
    class UnpolishCloudflare < HTTP::Feature
      def self.register
        HTTP::Options.register_feature :unpolish_cloudflare, self
      end

      def perform(request, &block)
        response = yield request

        if response.headers["CF-Polished"].present?
          request.uri.query = [request.uri.query.presence, "danbooru_no_polish=#{SecureRandom.uuid}"].compact.join("&")
          response = yield request
        end

        response
      end
    end
  end
end
