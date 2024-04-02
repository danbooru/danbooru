#!/usr/bin/env ruby

require "dtext"
require "json"
require "zlib"
require "active_support/all"

$failures = 0

def assert_equal(expected, actual, dtext:, model:, id:)
  success = expected == actual

  if !success
    unless ENV["QUIET"]
      File.write("/tmp/expected.txt", expected)
      File.write("/tmp/actual.txt", actual)

      puts
      puts
      puts "Old: http://192.168.0.101:3000/#{model}/#{id}"
      puts "New: https://danbooru.donmai.us/#{model}/#{id}"
      puts
      puts "DText: \n```\n#{dtext}\n```"
      puts
      #puts "Expected: #{expected}"
      #puts
      #puts "Actual:   #{actual}"
      puts `dwdiff -P -c /tmp/expected.txt /tmp/actual.txt`
      #puts `dwdiff -W'' -P -c /tmp/expected.txt /tmp/actual.txt`
      puts
    end
  end

  success
end

def test_file(filename, field = "body", dtext_field: "#{field}_dtext", **options)
  return if ENV["TEST"].present? && !filename.match?(ENV["TEST"])

  model = File.basename(filename, ".json.gz").gsub(/(_translated|_original)$/, "")
  failures = 0

  print "#{filename}: "

  Zlib::GzipReader.open(filename) do |file|
    file.each_line.with_index do |line, i|
      print "." if (i % 10000).zero?
      json = JSON.parse(line)
      success = assert_equal(json["dtext"], DText.parse(json["text"], domain: "danbooru.donmai.us", internal_domains: %w[danbooru.donmai.us], **options), dtext: json["text"], model: model, id: json["id"])
      failures += !success ? 1 : 0
    end
  end

  puts " failures: #{failures}"
  $failures += failures
end

test_file("test/files/pools.json.gz")
test_file("test/files/bans.json.gz", inline: true)
test_file("test/files/ip_bans.json.gz", inline: true)
test_file("test/files/moderation_reports.json.gz", inline: true)
test_file("test/files/post_appeals.json.gz", inline: true)
test_file("test/files/post_flags.json.gz", inline: true)
test_file("test/files/user_feedbacks.json.gz")

test_file("test/files/wiki_pages.json.gz")
test_file("test/files/forum_posts.json.gz")
test_file("test/files/wiki_page_versions.json.gz")
test_file("test/files/dmails.json.gz")
test_file("test/files/comments.json.gz")
test_file("test/files/artist_commentaries_original.json.gz", disable_mentions: true)
test_file("test/files/artist_commentaries_translated.json.gz", disable_mentions: true)
test_file("test/files/artist_commentary_versions_original.json.gz", disable_mentions: true)
test_file("test/files/artist_commentary_versions_translated.json.gz", disable_mentions: true)

puts "total failures: #{$failures}"

puts File.read("/proc/#{Process.pid}/status").lines.grep(/Vm/).join("\n")
