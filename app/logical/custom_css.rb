module CustomCss
  def self.parse(css)
    css.to_s.split(/\r\n|\r|\n/).map do |line|
      if line =~ /\A@import/
        line
      else
        line.gsub(/([^[:space:]])[[:space:]]*(?:!important)?[[:space:]]*(;|})/, "\\1 !important\\2")
      end
    end.join("\n")
  end
end
