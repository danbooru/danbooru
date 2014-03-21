module Iqdb
  module Responses
    class Response_300 < Error
      attr_reader :message

      def initialize(response_string)
        @message = response_string
      end

      def to_s
        "Error: #{message}"
      end
    end
  end
end
