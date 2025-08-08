# frozen_string_literal: true

module Danbooru
  class Http
    class HtmlAdapter < HTTP::MimeType::Adapter
      def self.register
        HTTP::MimeType.register_adapter "text/html", self
        HTTP::MimeType.register_alias "text/html", :html
      end

      def decode(str)
        # XXX technically should use the charset from the http headers.
        Nokogiri::HTML5.parse(str.force_encoding("utf-8"), max_tree_depth: -1)
      end
    end
  end
end
