#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

PoolVersion.find_each do |version|
  version.update_column(:post_ids, version.post_ids.scan(/\d+/).in_groups_of(2).map {|x| x.first}.join(" "))
end

TagImplication.destroy_all("antecedent_name = consequent_name")
TagImplication.find_each do |impl|
  impl.update_descendant_names!
end
