# frozen_string_literal: true

require "test_helper"

class NoteSanitizerTest < ActiveSupport::TestCase
  def assert_style_kept(css, **options)
    html = %{<p style="#{css}">test</p>}
    assert_equal(html, NoteSanitizer.sanitize(html, **options), "expected style to be kept: #{css}")
  end

  def assert_style_stripped(css, **options)
    html = %{<p style="#{css}">test</p>}
    assert_equal("<p>test</p>", NoteSanitizer.sanitize(html, **options), "expected style to be stripped: #{css}")
  end

  context "Sanitizing a note" do
    context "when sanitizing style attributes" do
      should "strip URLs" do
        assert_style_stripped("background-image: url(http://www.google.com);")
      end

      should "not strip allowed style properties" do
        assert_style_kept("font-size: 1em;")
        assert_style_kept("position: absolute;")
        assert_style_kept("position: Absolute;")
        assert_style_kept("position: relative;")
        assert_equal('<p style="position: relative;">test</p>', NoteSanitizer.sanitize('<p style="  position: relative;  ">test</p>'))
        assert_equal('<p style="color: red;position: relative;color: green;">test</p>', NoteSanitizer.sanitize('<p style="  color: red;; ;; position: relative;; ;;  color: green;; ;;">test</p>'))
      end

      should "strip disallowed style properties" do
        assert_style_stripped("position: fixed;")
        assert_style_stripped("position: sticky;")
        assert_style_stripped("display: none;")
        assert_style_stripped(";")

        assert_equal('<p style="color: red;">test</p>', NoteSanitizer.sanitize('<p style="position: fixed; color: red;">test</p>'))
        assert_equal('<p style="color: red;">test</p>', NoteSanitizer.sanitize('<p style="position: fixed; ; ; ; color: red;">test</p>'))
      end

      should "strip disallowed style values regardless of property name case" do
        assert_style_stripped("POSITION: fixed")
        assert_style_stripped("Position: Fixed")
        assert_style_stripped("DISPLAY: none")
        assert_style_kept("POSITION: absolute")
      end

      should "allow expected values for each style property" do
        assert_style_kept("color: red")
        assert_style_kept("color: #fff")
        assert_style_kept("color: #FFFFFF80")
        assert_style_kept("color: rgb(0, 0, 0)")
        assert_style_kept("color: rgba(0 0 0 / 50%)")
        assert_style_kept("color: hsl(120deg, 50%, 50%)")
        assert_style_kept("color: transparent")
        assert_style_kept("color: RebeccaPurple")
        assert_style_kept("color: notacolor")
        assert_style_kept("color: CurrentColor")
        assert_style_kept("background-color: #abc")
        assert_style_kept("-webkit-text-fill-color: transparent")

        assert_style_kept("background: linear-gradient(to right, red 0%, rgba(0,0,0,0.5) 100%) no-repeat center / cover")
        assert_style_kept("-webkit-background-clip: text")
        assert_style_kept("border: 1px solid #000")
        assert_style_kept("border-top: thin dashed red")
        assert_style_kept("border-style: dotted")
        assert_style_kept("border-width: 2px 0")
        assert_style_kept("border-radius: 50%")
        assert_style_kept("border-top-left-radius: 4px 8px")
        assert_style_kept("border-image: linear-gradient(red, blue) 1")

        assert_style_kept("margin: -4px auto 0 calc(1em + 2px)")
        assert_style_kept("padding: 0.5em")
        assert_style_kept("width: min(100%, 20em)")
        assert_style_kept("height: calc((100% - 4px) / 2)")
        assert_style_kept("top: 10px")
        assert_style_kept("left: auto")
        assert_style_kept("position: relative !important")
        assert_style_kept("display: inline-block")
        assert_style_kept("float: left")
        assert_style_kept("align-items: center")
        assert_style_kept("justify-content: space-between")

        assert_style_kept("font: italic bold 12px/1.5 Arial, 'Comic Sans MS', sans-serif")
        assert_style_kept("font-family: 'Times New Roman', serif")
        assert_style_kept("font-size: 1.5em")
        assert_style_kept("font-size: x-large")
        assert_style_kept("font-size-adjust: 0.5")
        assert_style_kept("font-style: italic")
        assert_style_kept("font-variant: small-caps")
        assert_style_kept("font-weight: 700")
        assert_style_kept("font-weight: bold")
        assert_style_kept("line-height: 1.25")
        assert_style_kept("letter-spacing: 0.1em")
        assert_style_kept("word-spacing: normal")
        assert_style_kept("text-align: center")
        assert_style_kept("text-decoration: underline wavy red")
        assert_style_kept("text-indent: 2em")
        assert_style_kept("vertical-align: middle")
        assert_style_kept("white-space: pre-wrap")
        assert_style_kept("word-break: break-all")
        assert_style_kept("word-wrap: break-word")
        assert_style_kept("overflow-wrap: anywhere")
        assert_style_kept("writing-mode: vertical-rl")
        assert_style_kept("-webkit-text-stroke: 1px black")
        assert_style_kept("-webkit-text-stroke-width: thin")

        assert_style_kept("opacity: 0.5")
        assert_style_kept("opacity: 50%")
        assert_style_kept("box-shadow: 0 0 4px 2px rgba(0,0,0,0.5), inset 0 0 2px #fff")
        assert_style_kept("text-shadow: 1px 1px 2px black")
        assert_style_kept("filter: blur(2px) drop-shadow(0 0 2px red)")
        assert_style_kept("transform: rotate(45deg) translate(10px, -5px) scale(1.5)")
        assert_style_kept("transform-origin: left top")
        assert_style_kept("perspective: 500px")
        assert_style_kept("perspective-origin: 50% 50%")
      end

      should "allow values and properties used in real notes" do
        assert_style_kept("white-space: wrap")
        assert_style_kept("display: inline-table")
        assert_style_kept("background-image: linear-gradient(to bottom, #fd999b, #ff3338)")
        assert_style_kept("background: conic-gradient(from 266.25deg at 175% 80%, #fec5e6 0deg 2.5deg, #fff 2.5deg 7.5deg)")
        assert_style_kept("background: repeating-linear-gradient(in hsl longer hue 90deg, #ff5cd0 0 90%)")
        assert_style_kept("background-size: 100%")
        assert_style_kept("-webkit-mask: radial-gradient(circle 25px at bottom right, transparent 99%, black 100%)")
        assert_style_kept("mask-composite: exclude")
        assert_style_kept("-webkit-transform: rotate(180deg)")
        assert_style_kept("-webkit-transform: scaleX(-1)")
        assert_style_kept("flex-direction: column")
        assert_style_kept("flex-flow: column nowrap")
        assert_style_kept("flex: 1")
        assert_style_kept("min-width: 5px")
        assert_style_kept("outline: 1px solid red")
        assert_style_kept("overflow: hidden")
        assert_style_kept("paint-order: stroke fill")
        assert_style_kept("text-orientation: upright")
        assert_style_kept("text-transform: uppercase")
        assert_style_kept("text-decoration-thickness: 2px")
        assert_style_kept("text-wrap: nowrap")
        assert_style_kept("visibility: visible")
        assert_style_kept("inset: 0")
        assert_style_kept("z-index: -1")
        assert_style_kept("z-index: 999")
      end

      should "allow CSS-wide keywords" do
        assert_style_kept("font-style: initial")
        assert_style_kept("line-height: inherit")
        assert_style_kept("word-break: unset")
        assert_style_kept("background: revert")
        assert_style_kept("color: INHERIT")
        assert_style_stripped("position: fixed !important")
      end

      should "allow var() in designated properties" do
        assert_style_kept("background-color: var(--body-background-color)")
        assert_style_kept("background-color: var(--unknown)")
        assert_style_kept("font-family: var(--body-font)")
        assert_style_kept("font-family: var(--unknown), sans-serif")
        assert_style_kept("color: var(--link-color)")
        assert_style_kept("color: var(--unknown)")

        assert_style_stripped("color: var(--character-tag-color, red)")
        assert_style_stripped("color: var(--character-tag-color, var(--x))")
        assert_style_stripped("color: var(--x) var(--y, 1)")
        assert_style_stripped("color: var(unknown)")
        assert_style_stripped("color: var(--)")
        assert_style_stripped("color: var(--x y)")
        assert_style_stripped("color: var(url(http://example.com))")
        assert_style_stripped("background: var(--unknown) no-repeat")
        assert_style_stripped("width: var(--unknown)")
        assert_style_stripped("border-color: var(--unknown)")
        assert_style_stripped("position: var(--unknown)")
        assert_style_stripped("display: var(--unknown)")
        assert_style_stripped("--unknown: red")
      end

      should "strip unexpected values for each style property" do
        assert_style_stripped("text-align: bogus")
        assert_style_stripped("float: url(http://example.com)")
        assert_style_stripped("color: 10px")
        assert_style_stripped("color: #12")
        assert_style_stripped("color: #12345")
        assert_style_stripped("color: not-a-color")
        assert_style_stripped("width: red")
        assert_style_stripped("height: 10")
        assert_style_stripped("margin: 5xyz")
        assert_style_stripped("opacity: red")
        assert_style_stripped("font-weight: expression")
        assert_style_stripped("border-style: red")
        assert_style_stripped("font-family: foo(bar)")
        assert_style_stripped("transform: foo(1)")
        assert_style_stripped("transform: blur(1px)")
        assert_style_stripped("filter: rotate(45deg)")
        assert_style_stripped("filter: url(http://example.com/a.svg#f)")
        assert_style_stripped("background: linear-gradient(red, blue) 5xyz")
      end

      should "strip values nested more deeply than the nesting depth" do
        assert_style_kept("width: #{"calc(" * 10}1px#{")" * 10}", max_css_nesting_depth: 10)
        assert_style_stripped("width: #{"calc(" * 11}1px#{")" * 11}", max_css_nesting_depth: 10)
        assert_style_stripped("width: #{"calc(" * 1000}1px#{")" * 1000}", max_css_nesting_depth: 10)
      end

      should "strip attr(), src(), env() and other unexpected functions, and var() outside color and font properties" do
        assert_style_stripped("background: attr(title url)")
        assert_style_stripped("background: attr(title type(<url>))")
        assert_style_stripped("background: src('http://example.com/a.png')")
        assert_style_stripped("background: image-set(attr(title url) 1x)")
        assert_style_stripped("background: image-set('http://example.com/a.png' 1x)")
        assert_style_stripped("background: linear-gradient(red, attr(title))")
        assert_style_stripped("border-image: attr(title url) 30")
        assert_style_stripped("width: env(safe-area-inset-top)")
        assert_style_stripped("width: calc(var(--x) + 1px)")
        assert_style_stripped("filter: blur(var(--x))")
        assert_style_stripped("color: rgb(var(--r), 0, 0)")
        assert_style_stripped('background: a\74tr(title url)')
        assert_style_stripped('width: V\61R(--x)')
        assert_style_stripped("background: image-set(var(--x) 1x)")
        assert_style_stripped("color: attr(title)")
      end
    end

    context "when sanitizing HTML" do
      should "strip unsafe tags" do
        body = '<p>test</p> <script>alert("owned")</script>'
        assert_equal("<p>test</p> ", NoteSanitizer.sanitize(body))
      end

      should "return the empty string if the HTML is nested more than 40 levels deep" do
        assert_equal("", NoteSanitizer.sanitize("<b>" * 41))
      end

      should "raise an error from sanitize! if the HTML is nested more than 40 levels deep" do
        assert_nothing_raised { NoteSanitizer.sanitize!("<b>" * 40) }
        assert_nothing_raised { NoteSanitizer.sanitize!("<b>" * 10, max_html_nesting_depth: 10) }
        assert_raises(NoteSanitizer::Error) { NoteSanitizer.sanitize!("<b>" * 41) }
        assert_raises(NoteSanitizer::Error) { NoteSanitizer.sanitize!("<b>" * 11, max_html_nesting_depth: 10) }
      end

      should "mark links as nofollow" do
        body = '<a href="http://www.google.com">google</a>'
        assert_equal('<a href="http://www.google.com" rel="external noreferrer nofollow">google</a>', NoteSanitizer.sanitize(body))
      end

      should "escape '<' characters properly" do
        assert_equal("foo &lt; bar", NoteSanitizer.sanitize("foo < bar"))
        assert_equal("foo &lt;- bar", NoteSanitizer.sanitize("foo <- bar"))
        assert_equal("foo &lt;3 bar", NoteSanitizer.sanitize("foo <3 bar"))
        assert_equal("foo &lt;: bar", NoteSanitizer.sanitize("foo <: bar"))
        assert_equal("foo &lt;&gt; bar", NoteSanitizer.sanitize("foo <> bar"))
        assert_equal("foo &lt;", NoteSanitizer.sanitize("foo <"))

        assert_equal("foo ", NoteSanitizer.sanitize("foo <x bar"))
        assert_equal("foo ", NoteSanitizer.sanitize("foo <? bar"))
        assert_equal("foo ", NoteSanitizer.sanitize("foo <! bar"))
        assert_equal("foo ", NoteSanitizer.sanitize("foo </ bar"))
      end
    end

    should "not fail on a frozen string" do
      assert_equal("", NoteSanitizer.sanitize("".freeze)) # rubocop:disable Style/RedundantFreeze
    end

    should "not fail on nil" do
      assert_equal("", NoteSanitizer.sanitize(nil))
    end
  end
end
