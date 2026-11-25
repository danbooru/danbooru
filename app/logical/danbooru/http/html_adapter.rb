# frozen_string_literal: true

module Danbooru
  class Http
    class HtmlAdapter < HTTP::MimeType::Adapter
      MAX_TREE_DEPTH = Nokogiri::Gumbo::DEFAULT_MAX_TREE_DEPTH # 400

      def self.register
        HTTP::MimeType.register_adapter "text/html", self
        HTTP::MimeType.register_alias "text/html", :html
      end

      def decode(str)
        # XXX technically should use the charset from the http headers.
        Nokogiri::HTML5.parse(str.force_encoding("utf-8"), max_tree_depth: MAX_TREE_DEPTH)
      rescue ArgumentError => e
        raise if e.message.exclude?("Document tree depth limit exceeded")

        nil
      end
    end
  end
end
