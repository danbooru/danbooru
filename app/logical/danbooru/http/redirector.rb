# frozen_string_literal: true

# A HTTP::Feature that automatically follows HTTP redirects.
#
# @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections
module Danbooru
  class Http
    class Redirector < HTTP::Feature
      # The request headers that are kept when a redirect goes to a different origin.
      CROSS_ORIGIN_HEADERS = %w[host connection user-agent accept accept-encoding accept-language referer content-type content-length].freeze

      attr_reader :max_redirects

      def initialize(max_redirects: 5)
        super()
        @max_redirects = max_redirects
      end

      def self.register
        HTTP::Options.register_feature :redirector, self
      end

      def perform(request, &block)
        response = yield request

        redirects = max_redirects
        while response.status.redirect?
          raise HTTP::Redirector::TooManyRedirectsError if redirects <= 0

          response = yield build_redirect(request, response)
          redirects -= 1
        end

        response
      end

      def build_redirect(request, response)
        location = response.headers["Location"].to_s
        uri = HTTP::URI.parse(location)

        verb = request.verb
        verb = :get if response.status.in?([302, 303]) && !request.verb.in?([:get, :head])

        redirect = request.redirect(uri, verb)

        # httprb only removes the Authorization and Cookie headers when redirecting to a different origin. Remove every
        # header that isn't known to be safe, so custom credential headers like X-Api-Key aren't sent to other hosts.
        if redirect.uri.origin != request.uri.origin
          (redirect.headers.keys.map(&:downcase) - CROSS_ORIGIN_HEADERS).each { |name| redirect.headers.delete(name) }
        end

        redirect
      end
    end
  end
end
