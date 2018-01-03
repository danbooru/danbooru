# donmai.us specific

class ApiCacheGenerator
  def generate_tag_cache
    path = Danbooru.config.shared_dir_path
    FileUtils.mkdir_p("#{path}/system/cache")
    File.open("#{path}/system/cache/tags.json", "w") do |f|
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
    Zlib::GzipWriter.open("#{path}/system/cache/tags.json.gz") do |gz|
      gz.write(IO.binread("#{path}/system/cache/tags.json"))
      gz.close
    end
    RemoteFileManager.new("#{path}/system/cache/tags.json").distribute
    RemoteFileManager.new("#{path}/system/cache/tags.json.gz").distribute
  end
end
