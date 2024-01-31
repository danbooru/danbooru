# frozen_string_literal: true

module Danbooru
  class Http
    class XmlAdapter < HTTP::MimeType::Adapter
      def self.register
        HTTP::MimeType.register_adapter "text/xml", self
        HTTP::MimeType.register_adapter "application/xml", self
        HTTP::MimeType.register_alias "application/xml", :xml
      end

      def decode(str)
        Hash.from_xml(str).with_indifferent_access
      end
    end
  end
end
