FactoryBot.define do
  factory(:ip_geolocation) do
    ip_addr { Faker::Internet.public_ip_v4_address }
    network { Faker::Internet.public_ip_v4_address }
    asn { 42 }
    organization { "AT&T" }
    carrier { "AT&T" }
    is_proxy { false }
    latitude { 50.0 }
    longitude { 50.0 }
    time_zone { Faker::Address.time_zone }
    continent { "NA" }
    country { "US" }
    region { Faker::Address.state_abbr }
    city { Faker::Address.city }
  end
end
