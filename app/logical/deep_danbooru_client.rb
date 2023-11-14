# frozen_string_literal: true

class DeepDanbooruClient
  attr_reader :http

  def initialize(http: Danbooru::Http.internal)
    @http = http
  end

  def tags!(file)
    html = post!("/upload", form: {
      file: HTTP::FormData::File.new(file)
    }).parse

    tags = html.css("tbody tr").map do |row|
      tag_name = row.css("td:first-child").text
      confidence = row.css("td:last-child").text

      # If tag_name is "rating:safe", then make a mock tag.
      tag = Tag.find_by_name_or_alias(tag_name) || Tag.new(name: tag_name).freeze
      [tag, confidence.to_f]
    end.to_h

    tags
  end

  def post!(url, **options)
    http.post!("http://dev.kanotype.net:8003/deepdanbooru/#{url}", **options)
  end
end
