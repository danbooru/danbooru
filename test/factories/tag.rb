FactoryBot.define do
  factory(:tag) do
    name {"#{FFaker::Name.first_name.downcase}#{rand(1000)}"}
    post_count { 100 }
    category {Tag.categories.general}

    factory(:general_tag) do
      category {Tag.categories.general}
    end

    factory(:artist_tag) do
      category {Tag.categories.artist}
    end

    factory(:copyright_tag) do
      category {Tag.categories.copyright}
    end

    factory(:character_tag) do
      category {Tag.categories.character}
    end

    factory(:meta_tag) do
      category {Tag.categories.meta}
    end
  end
end
