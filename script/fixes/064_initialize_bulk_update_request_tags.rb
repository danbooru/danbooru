#!/usr/bin/env ruby

require_relative "../../config/environment"

BulkUpdateRequest.transaction do
  BulkUpdateRequest.find_each do |request|
    request.tags = request.processor.affected_tags
    request.save!(validate: false)
    puts "bur id=#{request.id} tags=#{request.tags}"
  end
end
