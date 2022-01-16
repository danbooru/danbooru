class CustomCss
  attr_reader :css

  def initialize(css)
    @css = css
  end

  def valid?
    css.blank? || parsed_css.none? { |node| node[:node] == :error }
  end

  def parsed_css
    @parsed_css ||= Crass.parse(css, preserve_comments: true)
  end
end
