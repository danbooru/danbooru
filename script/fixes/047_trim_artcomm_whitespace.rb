#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

ArtistCommentary.without_timeout do
  ArtistCommentary.transaction do
    artcomms = ArtistCommentary.where(%(
         original_title         ~ '^[[:space:]]|[[:space:]]$'
      OR translated_title       ~ '^[[:space:]]|[[:space:]]$'
      OR original_description   ~ '^[[:space:]]|[[:space:]]$'
      OR translated_description ~ '^[[:space:]]|[[:space:]]$'
    ))
    size = artcomms.size

    artcomms.find_each.with_index do |artcomm, i|
      artcomm.save
      puts "#{i}/#{size}" if i % 100 == 0
    end

    # raise ActiveRecord::Rollback
  end
end
