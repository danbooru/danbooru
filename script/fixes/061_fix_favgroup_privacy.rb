#!/usr/bin/env ruby

require_relative "../../config/environment"

users = User.bit_prefs_match(:enable_private_favorites, true)
favgroups = FavoriteGroup.where(is_public: false).where.not(creator_id: users.select(:id))

favgroups.update_all(is_public: true)
