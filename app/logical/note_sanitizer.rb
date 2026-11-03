# frozen_string_literal: true

# Sanitizes the HTML used in notes. Only whitelisted HTML tags, HTML attributes, and CSS properties are allowed.
module NoteSanitizer
  class Error < StandardError; end

  # The list of HTML tags allowed in notes.
  ALLOWED_ELEMENTS = %w[
    code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em
    strong small big b i font u s pre ruby rb rt rp rtc sub sup hr wbr
  ]

  # The list of allowed HTML attributes for each tag. The `:all` key specifies attributes that are allowed on all tags.
  ALLOWED_ATTRIBUTES = {
    :all => %w[style title],
    "a" => %w[href],
    "span" => %w[class],
    "div" => %w[class align],
    "p" => %w[class align],
    "font" => %w[color size],
  }

  # Common CSS units and keywords.
  LENGTH_UNITS = %w[px em rem ex ch cap lh rlh vw vh vmin vmax vi vb cm mm q in pt pc]
  ANGLE_UNITS = %w[deg grad rad turn]
  LINE_STYLES = %w[none hidden dotted dashed solid double groove ridge inset outset]
  LINE_WIDTHS = %w[thin medium thick]
  BORDER = [:color, :color_function, :length, :math_function, *LINE_STYLES, *LINE_WIDTHS]
  BACKGROUND_CLIP = %w[border-box padding-box content-box text]
  POSITIONS = %w[left right top bottom center]
  SIZES = %i[length percentage math_function] + %w[auto min-content max-content fit-content]
  DIRECTIONS = %w[row row-reverse column column-reverse]
  SIDES = %w[top right bottom left]
  CORNERS = %w[top-left top-right bottom-left bottom-right]

  # The list of CSS properties allowed in the `style` attribute, and the types of values allowed for each property.
  # Each entry is either a type of value (`:color`, `:length`, `:number`, `:angle`, `:percentage`, `:string`, `:ident`),
  # a function from ALLOWED_FUNCTIONS (e.g. `:color_function`), or a keyword.
  ALLOWED_PROPERTIES = {
    "align-items" => %w[normal stretch center start end flex-start flex-end self-start self-end baseline first last safe unsafe],
    "background" => [:color, :color_function, :length, :percentage, :gradient_function, :math_function, *BACKGROUND_CLIP, *POSITIONS] + %w[none repeat no-repeat repeat-x repeat-y space round scroll cover contain auto],
    "background-clip" => BACKGROUND_CLIP,
    "-webkit-background-clip" => BACKGROUND_CLIP,
    "background-color" => [:color, :color_function, :variable_function],
    "background-image" => [:gradient_function, "none"],
    "background-size" => [:length, :percentage, :math_function, "auto", "cover", "contain"],
    "border" => BORDER,
    "border-color" => [:color, :color_function],
    "border-image" => %i[gradient_function length percentage number math_function] + %w[none stretch repeat round space fill],
    "border-radius" => [:length, :percentage, :math_function],
    "border-style" => LINE_STYLES,
    "border-width" => [:length, :math_function, *LINE_WIDTHS],
    **SIDES.to_h { |side| ["border-#{side}", BORDER] },
    **SIDES.to_h { |side| ["border-#{side}-color", [:color, :color_function]] },
    **SIDES.to_h { |side| ["border-#{side}-style", LINE_STYLES] },
    **SIDES.to_h { |side| ["border-#{side}-width", [:length, :math_function, *LINE_WIDTHS]] },
    **CORNERS.to_h { |corner| ["border-#{corner}-radius", [:length, :percentage, :math_function]] },
    **SIDES.index_with { [:length, :percentage, :math_function, "auto"] },
    "box-shadow" => [:color, :color_function, :length, :math_function, "inset", "none"],
    "color" => [:color, :color_function, :variable_function],
    "display" => %w[inline block inline-block flex inline-flex grid inline-grid table inline-table table-cell table-row],
    "filter" => [:filter_function, "none"],
    "flex" => [:number, :length, :percentage, :math_function, "auto", "none"],
    "flex-direction" => DIRECTIONS,
    "flex-flow" => DIRECTIONS + %w[nowrap wrap wrap-reverse],
    "float" => %w[left right none],
    "font" => [:length, :percentage, :number, :string, :ident, :math_function],
    "font-family" => [:string, :ident, :variable_function],
    "font-size" => %i[length percentage math_function] + %w[xx-small x-small small medium large x-large xx-large xxx-large smaller larger],
    "font-size-adjust" => [:number, :math_function, "none"],
    "font-style" => [:angle, :math_function] + %w[normal italic oblique],
    "font-variant" => %w[normal none small-caps all-small-caps petite-caps all-petite-caps unicase titling-caps common-ligatures no-common-ligatures],
    "font-weight" => [:number, :math_function] + %w[normal bold bolder lighter],
    "height" => SIZES,
    "width" => SIZES,
    "min-width" => SIZES,
    "inset" => [:length, :percentage, :math_function, "auto"],
    "justify-content" => %w[normal start end flex-start flex-end center left right space-between space-around space-evenly stretch safe unsafe],
    "letter-spacing" => [:length, :percentage, :math_function, "normal"],
    "line-height" => [:length, :percentage, :number, :math_function, "normal"],
    "margin" => [:length, :percentage, :math_function, "auto"],
    **SIDES.to_h { |side| ["margin-#{side}", [:length, :percentage, :math_function, "auto"]] },
    "mask-composite" => %w[add subtract intersect exclude],
    "-webkit-mask" => [:gradient_function, :length, :percentage, :math_function, "none", *POSITIONS],
    "opacity" => %i[number percentage math_function],
    "outline" => BORDER,
    "overflow" => %w[hidden visible clip],
    "padding" => [:length, :percentage, :math_function],
    **SIDES.to_h { |side| ["padding-#{side}", [:length, :percentage, :math_function]] },
    "paint-order" => %w[normal fill stroke markers],
    "perspective" => [:length, :math_function, "none"],
    "perspective-origin" => [:length, :percentage, :math_function, *POSITIONS],
    "position" => %w[absolute relative],
    "text-align" => %w[left right center justify start end],
    "text-decoration" => %i[color color_function length math_function] + %w[none underline overline line-through blink solid double dotted dashed wavy auto from-font],
    "text-decoration-thickness" => [:length, :math_function, "auto", "from-font"],
    "text-indent" => [:length, :percentage, :math_function, "each-line", "hanging"],
    "text-orientation" => %w[mixed upright sideways],
    "text-shadow" => [:color, :color_function, :length, :math_function, "none"],
    "text-transform" => %w[none capitalize uppercase lowercase],
    "text-wrap" => %w[wrap nowrap balance pretty stable],
    "transform" => [:transform_function, "none"],
    "-webkit-transform" => [:transform_function, "none"],
    "transform-origin" => [:length, :percentage, :math_function, *POSITIONS],
    "-webkit-text-fill-color" => [:color, :color_function],
    "-webkit-text-stroke" => [:color, :color_function, :length, :math_function, *LINE_WIDTHS],
    "-webkit-text-stroke-color" => [:color, :color_function],
    "-webkit-text-stroke-width" => [:length, :math_function, *LINE_WIDTHS],
    "white-space" => %w[normal nowrap wrap pre pre-wrap pre-line break-spaces],
    "word-break" => %w[normal break-all keep-all break-word],
    "word-spacing" => [:length, :math_function, "normal"],
    "word-wrap" => %w[normal break-word anywhere],
    "overflow-wrap" => %w[normal break-word anywhere],
    "writing-mode" => %w[horizontal-tb vertical-rl vertical-lr sideways-rl sideways-lr],
    "vertical-align" => %i[length percentage math_function] + %w[baseline sub super text-top text-bottom middle top bottom],
    "visibility" => %w[visible hidden],
    "z-index" => [:number, :math_function, "auto"],
  }

  # The list of allowed CSS functions, and the types of arguments each function accepts.
  ALLOWED_FUNCTIONS = {
    # var(--custom-property)
    variable_function: [%w[var], [:custom_property]],
    # rgb(255, 0, 0), rgba(0 0 0 / 50%), hsl(120deg, 50%, 50%)
    color_function: [%w[rgb rgba hsl hsla], %i[number percentage angle math_function]],
    # calc(100% - 10px), min(50%, 20em), clamp(1em, 5%, 3em)
    math_function: [%w[calc min max clamp], %i[length percentage number angle math_function]],
    # linear-gradient(to right, red 0%, #00f 100%), radial-gradient(circle at center, red, blue)
    gradient_function: [
      %w[linear-gradient radial-gradient conic-gradient repeating-linear-gradient repeating-radial-gradient repeating-conic-gradient],
      %i[color color_function length percentage number angle math_function] + %w[
        to top bottom left right center circle ellipse closest-side closest-corner farthest-side farthest-corner at from
        in srgb hsl hwb lab lch oklab oklch longer shorter increasing decreasing hue
      ],
    ],
    # blur(2px), brightness(150%), drop-shadow(2px 2px 4px black)
    filter_function: [
      %w[blur brightness contrast drop-shadow grayscale hue-rotate invert opacity saturate sepia],
      %i[length percentage number angle color color_function math_function],
    ],
    # rotate(45deg), translate(50%, 10px), scale(1.5)
    transform_function: [
      %w[
        matrix matrix3d perspective rotate rotate3d rotatex rotatey rotatez scale scale3d scalex scaley scalez
        skew skewx skewy translate translate3d translatex translatey translatez
      ],
      %i[length percentage number angle math_function],
    ],
  }

  # Sanitize a string of HTML. Returns the empty string if the HTML can't be parsed.
  #
  # @param text [String] The HTML to sanitize.
  # @return [String] The sanitized HTML.
  def self.sanitize(text, **options)
    sanitize!(text, **options)
  rescue Error
    ""
  end

  # Sanitize a string of HTML. Raises an error if the HTML can't be parsed.
  #
  # @param text [String] The HTML to sanitize.
  # @param max_html_nesting_depth [Integer] The maximum nesting depth of HTML elements.
  # @param max_css_nesting_depth [Integer] The maximum nesting depth of CSS functions (e.g. `calc()`).
  # @return [String] The sanitized HTML.
  # @raise [Error] If the HTML is nested too deeply or can't be parsed.
  def self.sanitize!(text, max_html_nesting_depth: 40, max_css_nesting_depth: 5)
    Sanitize.clean(
      text,
      parser_options: { max_tree_depth: max_html_nesting_depth },
      elements: ALLOWED_ELEMENTS,
      attributes: ALLOWED_ATTRIBUTES,
      add_attributes: {
        "a" => { "rel" => "external noreferrer nofollow" },
      },
      protocols: {
        "a" => { "href" => ["http", "https", :relative] },
      },
      css: {
        allow_comments: false,
        allow_hacks: false,
        at_rules: [],
        protocols: [],
        properties: ALLOWED_PROPERTIES.keys,
      },
      transformers: [
        ->(**env) { sanitize_css!(**env, max_css_nesting_depth:) },
      ],
    )
  rescue ArgumentError => e
    raise if e.message.exclude?("Document tree depth limit exceeded")

    raise Error, "HTML is nested too deeply (max depth: #{max_html_nesting_depth})"
  end

  # Remove disallowed CSS properties from the HTML element's style attribute.
  #
  # @param node [Nokogiri::HTML5::DocumentFragment] The HTML element to sanitize.
  def self.sanitize_css!(node:, max_css_nesting_depth:, **_env)
    node["style"] = sanitize_style(node["style"], max_css_nesting_depth:)
  end

  # @param style [String] The CSS style attribute.
  # @return [String] The sanitized CSS style attribute.
  def self.sanitize_style(style, max_css_nesting_depth:)
    return nil if style.blank?

    nodes = Crass.parse_properties(style, maximum_depth: max_css_nesting_depth)
    omit_next_semicolon = false

    nodes.map! do |node|
      case node[:node]
      in :property if !allowed_css_property?(node[:name], node[:children])
        omit_next_semicolon = true
        nil

      in :semicolon if omit_next_semicolon
        nil

      in :whitespace
        # node
        nil

      else
        omit_next_semicolon = false
        node
      end
    end

    Crass::Parser.stringify(nodes).strip
  end

  # @param name [String] The CSS property name.
  # @param nodes [Array<Hash>] The property value as a list of parsed nodes.
  # @return [Boolean] True if the property is allowed
  def self.allowed_css_property?(name, nodes)
    allowed = ALLOWED_PROPERTIES[name.downcase]
    allowed.present? && allowed_css_values?(nodes, allowed)
  end

  # @param nodes [Array<Hash>] The parsed CSS value as a list of nodes.
  # @param allowed [Array<Symbol, String>] The types of values allowed for this CSS property.
  def self.allowed_css_values?(nodes, allowed)
    nodes.all? { |node| allowed_css_value?(node, allowed) }
  end

  # @param node [Hash] The parsed CSS property value (e.g. for `width: 100px` it would be `{ node: :dimension, value: 100, unit: "px" }`).
  # @param allowed [Array<Symbol, String>] The types of values allowed for this CSS property (e.g. `width: ...` allows lengths, percentages, and keywords like `auto`).
  # @return [Boolean] True if the value is allowed for this CSS property.
  def self.allowed_css_value?(node, allowed)
    case node
    # `a, b` or `a b`
    in { node: :whitespace | :comma }
      true

    # `font: 12px/1.5`, `calc(1px + 2px)`
    in { node: :delim, value: "/" | "+" | "-" | "*" }
      true

    # `solid`, `bold`
    in { node: :ident, value: } if allowed.include?(value.downcase)
      true

    # `Arial`, `sans-serif`
    in { node: :ident, value: } if allowed.include?(:ident)
      true

    # `red`, `asdofijoi`
    in { node: :ident, value: /\A[a-z]+\z/i } if allowed.include?(:color)
      true

    # `var(--link-color)`
    in { node: :ident, value: /\A--[\w-]+\z/ } if allowed.include?(:custom_property)
      true

    # `inherit`, `initial`, `unset`, `revert`
    in { node: :ident, value: } if value.downcase.in?(%w[inherit initial unset revert])
      true

    # `50%`
    in { node: :percentage } if allowed.include?(:percentage)
      true

    # `0`, `1.5`, `400`
    in { node: :number, value: } if allowed.include?(:number)
      true

    # `0`
    in { node: :number, value: } if allowed.include?(:length) && value.zero?
      true

    # `10px`, `2em`
    in { node: :dimension, unit: } if allowed.include?(:length) && unit.downcase.in?(LENGTH_UNITS)
      true

    # `45deg`
    in { node: :dimension, unit: } if allowed.include?(:angle) && unit.downcase.in?(ANGLE_UNITS)
      true

    # `#f00`, `#ff0000`, `#ff000080`
    in { node: :hash, value: /\A(\h{3,4}|\h{6}|\h{8})\z/ } if allowed.include?(:color)
      true

    # `"Times New Roman"`
    in { node: :string } if allowed.include?(:string)
      true

    # `(1px + 2px)` inside `calc()`
    in { node: :simple_block, start: "(", value: }
      allowed_css_values?(value, allowed) # Note that the recursion is limited by the `max_css_nesting_depth`

    # `rgb(0, 0, 0)`, `linear-gradient(red, blue)`, `translate(10px, 5px)`
    in { node: :function, name:, value: }
      allowed_css_function?(name.downcase, value, allowed)

    else
      false
    end
  end

  # @param name [String] The function name.
  # @param args [Array<Hash>] The parsed tokens of the function's arguments.
  # @param allowed [Array<Symbol, String>] The types of arguments allowed for this property
  def self.allowed_css_function?(name, args, allowed)
    ALLOWED_FUNCTIONS.slice(*allowed.grep(Symbol)).values.any? do |names, arg_types|
      name.in?(names) && allowed_css_values?(args, arg_types)
    end
  end
end
