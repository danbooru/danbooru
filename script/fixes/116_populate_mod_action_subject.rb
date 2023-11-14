#!/usr/bin/env ruby

require_relative "base"

def update_subject!(mod_action, subject)
  mod_action.subject = subject
  mod_action.save!(touch: false)
  p mod_action
end

with_confirmation do
  ModAction.where(subject: nil).find_each do |mod_action|
    case mod_action.category
    when "user_delete"
      user_id = mod_action.description[/deleted user #(\d+)/, 1]
      update_subject!(mod_action, User.find(user_id))
    when "user_ban"
      user_name = mod_action.description[/\Abanned <@(.*?)> .*?: (.*)/, 1]
      reason = mod_action.description[/\Abanned <@(.*?)> .*?: (.*)/, 2]

      user = User.find_by_name(user_name)
      user = UserNameChangeRequest.find_by(original_name: user_name)&.user if user.nil?

      ban = Ban.where(user: user, banner: mod_action.creator, reason: reason, created_at: (mod_action.created_at - 1.second..mod_action.created_at + 1.second)).last if user
      ban = Ban.where(banner: mod_action.creator, reason: reason, created_at: (mod_action.created_at - 1.second..mod_action.created_at + 1.second)).last if ban.nil?
      ban = Ban.where(user: user, reason: reason, created_at: (mod_action.created_at - 1.second..mod_action.created_at + 1.second)).last if ban.nil?
      ban = Ban.where(banner: mod_action.creator, created_at: (mod_action.created_at - 1.second..mod_action.created_at + 1.second)).last if ban.nil?
      user = ban.user if ban&.user

      update_subject!(mod_action, user) if user

    when "user_unban"
      user_name = mod_action.description[/\Aunbanned <@(.*?)>/, 1]
      user = User.find_by_name(user_name)
      user = UserNameChangeRequest.find_by(original_name: user_name)&.user if user.nil?
      update_subject!(mod_action, user) if user
    when "user_name_change"
      update_subject!(mod_action, mod_action.creator)
    when "user_level_change"
      user_id = mod_action.description[/\A(?:promoted|demoted) ".*":\/users\/(\d+) from .* to .*/, 1]
      update_subject!(mod_action, User.find(user_id))
    when "user_upload_privilege"
      user_id = mod_action.description[/\A(?:granted|removed) unlimited upload privileges (?:to|from) ".*":\/users\/(\d+)/, 1]
      update_subject!(mod_action, User.find(user_id))
    when "user_approval_privilege"
      # "name":/users/:id changed banned from flagging for "name":/users/id from false to [b]true[/b]
      user_id = mod_action.description[/\A(?:granted|removed) approval privileges (?:to|from) ".*":\/users\/(\d+)/, 1]
      next if user_id.nil?
      update_subject!(mod_action, User.find(user_id))
    when "user_account_upgrade"
      update_subject!(mod_action, mod_action.creator)
    when "user_feedback_update"
      user_id = mod_action.description[/\Aupdated user feedback for ".*":\/users\/(\d+)/, 1]
      update_subject!(mod_action, User.find(user_id))
    when "user_feedback_delete"
      user_id = mod_action.description[/\Adeleted user feedback for ".*":\/users\/(\d+)/, 1]
      update_subject!(mod_action, User.find(user_id))

    when "post_delete"
      post_id = mod_action.description[/\Adeleted post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_undelete"
      post_id = mod_action.description[/\Aundeleted post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_ban"
      post_id = mod_action.description[/\Abanned post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_unban"
      post_id = mod_action.description[/\Aunbanned post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_move_favorites"
      post_id = mod_action.description[/\Amoved favorites from post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_regenerate"
      post_id = mod_action.description[/\Aregenerated image samples for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_regenerate"
      post_id = mod_action.description[/\Aregenerated image samples for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_regenerate_iqdb"
      post_id = mod_action.description[/\Aregenerated IQDB for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_note_lock_create"
      post_id = mod_action.description[/\Alocked notes for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_note_lock_delete"
      post_id = mod_action.description[/\Aunlocked notes for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_rating_lock_create"
      post_id = mod_action.description[/\Alocked rating for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post
    when "post_rating_lock_delete"
      post_id = mod_action.description[/\Aunlocked rating for post #(\d+)/, 1]
      post = Post.find_by(id: post_id)
      update_subject!(mod_action, post) if post

    when "post_vote_delete"
      post_vote_id = mod_action.description[/\Adeleted post vote #(\d+)/, 1]
      update_subject!(mod_action, PostVote.find(post_vote_id))
    when "post_vote_undelete"
      post_vote_id = mod_action.description[/\Aundeleted post vote #(\d+)/, 1]
      update_subject!(mod_action, PostVote.find(post_vote_id))

    when "pool_delete"
      pool_id = mod_action.description[/\Adeleted pool #(\d+)/, 1]
      update_subject!(mod_action, Pool.find(pool_id))
    when "pool_undelete"
      pool_id = mod_action.description[/\Aundeleted pool #(\d+)/, 1]
      update_subject!(mod_action, Pool.find(pool_id))

    when "artist_ban"
      artist_id = mod_action.description[/\Abanned artist #(\d+)/, 1]
      update_subject!(mod_action, Artist.find(artist_id))
    when "artist_unban"
      artist_id = mod_action.description[/\Aunbanned artist #(\d+)/, 1]
      update_subject!(mod_action, Artist.find(artist_id))

    when "comment_update"
      comment_id = mod_action.description[/\Aupdated comment #(\d+)/, 1]
      comment = Comment.find_by(id: comment_id)
      update_subject!(mod_action, comment) if comment
    when "comment_delete"
      comment_id = mod_action.description[/\Adeleted comment #(\d+)/, 1]
      comment = Comment.find_by(id: comment_id)
      update_subject!(mod_action, comment) if comment

    when "comment_vote_delete"
      comment_vote_id = mod_action.description[/\Adeleted comment vote #(\d+)/, 1]
      update_subject!(mod_action, CommentVote.find(comment_vote_id))
    when "comment_vote_undelete"
      comment_vote_id = mod_action.description[/\Aundeleted comment vote #(\d+)/, 1]
      update_subject!(mod_action, CommentVote.find(comment_vote_id))

    when "forum_topic_delete"
      forum_topic_id = mod_action.description[/\Adeleted forum topic #(\d+)/, 1]
      update_subject!(mod_action, ForumTopic.find(forum_topic_id))
    when "forum_topic_undelete"
      forum_topic_id = mod_action.description[/\Aundeleted forum topic #(\d+)/, 1]
      update_subject!(mod_action, ForumTopic.find(forum_topic_id))
    when "forum_topic_lock"
      forum_topic_id = mod_action.description[/\Alocked forum topic #(\d+)/, 1]
      update_subject!(mod_action, ForumTopic.find(forum_topic_id))

    when "forum_post_update"
      forum_post_id = mod_action.description[/\Aupdated forum #(\d+)/, 1]
      update_subject!(mod_action, ForumPost.find(forum_post_id))
    when "forum_post_delete"
      forum_post_id = mod_action.description[/\Adeleted forum #(\d+)/, 1]
      update_subject!(mod_action, ForumPost.find(forum_post_id))

    when "moderation_report_handled"
      modreport_id = mod_action.description[/\Ahandled modreport #(\d+)/, 1]
      modreport = ModerationReport.find_by(id: modreport_id)
      update_subject!(mod_action, modreport) if modreport
    when "moderation_report_rejected"
      modreport_id = mod_action.description[/\Arejected modreport #(\d+)/, 1]
      modreport = ModerationReport.find_by(id: modreport_id)
      update_subject!(mod_action, modreport) if modreport

    when "tag_alias_create"
      tag_alias_id = mod_action.description[/\Acreated pending "tag alias #(\d+)"/, 1]
      tag_alias = TagAlias.find_by(id: tag_alias_id)
      update_subject!(mod_action, tag_alias) if tag_alias
    when "tag_alias_update"
      tag_alias_id = mod_action.description[/\Aupdated "tag alias #(\d+)"/, 1]
      tag_alias = TagAlias.find_by(id: tag_alias_id)
      update_subject!(mod_action, tag_alias) if tag_alias
    when "tag_alias_delete"
      antecedent_name = mod_action.description[/\Adeleted tag alias (.*) -> (.*)\z/, 1]
      consequent_name = mod_action.description[/\Adeleted tag alias (.*) -> (.*)\z/, 2]
      tag_alias = TagAlias.find_by(status: "deleted", antecedent_name: antecedent_name, consequent_name: consequent_name)
      update_subject!(mod_action, tag_alias) if tag_alias

    when "tag_implication_create"
      tag_implication_id = mod_action.description[/\Acreated pending "tag implication #(\d+)"/, 1]
      tag_implication = TagImplication.find_by(id: tag_implication_id)
      update_subject!(mod_action, tag_implication) if tag_implication
    when "tag_implication_update"
      tag_implication_id = mod_action.description[/\Aupdated "tag implication #(\d+)"/, 1]
      tag_implication = TagImplication.find_by(id: tag_implication_id)
      update_subject!(mod_action, tag_implication) if tag_implication
    when "tag_implication_delete"
      antecedent_name = mod_action.description[/\Adeleted tag implication (.*) -> (.*)\z/, 1]
      consequent_name = mod_action.description[/\Adeleted tag implication (.*) -> (.*)\z/, 2]
      tag_implication = TagImplication.find_by(status: "deleted", antecedent_name: antecedent_name, consequent_name: consequent_name)
      update_subject!(mod_action, tag_implication) if tag_implication

    when "tag_deprecate"
      tag_name = mod_action.description[/\Amarked the tag \[\[(.*)\]\] as deprecated/, 1]
      update_subject!(mod_action, Tag.find_by!(name: tag_name))
    when "tag_undeprecate"
      tag_name = mod_action.description[/\Amarked the tag \[\[(.*)\]\] as not deprecated/, 1]
      update_subject!(mod_action, Tag.find_by!(name: tag_name))

    when "ip_ban_create"
      ip_addr = mod_action.description[/\Acreated ip ban for (.*)/, 1]
      ip_ban = IpBan.ip_matches(ip_addr).where(creator: mod_action.creator, created_at: (mod_action.created_at - 1.second...mod_action.created_at + 1.second)).first
      update_subject!(mod_action, ip_ban)
    when "ip_ban_delete"
      ip_addr = mod_action.description[/\Adeleted ip ban for (.*)/, 1]
      ip_ban = IpBan.ip_matches(ip_addr).where(created_at: (..mod_action.created_at)).last
      update_subject!(mod_action, ip_ban)
    when "ip_ban_undelete"
      ip_addr = mod_action.description[/\Aundeleted ip ban for (.*)/, 1]
      ip_ban = IpBan.ip_matches(ip_addr).where(created_at: (..mod_action.created_at)).last
      update_subject!(mod_action, ip_ban)

    when "other"
      mod_action.update_columns(category: "user_name_change")
      update_subject!(mod_action, mod_action.creator)
    end
  end
end
