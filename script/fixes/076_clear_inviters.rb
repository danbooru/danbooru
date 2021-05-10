#!/usr/bin/env ruby

require_relative "../../config/environment"

User.transaction do
  # Clear inviter for users who were listed as invited by Albert. Most of these
  # are very old Gold upgrades. Others are old accounts who probably weren't
  # invited by Albert himself.
  p User.where(inviter_id: 1).count
  User.where(inviter_id: 1).update_all(inviter_id: nil)

  # Clear inviter for older Gold and Platinum upgrades where the user was listed as having invited themselves.
  p User.where("inviter_id = id").count
  User.where("inviter_id = id").update_all(inviter_id: nil)

  # Clear inviter for newer Gold and Platinum upgrades where the user was listed as being invited by DanbooruBot.
  p User.where(inviter_id: User.system.id).count
  User.where(inviter_id: User.system.id).update_all(inviter_id: nil)

  # Clear inviter for users where there is a promotion feedback from the inviter.
  p User.joins(:feedback).where.not(inviter_id: nil).where_regex(:body, "^(You have been promoted|You gained the ability|Promoted from|Promoted by)").where("inviter_id = user_feedback.creator_id").count
  User.joins(:feedback).where.not(inviter_id: nil).where_regex(:body, "^(You have been promoted|You gained the ability|Promoted from|Promoted by)").where("inviter_id = user_feedback.creator_id").update_all(inviter_id: nil)

  # Clear inviter for users where there is a promotion modaction from the inviter.
  sql = "JOIN (SELECT (regexp_matches(description, '/users/([0-9]+)'))[1]::integer as user_id, * FROM mod_actions) AS subquery ON subquery.user_id = users.id"
  p User.joins(sql).where("subquery.category": [7, 8, 9, 19]).where("users.inviter_id = subquery.creator_id").count
  User.joins(sql).where("subquery.category": [7, 8, 9, 19]).where("users.inviter_id = subquery.creator_id").update_all(inviter_id: nil)
end
