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
    border-top border-top-color border-top-left-radius border-top-right-radius border-top-style border-top-width
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

  # The list of values allowed for each CSS property. For properties not on this list, any value is allowed.
  ALLOWED_PROPERTY_VALUES = {
    position: %w[absolute relative],
    display: %w[inline block inline-block flex inline-flex grid inline-grid table table-cell table-row],
  }.with_indifferent_access

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
      :transformers => [
        method(:sanitize_css!)
      ]
    )
  end

  # Remove disallowed CSS properties from the HTML element's style attribute.
  # @param node [Nokogiri::HTML5::DocumentFragment] The HTML element to sanitize.
  def self.sanitize_css!(node:, **env)
    node["style"] = sanitize_style(node["style"])
  end

  # @param style [String] The CSS style attribute.
  # @return [String] The sanitized CSS style attribute.
  def self.sanitize_style(style)
    return nil if style.blank?

    nodes = Crass.parse_properties(style)
    omit_next_semicolon = false

    nodes.map! do |node|
      case node[:node]
      in :property if !allowed_css_property?(node[:name], node[:value])
        omit_next_semicolon = true
        nil

      in :semicolon if omit_next_semicolon
        nil

      in :whitespace
        nil

      else
        omit_next_semicolon = false
        node
      end
    end

    Crass::Parser.stringify(nodes).strip
  end

  # @param name [String] The CSS property name.
  # @param value [String] The CSS property value.
  def self.allowed_css_property?(name, value)
    allowed_values = ALLOWED_PROPERTY_VALUES[name]
    allowed_values.blank? || value.downcase.in?(allowed_values)
  end
end
