#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

TagAlias.active.find_each do |tag_alias|
  Tag.find_or_create_by_name(tag_alias.antecedent_name)
  Tag.find_or_create_by_name(tag_alias.consequent_name)
  if tag_alias.antecedent_tag.category != 0 && tag_alias.antecedent_tag.category != tag_alias.consequent_tag.category
    tag_alias.consequent_tag.update_attribute(:category, tag_alias.antecedent_tag.category)
  end
end
