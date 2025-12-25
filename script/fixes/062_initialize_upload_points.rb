#!/usr/bin/env ruby

require_relative "../../config/environment"

fix = ENV.fetch("FIX", "false").truthy?
uploaders = User.where(id: Post.select(:uploader_id))

warn "uploaders=#{uploaders.count}"
uploaders.find_each.with_index do |uploader, n|
  new_points = uploader.upload_limit.recalculated_upload_points

  warn "n=#{n} id=#{uploader.id} name=#{uploader.name} points=#{new_points} change=#{new_points - uploader.upload_points}" if new_points != uploader.upload_points
  uploader.recalculate_upload_points! if fix && new_points != uploader.upload_points
end
