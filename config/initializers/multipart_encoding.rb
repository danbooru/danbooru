# Don't let multipart forms pass non-UTF-8 strings to the app. Rack tags form fields with whatever charset the client
# gives (`Content-Type: text/plain; charset=Shift_JIS`). Ignore it, and reject fields that aren't valid UTF-8 or that
# contain NUL bytes.
Rack::Multipart::Parser.prepend(Module.new do
  private def tag_multipart_encoding(filename, _content_type, name, body)
    fields = filename ? [name] : [name, body]

    fields.compact.each do |field|
      field.force_encoding(Encoding::UTF_8)

      if !field.valid_encoding? || field.include?("\0")
        raise Rack::QueryParser::InvalidParameterError, "Form fields must be valid UTF-8 and can't contain NUL bytes."
      end
    end
  end
end)
