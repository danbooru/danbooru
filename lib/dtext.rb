require "dtext/dtext"

module DTextRagel
  class Error < StandardError; end

  def self.parse_inline(str)
    parse(str, :inline => true)
  end

  def self.parse_strip(str)
    parse(str, :strip => true)
  end
end
