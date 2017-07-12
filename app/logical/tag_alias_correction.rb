class TagAliasCorrection
  attr_reader :tag_alias_id, :tag_alias, :hostname
  delegate :antecedent_name, :consequent_name, :to => :tag_alias

  def initialize(tag_alias_id, hostname = Socket.gethostname)
    @tag_alias_id = tag_alias_id
    @tag_alias = TagAlias.find(tag_alias_id)
    @hostname = hostname
  end

  def to_json(options = {})
    statistics_hash.to_json
  end

  def statistics_hash
    @statistics_hash ||= {
      "antecedent_cache" => Cache.get("ta:" + Cache.sanitize(tag_alias.antecedent_name)),
      "consequent_cache" => Cache.get("ta:" + Cache.sanitize(tag_alias.consequent_name)),
      "antecedent_count" => Tag.find_by_name(tag_alias.antecedent_name).try(:post_count),
      "consequent_count" => Tag.find_by_name(tag_alias.consequent_name).try(:post_count)
    }
  end

  def fill_hash!
    res = HTTParty.get("http://#{hostname}/tag_aliases/#{tag_alias_id}/correction.json", Danbooru.config.httparty_options)
    if res.success?
      json = JSON.parse(res.body)
      statistics_hash["antecedent_cache"] = json["antecedent_cache"]
      statistics_hash["consequent_cache"] = json["consequent_cache"]
    end
  end

  def each_server
    Danbooru.config.all_server_hosts.each do |host|
      other = TagAliasCorrection.new(tag_alias_id, host)

      if host != Socket.gethostname
        other.fill_hash!
      end

      yield other
    end
  end

  def clear_cache
    tag_alias.clear_all_cache
  end

  def fix!
    clear_cache
    tag_alias.delay(:queue => "default").update_posts
  end
end
