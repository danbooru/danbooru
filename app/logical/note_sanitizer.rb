module NoteSanitizer
  ALLOWED_ELEMENTS = %w(
    code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em
    strong small big b i font u s pre ruby rb rt rp
  )

  ALLOWED_ATTRIBUTES = {
    :all => %w(style title),
    "a" => %w(href),
    "span" => %w(class),
    "div" => %w(class align),
    "p" => %w(class align),
    "font" => %w(color size),
  }

  def self.sanitize(text)
    text.gsub!(/<( |-|3|:|>|\Z)/, "&lt;\\1")

    Sanitize.clean(
      text,
      :elements => ALLOWED_ELEMENTS,
      :attributes => ALLOWED_ATTRIBUTES,
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
