class TagAliasCorrection
  attr_reader :tag_alias_id, :tag_alias
  delegate :antecedent_name, :consequent_name, :to => :tag_alias

  def initialize(tag_alias_id)
    @tag_alias_id = tag_alias_id
    @tag_alias = TagAlias.find(tag_alias_id)
  end

  def to_json(options = {})
    statistics_hash.to_json
  end

  def statistics_hash
    @statistics_hash ||= {
      "antecedent_cache" => Cache.get("ta:" + Cache.hash(tag_alias.antecedent_name)),
      "consequent_cache" => Cache.get("ta:" + Cache.hash(tag_alias.consequent_name)),
      "antecedent_count" => Tag.find_by_name(tag_alias.antecedent_name).try(:post_count),
      "consequent_count" => Tag.find_by_name(tag_alias.consequent_name).try(:post_count)
    }
  end

  def clear_cache
    tag_alias.clear_all_cache
  end

  def fix!
    clear_cache
    tag_alias.delay(:queue => "default").update_posts
  end
end
