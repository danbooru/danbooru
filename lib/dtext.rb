require "dtext/dtext"

module DTextRagel
  def self.parse_inline(str)
    parse(str, :inline => true)
  end

  def self.parse_strip(str)
    parse(str, :strip => true)
  end
end
