module Iqdb
  module Responses
    class Response_102 < Base
      attr_reader :dbid, :filename

      def initialize(response_string)
        @dbid, @filename = response_string.split(/ /)
      end
    end
  end
end
