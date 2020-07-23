# A HTTP::Feature that automatically follows HTTP redirects.
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections

module Danbooru
  class Http
    class Redirector < HTTP::Feature
      HTTP::Options.register_feature :redirector, self

      attr_reader :max_redirects

      def initialize(max_redirects: 5)
        @max_redirects = max_redirects
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
        verb = :get if response.status == 303 && !request.verb.in?([:get, :head])

        request.redirect(uri, verb)
      end
    end
  end
end
