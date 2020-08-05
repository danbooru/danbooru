FactoryBot.define do
  factory(:linked_account) do
    user
    api_key { {} }
    account_data { {} }
    account_id { FFaker::Guid.guid }

    factory(:discord_account) do
      site { "Discord" }
    end
  end
end
