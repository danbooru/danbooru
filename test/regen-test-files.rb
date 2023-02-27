#!/usr/bin/env ruby

require "dtext"
require "json"
require "zlib"
require "securerandom"
require "fileutils"

def regen_file(input_filename, **options)
  print "#{input_filename}: "

  output_filename = SecureRandom.uuid
  Zlib::GzipWriter.open(output_filename) do |output|
    Zlib::GzipReader.open(input_filename) do |input|
      input.each_line.with_index do |line, i|
        print "." if (i % 10000).zero?
        json = JSON.parse(line)

        output.puts({ **json, dtext: DText.parse(json["text"], domain: "danbooru.donmai.us", internal_domains: %w[danbooru.donmai.us], **options) }.to_json)
      end
    end
  end

  FileUtils.mv(output_filename, input_filename)

  puts
end

regen_file("test/files/pools.json.gz")
regen_file("test/files/bans.json.gz", inline: true)
regen_file("test/files/ip_bans.json.gz", inline: true)
regen_file("test/files/moderation_reports.json.gz", inline: true)
regen_file("test/files/post_appeals.json.gz", inline: true)
regen_file("test/files/post_flags.json.gz", inline: true)
regen_file("test/files/user_feedbacks.json.gz")

regen_file("test/files/wiki_pages.json.gz")
regen_file("test/files/forum_posts.json.gz")
regen_file("test/files/dmails.json.gz")
regen_file("test/files/comments.json.gz")
regen_file("test/files/wiki_page_versions.json.gz")
regen_file("test/files/artist_commentaries_original.json.gz", disable_mentions: true)
regen_file("test/files/artist_commentaries_translated.json.gz", disable_mentions: true)
regen_file("test/files/artist_commentary_versions_original.json.gz", disable_mentions: true)
regen_file("test/files/artist_commentary_versions_translated.json.gz", disable_mentions: true)
