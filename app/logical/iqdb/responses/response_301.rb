module Iqdb
  module Responses
    class Response_301 < Error
      attr_reader :exception, :description

      def initialize(response_string)
        response_string =~ /^(\S+) (.+)/
        @exception = $1
        @description = $2
      end

      def to_s
        "Exception: #{exception}: #{description}"
      end
    end
  end
end
