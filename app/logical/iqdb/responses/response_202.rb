module Iqdb
  module Responses
    class Response_202 < Base
      attr_reader :original_id, :stddev, :dupes

      def initialize(response_string)
        response_string =~ /^(\d+)=([0-9.]+)/
        @original_id = $1
        @stddev = $2

        @dupes = response_string.scan(/(\d+):([0-9.]+)/).map {|x| [x[0].to_i(16), x[1].to_f]}
      end

      def original_post_id
        original_id.to_i(16)
      end
    end
  end
end
