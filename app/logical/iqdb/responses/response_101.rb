module Iqdb
  module Responses
    class Response_101 < Base
      attr_reader :key, :value

      def initialize(response_string)
        @key, @value = response_string.split(/\=/)
      end
    end
  end
end
