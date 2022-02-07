#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  # Delete all old upload records from before the upload rework in abdab7a0a / f11c46b4f.
  Upload.where("uploads.id <= 4974361").where.missing(:upload_media_assets).delete_all
end
