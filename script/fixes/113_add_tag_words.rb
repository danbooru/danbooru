#!/usr/bin/env ruby

require_relative "base"

Tag.find_each do |tag|
  tag.update_columns(words: Tag.parse_words(tag.name))
  p tag
end
