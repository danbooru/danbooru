module NoteSanitizer
  ALLOWED_ELEMENTS = %w(
    code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em
    strong small big b i font u s pre ruby rb rt rp rtc sub sup hr wbr
  )

  ALLOWED_ATTRIBUTES = {
    :all => %w(style title),
    "a" => %w(href),
    "span" => %w(class),
    "div" => %w(class align),
    "p" => %w(class align),
    "font" => %w(color size)
  }

  ALLOWED_PROPERTIES = %w(
    align-items
    background background-color
    border border-color border-image border-radius border-style border-width
    border-bottom border-bottom-color border-bottom-left-radius border-bottom-right-radius border-bottom-style border-bottom-width
    border-left border-left-color border-left-style border-left-width
    border-right border-right-color border-right-style border-right-width
    border-top border-top-color border-top-left-radious border-top-right-radius border-top-style border-top-width
    bottom left right top
    box-shadow
    clear
    color
    display
    filter
    float
    font font-family font-size font-size-adjust font-style font-variant font-weight
    height width
    justify-content
    letter-spacing
    line-height
    list-style list-style-position list-style-type
    margin margin-bottom margin-left margin-right margin-top
    mask mask-border mask-clip mask-composite mask-image mask-mode mask-origin mask-position mask-repeat mask-size
    opacity
    outline outline-color outline-offset outline-width outline-style
    padding padding-bottom padding-left padding-right padding-top
    perspective perspective-origin
    position
    text-align
    text-decoration text-decoration-color text-decoration-line text-decoration-style
    text-indent
    text-shadow
    text-transform
    transform transform-origin
    white-space
    word-break
    word-spacing
    word-wrap overflow-wrap
    writing-mode
    vertical-align
  )

  def self.sanitize(text)
    text.gsub!(/<( |-|3|:|>|\Z)/, "&lt;\\1")

    Sanitize.clean(
      text,
      :elements => ALLOWED_ELEMENTS,
      :attributes => ALLOWED_ATTRIBUTES,
      :add_attributes => {
        "a" => { "rel" => "external noreferrer nofollow" }
      },
      :protocols => {
        "a" => {
          "href" => ["http", "https", :relative]
        }
      },
      :css => {
        allow_comments: false,
        allow_hacks: false,
        at_rules: [],
        protocols: [],
        properties: ALLOWED_PROPERTIES
      },
      :transformers => method(:relativize_links)
    )
  end

  def self.relativize_links(node:, **env)
    return unless node.name == "a" && node["href"].present?

    url = Addressable::URI.heuristic_parse(node["href"]).normalize

    if url.authority == Danbooru.config.hostname
      url.site = nil
      node["href"] = url.to_s
    end
  rescue Addressable::URI::InvalidURIError
    # do nothing for invalid urls
  end
end
