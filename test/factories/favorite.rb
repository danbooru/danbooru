FactoryBot.define do
  factory(:favorite) do
    user
    post

    factory(:private_favorite) do
      user factory: :gold_user, enable_private_favorites: true
    end
  end
end
