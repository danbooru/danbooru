#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  Upload.where("status ~ '^error:'").find_each do |upload|
    message = upload.status.delete_prefix("error: ").strip
    upload.update_columns(status: "error", error: message)
    puts({ id: upload.id, status: "error", error: message }.to_json)
  end
end
