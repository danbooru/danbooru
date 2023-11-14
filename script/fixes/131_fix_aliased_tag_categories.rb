#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  fix = ENV.fetch("FIX", "false").truthy?

  aliases = TagAlias.active.joins(:antecedent_tag, :consequent_tag).where("tags.category != consequent_tags_tag_aliases.category")
  aliases.find_each do |tag_alias|
    tag_alias.antecedent_tag.assign_attributes(category: tag_alias.consequent_tag.category, updater: User.system)

    puts ({ id: tag_alias.id, from: tag_alias.antecedent_tag.name, to: tag_alias.consequent_tag.name, changes: tag_alias.antecedent_tag.changes }).to_json
    tag_alias.antecedent_tag.save!(touch: false) if fix
  end
end
