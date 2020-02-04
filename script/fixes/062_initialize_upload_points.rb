#!/usr/bin/env ruby

require_relative "../../config/environment"

uploaders = User.where(id: Post.select(:uploader_id)).bit_prefs_match(:can_upload_free, false)

warn "uploaders=#{uploaders.count}"
uploaders.find_each.with_index do |uploader, n|
  uploader.upload_limit.update_limit!(nil, incremental: false)
  warn "n=#{n} id=#{uploader.id} name=#{uploader.name} points=#{uploader.upload_points}"
end

contributors = User.bit_prefs_match(:can_upload_free, true)
contributors.update_all(upload_points: UploadLimit::MAXIMUM_POINTS)
