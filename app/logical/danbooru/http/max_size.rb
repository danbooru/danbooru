# frozen_string_literal: true

# Limits the size of response bodies, and decompresses gzipped responses. The limit applies to the decompressed size,
# so a small gzipped response can't expand to fill up memory. Raises Danbooru::Http::FileTooLargeError when the body
# is read if it's too large.
#
# This replaces http.rb's `auto_inflate` feature, which decompresses each chunk of the response all at once, so a
# single chunk could expand to many megabytes before the size could be checked.
module Danbooru
  class Http
    class MaxSize < HTTP::Feature
      attr_reader :max_size

      def initialize(max_size:)
        super()
        @max_size = max_size
      end

      def self.register
        HTTP::Options.register_feature :max_size, self
      end

      def wrap_response(response)
        gzipped = response.headers[:content_encoding].to_s.in?(%w[gzip x-gzip deflate])
        stream = Stream.new(response.connection, max_size: max_size, gzipped: gzipped, content_length: (response.content_length unless gzipped))

        HTTP::Response.new(
          status: response.status,
          version: response.version,
          headers: response.headers,
          proxy_headers: response.proxy_headers,
          connection: response.connection,
          body: HTTP::Response::Body.new(stream, encoding: response.body.encoding),
          request: response.request,
        )
      end

      class Stream
        # The number of bytes to read from the socket at a time. Larger reads download faster, with little gain past 256KB.
        READ_SIZE = 256.kilobytes

        # The number of compressed bytes to inflate at a time. Gzip can expand data about 1000x, so this limits each chunk of output to about 16MB.
        INFLATE_SIZE = 16.kilobytes

        attr_reader :connection, :max_size, :content_length, :inflater

        def initialize(connection, max_size:, gzipped:, content_length: nil)
          @connection = connection
          @max_size = max_size
          @content_length = content_length
          @inflater = Zlib::Inflate.new(32 + Zlib::MAX_WBITS) if gzipped
          @compressed = "".b
          @offset = 0
          @size = 0
        end

        def readpartial(size = READ_SIZE, _outbuf = nil)
          return add(read(size)) if inflater.nil?

          if @offset >= @compressed.bytesize
            @compressed = read(size)
            @offset = 0
          end

          input = @compressed.byteslice(@offset, INFLATE_SIZE)
          @offset += input.bytesize

          output = String.new
          inflater.inflate(input) { |piece| output << add(piece) }
          output
        rescue EOFError
          inflater.close if inflater && !inflater.closed?
          raise
        end

        private

        def read(size)
          chunk = connection.readpartial(size)

          # Checked after reading so that responses without a body, such as HEAD requests, aren't affected.
          if content_length.to_i > max_size
            raise FileTooLargeError, "File size too large (size: #{content_length.to_fs(:human_size)}; max size: #{max_size.to_fs(:human_size)})"
          end

          chunk
        end

        def add(chunk)
          @size += chunk.bytesize
          raise FileTooLargeError, "File size too large (max size: #{max_size.to_fs(:human_size)})" if @size > max_size
          chunk
        end
      end
    end
  end
end
