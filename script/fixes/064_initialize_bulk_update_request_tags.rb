#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  BulkUpdateRequest.find_each do |request|
    request.tags = request.processor.affected_tags

    if request.changed?
      request.save!(validate: false)
      puts "bur id=#{request.id} added_tags=#{request.tags - request.tags_before_last_save} removed_tags=#{request.tags_before_last_save - request.tags}"
    end
  end
end
