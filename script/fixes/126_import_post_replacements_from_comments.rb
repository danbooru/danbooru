#!/usr/bin/env ruby

require_relative "base"

CurrentUser.user = User.system

# Parse the data from a DanbooruBot replacement comment.
def parse_comment(comment)
  dtext = DText.format_text(comment.body)
  html = Nokogiri::HTML5.fragment(dtext)

  old_source = html.css("table tr:first-child td a")[0]&.get_attribute("href") || html.css("table tr:first-child td")[0].text
  old_md5 = html.css("table tr:first-child td")[1].text
  old_file_ext = html.css("table tr:first-child td")[2].text
  old_image_width, old_image_height = html.css("table tr:first-child td")[3].text.split(" x ").map(&:to_i)
  old_file_size = html.css("table tr:first-child td")[4].text

  new_source = html.css("table tr:last-child td a")[0]&.get_attribute("href") || html.css("table tr:last-child td")[0].text
  new_md5 = html.css("table tr:last-child td")[1].text
  new_file_ext = html.css("table tr:last-child td")[2].text
  new_image_width, new_image_height = html.css("table tr:last-child td")[3].text.split(" x ").map(&:to_i)
  new_file_size = html.css("table tr:last-child td")[4].text

  replacer_name = html.css("a.dtext-user-mention-link")[0]&.get_attribute("data-user-name")
  replacer_name = "user_166417" if replacer_name == "Randeel"

  if replacer_name.nil?
    replacer_id = html.css("a.dtext-link[href^='/users']")[0]["href"][%r{^/users/([0-9]+)$}, 1]
    replacer = User.find(replacer_id)
  else
    replacer = User.find_by_name(replacer_name) || UserNameChangeRequest.find_by(original_name: replacer_name)&.user
  end

  raise "unknown replacer" if replacer.nil?

  OpenStruct.new(
    old_source:, old_md5:, old_file_ext:, old_file_size:, old_image_width:, old_image_height:,
    new_source:, new_md5:, new_file_ext:, new_file_size:, new_image_width:, new_image_height:,
    replacer:
  )
end

# Given a post, pair each replacement with the matching comment. Some replacements may not have a matching comment. This
# can happen because replacements that didn't change the MD5 didn't leave comments. Return the replacement-comment pairs
# and the leftover replacements.
def pair_comments(post)
  replacements = post.replacements.order(id: :asc).to_a
  comments = post.comments.where(creator: User.system).where_regex(:body, "replaced this post").order(id: :asc).to_a
  pairs = []

  while replacements.present? && comments.present?
    # Take the Cartesian product of all possible replacement-comment pairs, filter for matching pairs, and take the pair
    # with the closest matching created_at times.
    replacement, comment = replacements.product(comments).select do |replacement, comment|
      data = parse_comment(comment)

      if replacement.old_md5.present? && replacement.md5.present?
        data.old_source == replacement.original_url && data.replacer == replacement.creator && data.old_md5 == replacement.old_md5 && data.new_md5 == replacement.md5
      elsif replacement.old_md5.present?
        data.old_source == replacement.original_url && data.replacer == replacement.creator && data.old_md5 == replacement.old_md5
      else
        data.old_source == replacement.original_url && data.replacer == replacement.creator
      end
    end.min_by do |replacement, comment|
      [(replacement.updated_at - comment.created_at).abs, replacement.id, comment.id]
    end

    pairs << [replacement, comment]
    replacements -= [replacement]
    comments -= [comment]
  end

  [pairs, replacements]
end

with_confirmation do
  fix = ENV.fetch("FIX", "false").truthy?
  cond = ENV.fetch("COND", "TRUE")

  post_ids = PostReplacement.where(md5: nil).or(PostReplacement.where(old_md5: nil)).where(cond).pluck(:post_id).sort.uniq

  post_ids.each do |post_id|
    post = Post.find(post_id)
    replacements = post.replacements
    comments = post.comments.where(creator: User.system).where_regex(:body, "replaced this post")

    pairs, leftover_replacements = pair_comments(post)

    leftover_replacements.each do |replacement|
      #puts ({ error: "couldn't find comment", post: post.id, replacement: replacement.id, replacements: replacements.size, comments: comments.size, replacer: replacement.creator.name, old_md5: replacement.old_md5, new_md5: replacement.md5 }.to_json)
    end

    pairs.each do |replacement, comment|
      data = parse_comment(comment)
      replacer = data.replacer

      if replacer != replacement.creator
        puts ({ error: "replacer/replacement creator mismatch", post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, }.to_json)
        next
      end

      #if replacer != comment.updater && !comment.is_deleted?
      #  puts ({ error: "replacer/comment updater mismatch", post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, updater: comment.updater.name }.to_json)
      #  next
      #end

      if (replacement.updated_at - comment.created_at).abs > 70.seconds
        puts ({ error: "timestamp mismatch", post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, }.to_json)
        next
      end

      if data.old_source.to_s != replacement.original_url
        puts ({ error: "old source mismatch", post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, comment_old_source: data.old_source, replacement_old_source: replacement.original_url }.to_json)
        next
      end

      #if data.new_source != replacement.replacement_url.strip
      #  puts ({ error: "new source mismatch", post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, comment_new_source: data.new_source, replacement_new_source: replacement.replacement_url }.to_json)
      #  next
      #end

      replacement.old_md5 = data.old_md5 if replacement.old_md5.blank?
      replacement.md5 = data.new_md5 if replacement.md5.blank?

      puts ({ post: post.id, replacement: replacement.id, comment: comment.id, replacements: replacements.size, comments: comments.size, timediff: (comment.created_at - replacement.updated_at).abs.to_i, replacer: replacement.creator.name, replacement_changes: replacement.changes }.to_json)

      if replacement.changed? && fix
        replacement.save!(touch: false)
      end
    end
  end

  comments = User.system.comments.undeleted.where_regex(:body, "replaced this post").find_each do |comment|
    comment.update!(is_deleted: true) if fix
    puts "deleted comment ##{comment.id}"
  end
end
