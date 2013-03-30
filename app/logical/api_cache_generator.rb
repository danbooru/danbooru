class ApiCacheGenerator
  def generate_tag_cache
    File.open("#{RAILS_ROOT}/public/cache/tags-legacy.xml", "w") do |f|
      f.puts('<?xml version="1.0" encoding="UTF-8"?>')
      f.puts('<tags type="array">')
      Tag.find_each do |tag|
        name = CGI.escape_html(tag.name)
        id = tag.id.to_s
        created_at = tag.created_at.try(:strftime, '%Y-%m-%d %H:%M')
        post_count = tag.post_count.to_s
        category = tag.category
        f.puts('<tag name="' + name + '" id="' + id + '" ambiguous="false" created_at="' + created_at + '" count="' + post_count + '" type="' + category + '"></tag>')
      end
      f.puts('</tags>')
    end
  end
end
