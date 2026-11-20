FactoryBot.define do
  factory :dmca_request do
    name { "John Doe" }
    email { "test@gmail.com" }
    address { "123 Fake Street" }
    infringing_urls { "https://example.com/1.html\nhttps://example.com/2.html" }
    original_urls { "https://google.com/1.html\nhttps://google.com/2.html" }
    proof { "source: me" }
    signature { "John Doe" }
  end
end
