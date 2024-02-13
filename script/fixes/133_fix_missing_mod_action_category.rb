#!/usr/bin/env ruby

require_relative "base"

fix = ENV.fetch("FIX", "false").truthy?

ModAction.where(category: 2000).find_each do |mod_action|
  mod_action.category = :user_name_change
  mod_action.subject = mod_action.creator
  mod_action.save!(touch: false) if fix
  p mod_action
end
