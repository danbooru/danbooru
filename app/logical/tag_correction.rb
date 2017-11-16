class TagCorrection
  attr_reader :tag_id, :tag, :hostname

  def initialize(tag_id, hostname = Socket.gethostname)
    @tag_id = tag_id
    @tag = Tag.find(tag_id)
    @hostname = hostname
  end

  def to_json(options = {})
    statistics_hash.to_json
  end

  def statistics_hash
    @statistics_hash ||= {
      "category_cache" => Cache.get("tc:" + Cache.hash(tag.name)),
      "post_fast_count_cache" => Cache.get("pfc:" + Cache.hash(tag.name))
    }
  end

  def fill_hash!
    res = HTTParty.get("http://#{hostname}/tags/#{tag_id}/correction.json", Danbooru.config.httparty_options)
    if res.success?
      json = JSON.parse(res.body)
      statistics_hash["category_cache"] = json["category_cache"]
      statistics_hash["post_fast_count_cache"] = json["post_fast_count_cache"]
    end
  end

  def each_server
    Danbooru.config.all_server_hosts.each do |host|
      other = TagCorrection.new(tag_id, host)

      if host != Socket.gethostname
        other.fill_hash!
      end

      yield other
    end
  end

  def fix!
    tag.delay(:queue => "default").fix_post_count
    tag.update_category_cache_for_all
  end
end
