#!/usr/bin/env ruby

require_relative "../../config/environment"

User.transaction do
  members = User.where(level: User::Levels::MEMBER)
  restricted = members.bit_prefs_match(:requires_verification, true).bit_prefs_match(:is_verified, false)
  restricted.update_all(level: User::Levels::RESTRICTED)
end
