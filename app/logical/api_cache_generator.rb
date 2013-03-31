class ApiCacheGenerator
  def generate_tag_cache
    File.open("#{Rails.root}/public/cache/tags.json", "w") do |f|
      f.print("[")
      Tag.find_each do |tag|
        hash = {
          "name" => tag.name,
          "id" => tag.id,
          "created_at" => tag.created_at,
          "post_count" => tag.post_count,
          "category" => tag.category
        }
        f.print(hash.to_json)
        f.print(", ")
      end
      f.seek(-2, IO::SEEK_END)
      f.print("]\n")
    end
  end
end
