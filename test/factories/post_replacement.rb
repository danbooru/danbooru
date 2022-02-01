FactoryBot.define do
  factory(:post_replacement) do
    post factory: :post, source: FFaker::Internet.http_url
    original_url { FFaker::Internet.http_url }
    replacement_url { "" }
    replacement_file { Rack::Test::UploadedFile.new("test/files/test.jpg") }
    creator
  end
end
