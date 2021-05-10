module Danbooru
  class Http
    class Session < HTTP::Feature
      HTTP::Options.register_feature :session, self

      attr_reader :cookie_jar

      def initialize(cookie_jar: HTTP::CookieJar.new)
        @cookie_jar = cookie_jar
      end

      def perform(request)
        add_cookies(request)
        response = yield request
        save_cookies(response)
        response
      end

      def add_cookies(request)
        cookies = cookies_for_request(request)
        request.headers["Cookie"] = cookies if cookies.present?
      end

      def cookies_for_request(request)
        saved_cookies = cookie_jar.each(request.uri).map { |c| [c.name, c.value] }.to_h
        request_cookies = HTTP::Cookie.cookie_value_to_hash(request.headers["Cookie"].to_s)
        saved_cookies.merge(request_cookies).map { |name, value| "#{name}=#{value}" }.join("; ")
      end

      def save_cookies(response)
        response.cookies.each do |cookie|
          cookie_jar.add(cookie)
        end
      end
    end
  end
end
