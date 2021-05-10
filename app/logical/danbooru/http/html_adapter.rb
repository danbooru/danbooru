module Danbooru
  class Http
    class HtmlAdapter < HTTP::MimeType::Adapter
      HTTP::MimeType.register_adapter "text/html", self
      HTTP::MimeType.register_alias "text/html", :html

      def decode(str)
        Nokogiri::HTML5(str, max_tree_depth: -1)
      end
    end
  end
end
