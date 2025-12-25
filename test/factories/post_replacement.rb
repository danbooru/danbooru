FactoryBot.define do
  factory(:post_replacement) do
    post factory: :post, source: Faker::Internet.url
    original_url { Faker::Internet.url }
    replacement_url { "" }
    replacement_file { Rack::Test::UploadedFile.new("test/files/test.jpg") }
    creator
  end
end
