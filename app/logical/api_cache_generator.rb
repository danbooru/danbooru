class ApiCacheGenerator
  def generate_tag_cache
    FileUtils.mkdir_p("/var/www/danbooru2/shared/system/cache")
    File.open("/var/www/danbooru2/shared/system/cache/tags.json", "w") do |f|
      f.print("[")
      Tag.without_timeout do
        Tag.find_each do |tag|
          next unless tag.post_count > 0
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
      end
      f.seek(-2, IO::SEEK_END)
      f.print("]\n")
    end
    Zlib::GzipWriter.open("/var/www/danbooru2/shared/system/cache/tags.json.gz") do |gz|
      gz.write(IO.binread("/var/www/danbooru2/shared/system/cache/tags.json"))
      gz.close
    end
    RemoteFileManager.new("/var/www/danbooru2/shared/system/cache/tags.json").distribute
    RemoteFileManager.new("/var/www/danbooru2/shared/system/cache/tags.json.gz").distribute
  end
end
