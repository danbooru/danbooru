FactoryBot.define do
  factory(:ip_geolocation) do
    ip_addr { FFaker::Internet.ip_v4_address }
    network { FFaker::Internet.ip_v4_address }
    asn { 42 }
    organization { "AT&T" }
    carrier { "AT&T" }
    is_proxy { false }
    latitude { 50.0 }
    longitude { 50.0 }
    time_zone { FFaker::Address.time_zone }
    continent { "NA" }
    country { "US" }
    region { FFaker::AddressUS.state_abbr }
    city { FFaker::AddressUS.city }
  end
end
