module NoteSanitizer
  def self.sanitize(text)
    text.gsub!(/<( |-|3|:|>|\Z)/, "&lt;\\1")

    Sanitize.clean(
      text,
      :elements => %w(code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em strong small big b i font u s pre ruby rb rt rp),
      :attributes => {
        "a" => %w(href title style),
        "span" => %w(class style),
        "div" => %w(class style align),
        "p" => %w(class style align),
        "font" => %w(color size style)
      },
      :protocols => {
        "a" => {
          "href" => ["http", "https", :relative]
        }
      },
      :css => Sanitize::Config::RELAXED[:css].merge({
        :protocols => []
      })
    )
  end
end
