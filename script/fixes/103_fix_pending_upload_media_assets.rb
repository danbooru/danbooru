#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  UploadMediaAsset.joins(:upload).pending.where(upload: { status: "completed" }).update_all(status: "active")
end
