module Iqdb
  module Responses
    class Response_100 < Base
      attr_reader :message

      def initialize(response_string)
        @message = response_string
      end
    end
  end
end
