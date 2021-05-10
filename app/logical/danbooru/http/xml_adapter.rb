module Danbooru
  class Http
    class XmlAdapter < HTTP::MimeType::Adapter
      HTTP::MimeType.register_adapter "application/xml", self
      HTTP::MimeType.register_alias "application/xml", :xml

      def decode(str)
        Hash.from_xml(str).with_indifferent_access
      end
    end
  end
end
