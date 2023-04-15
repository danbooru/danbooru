# frozen_string_literal: true

# Sanitizes the HTML used in notes. Only safe HTML tags, HTML attributes, and
# CSS properties are allowed.
module NoteSanitizer
  ALLOWED_ELEMENTS = %w[
    code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em
    strong small big b i font u s pre ruby rb rt rp rtc sub sup hr wbr
  ]

  ALLOWED_ATTRIBUTES = {
    :all => %w[style title],
    "a" => %w[href],
    "span" => %w[class],
    "div" => %w[class align],
    "p" => %w[class align],
    "font" => %w[color size]
  }

  ALLOWED_PROPERTIES = %w[
    align-items
    background-clip -webkit-background-clip
    background background-color
    border border-color border-image border-radius border-style border-width
    border-bottom border-bottom-color border-bottom-left-radius border-bottom-right-radius border-bottom-style border-bottom-width
    border-left border-left-color border-left-style border-left-width
    border-right border-right-color border-right-style border-right-width
    border-top border-top-color border-top-left-radious border-top-right-radius border-top-style border-top-width
    bottom left right top
    box-shadow
    color
    display
    filter
    float
    font font-family font-size font-size-adjust font-style font-variant font-weight
    height width
    justify-content
    letter-spacing
    line-height
    margin margin-bottom margin-left margin-right margin-top
    opacity
    padding padding-bottom padding-left padding-right padding-top
    perspective perspective-origin
    position
    text-align
    text-decoration
    text-indent
    text-shadow
    transform transform-origin
    -webkit-text-fill-color
    -webkit-text-stroke -webkit-text-stroke-color -webkit-text-stroke-width
    white-space
    word-break
    word-spacing
    word-wrap overflow-wrap
    writing-mode
    vertical-align
  ]

  # Sanitize a string of HTML.
  # @param text [String] the HTML to sanitize
  # @return [String] the sanitized HTML
  def self.sanitize(text)
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

  # Convert absolute Danbooru links inside notes to relative links.
  # https://danbooru.donmai.us/posts/1 is converted to /posts/1.
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
