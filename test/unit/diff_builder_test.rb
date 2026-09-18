require "test_helper"
require "diff/lcs/array"
require "nokogiri"

class DiffBuilderTest < ActiveSupport::TestCase
  context "DiffBuilder" do
    should "only expose the name and body HTML entry points" do
      builder = DiffBuilder.new(old_text: "old", new_text: "new")

      assert_respond_to(builder, :name_html)
      assert_respond_to(builder, :body_html)
      assert_not_respond_to(builder, :build)
      assert_not_respond_to(builder, :pattern)
    end

    context "name diffs" do
      should "render the smallest single changed middle" do
        html = DiffBuilder.new(old_text: "foo_qux_baz", new_text: "foo_bar_baz").name_html

        assert_equal("foo_<del>qux</del><ins>bar</ins>_baz", html)
        assert_predicate(html, :html_safe?)
      end

      should "render unrelated names as one replacement" do
        html = DiffBuilder.new(old_text: "akiya_akira_(full_accel)", new_text: "neckwrecker").name_html

        assert_equal("<del>akiya_akira_(full_accel)</del><ins>neckwrecker</ins>", html)
      end

      should "handle empty names as additions and removals" do
        assert_equal("<ins>new</ins>", DiffBuilder.new(old_text: nil, new_text: "new").name_html)
        assert_equal("<del>old</del>", DiffBuilder.new(old_text: "old", new_text: nil).name_html)
        assert_equal("", DiffBuilder.new(old_text: nil, new_text: nil).name_html)
      end

      should "compare grapheme clusters without normalizing Unicode" do
        html = DiffBuilder.new(old_text: "A👩‍💻e\u0301Z", new_text: "A👨‍💻éZ").name_html

        assert_equal("A<del>👩‍💻e\u0301</del><ins>👨‍💻é</ins>Z", html)
      end

      should "escape untrusted and pre-marked-safe names" do
        text = %{<tag>&"'}.html_safe
        html = DiffBuilder.new(old_text: text, new_text: text).name_html

        assert_equal("&lt;tag&gt;&amp;&quot;&#39;", html)
        assert_predicate(html, :html_safe?)
      end
    end

    context "body diffs" do
      should "render exact additions, removals, and replacements" do
        assert_equal(
          "hello <ins>brave </ins>world",
          DiffBuilder.new(old_text: "hello world", new_text: "hello brave world").body_html,
        )
        assert_equal(
          "hello <del>brave </del>world",
          DiffBuilder.new(old_text: "hello brave world", new_text: "hello world").body_html,
        )
        assert_equal(
          "hello <del>black</del><ins>white</ins> cat",
          DiffBuilder.new(old_text: "hello black cat", new_text: "hello white cat").body_html,
        )
      end

      should "render local CJK changes as a single replacement" do
        assert_equal(
          "今日は<del>晴れ</del><ins>雨</ins>です",
          DiffBuilder.new(old_text: "今日は晴れです", new_text: "今日は雨です").body_html,
        )
        assert_equal(
          "今天<del>晴天</del><ins>下雨</ins>",
          DiffBuilder.new(old_text: "今天晴天", new_text: "今天下雨").body_html,
        )
        assert_equal(
          "<del>ネコ</del><ins>イヌ</ins>です",
          DiffBuilder.new(old_text: "ネコです", new_text: "イヌです").body_html,
        )
        assert_equal(
          "<del>검은</del><ins>흰</ins> 고양이",
          DiffBuilder.new(old_text: "검은 고양이", new_text: "흰 고양이").body_html,
        )
      end

      should "keep combining marks and emoji sequences intact" do
        html = DiffBuilder.new(
          old_text: "Use cafe\u0301 👩‍💻 now",
          new_text: "Use cafe\u0300 👨‍💻 now",
        ).body_html

        assert_equal("Use <del>cafe\u0301 👩‍💻</del><ins>cafe\u0300 👨‍💻</ins> now", html)
      end

      should "preserve separate edits around matching content" do
        old_text = "Alpha old first. This middle sentence stays unchanged. Omega old last."
        new_text = "Alpha new first. This middle sentence stays unchanged. Omega new last."

        assert_equal(
          "Alpha <del>old</del><ins>new</ins> first. This middle sentence stays unchanged. Omega <del>old</del><ins>new</ins> last.",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "render full additions, removals, and unchanged paragraphs" do
        paragraph = "same\nbody"
        rendered_paragraph = "same<span class=\"paragraph-mark\">¶</span><br>body"

        assert_equal("<ins>new</ins>", DiffBuilder.new(old_text: nil, new_text: "new").body_html)
        assert_equal("<del>old</del>", DiffBuilder.new(old_text: "old", new_text: nil).body_html)
        assert_equal(rendered_paragraph, DiffBuilder.new(old_text: paragraph, new_text: paragraph).body_html)
      end

      should "keep a local edit in an eighty thousand character body" do
        prefix = "same " * 8_000
        suffix = " tail" * 7_999
        old_text = "#{prefix}old#{suffix}"
        new_text = "#{prefix}new#{suffix}"

        assert_equal(
          "#{prefix}<del>old</del><ins>new</ins>#{suffix}",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "handle a long malformed angle-bracket sequence" do
        old_text = "<" * 79_999
        new_text = "#{old_text}x"

        assert_equal(
          "#{"&lt;" * 79_999}<ins>x</ins>",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "preserve edge-case angle-bracket tokenization" do
        old_text = "<> <<> <><a> tail"
        new_text = "<> <<> <><b> tail"

        assert_equal(
          "&lt;&gt; &lt;&lt;&gt; <del>&lt;&gt;&lt;a&gt;</del><ins>&lt;&gt;&lt;b&gt;</ins> tail",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "render a long single-token replacement" do
        old_text = "#{"a" * 79_999}x"
        new_text = "#{"a" * 79_999}y"

        assert_equal(
          "<del>#{old_text}</del><ins>#{new_text}</ins>",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "render issue 4788 as one unrelated replacement" do
        old_text = "家主が怖い番組を観ていて怖く出られなくなった幽霊さん。"
        new_text = "Miss Ghost, unable to show herself because the house owner is watching a scary TV program."

        assert_equal(
          "<del>#{old_text}</del><ins>#{new_text}</ins>",
          DiffBuilder.new(old_text:, new_text:).body_html,
        )
      end

      should "exclude markup and underscores but count symbols as content" do
        old_structural_text = "alpha _ <b> beta"
        new_structural_text = "gamma _ <b> delta"
        old_symbol_text = "甲乙👩‍💻丙"
        new_symbol_text = "丁戊👩‍💻己"

        assert_equal(
          "<del>alpha _ &lt;b&gt; beta</del><ins>gamma _ &lt;b&gt; delta</ins>",
          DiffBuilder.new(old_text: old_structural_text, new_text: new_structural_text).body_html,
        )
        assert_not_equal(
          replacement_html(old_symbol_text, new_symbol_text),
          DiffBuilder.new(old_text: old_symbol_text, new_text: new_symbol_text).body_html,
        )
      end

      should "use a strict ten percent content coverage threshold" do
        old_at_threshold = "甲乙丙丁戊己庚辛壬癸"
        old_below_threshold = "甲乙丙丁戊己庚辛壬癸亥"
        new_text = "子丑寅卯辰己午未申酉"
        wholesale_at_threshold = replacement_html(old_at_threshold, new_text)

        assert_not_equal(wholesale_at_threshold, DiffBuilder.new(old_text: old_at_threshold, new_text:).body_html)
        assert_equal(
          replacement_html(old_below_threshold, new_text),
          DiffBuilder.new(old_text: old_below_threshold, new_text:).body_html,
        )
      end

      should "render formatting-only changes without corrupting either text" do
        assert_equal(
          "hello<del><span class=\"paragraph-mark\">¶</span></del><ins><span class=\"paragraph-mark\">¶</span></ins><br>world",
          DiffBuilder.new(old_text: "hello\nworld", new_text: "hello\r\nworld").body_html,
        )
        assert_equal(
          "<del>hello<span class=\"paragraph-mark\">¶</span><br>world</del><ins>helloworld</ins>",
          DiffBuilder.new(old_text: "hello\nworld", new_text: "helloworld").body_html,
        )
        assert_equal(
          "<del>helloworld</del><ins>hello<span class=\"paragraph-mark\">¶</span><br>world</ins>",
          DiffBuilder.new(old_text: "helloworld", new_text: "hello\nworld").body_html,
        )
        assert_equal(
          "hello<span class=\"paragraph-mark\">¶</span><br><ins><span class=\"paragraph-mark\">¶</span><br></ins>world",
          DiffBuilder.new(old_text: "hello\nworld", new_text: "hello\n\nworld").body_html,
        )
        assert_equal(
          "hello<del>,</del><ins>!</ins>world",
          DiffBuilder.new(old_text: "hello,world", new_text: "hello!world").body_html,
        )
        assert_equal(
          "hello<del> </del><ins>\t</ins>world",
          DiffBuilder.new(old_text: "hello world", new_text: "hello\tworld").body_html,
        )
      end

      should "preserve matching context for formatting-only edits with low content coverage" do
        assert_equal(
          "<del>aaa_bbb</del><ins>aaabbb</ins> &lt;tag&gt; <del>ccc_ddd</del><ins>cccddd</ins>",
          DiffBuilder.new(old_text: "aaa_bbb <tag> ccc_ddd", new_text: "aaabbb <tag> cccddd").body_html,
        )
      end

      should "consider content order when deciding whether text is related" do
        old_text = "ab <b> cd"
        new_text = "dc <b> ba"

        assert_equal(replacement_html(old_text, new_text), DiffBuilder.new(old_text:, new_text:).body_html)
      end

      should "preserve both texts without nesting change tags" do
        texts = ["", "a", "b", "a b", "b a", "a\nb", "a\r\nb", "ab", "a b c", "c b d", "甲乙👩‍💻", "<b>a & \"b\"</b>", "e\u0301 e\u0300"]

        texts.product(texts) do |old_text, new_text|
          html = DiffBuilder.new(old_text:, new_text:).body_html
          assert_body_texts_preserved(html, old_text, new_text)
        end
      end

      should "preserve formatting detail on both sides of the LCS work budget" do
        rendered_word = "a<del> </del><ins>\t</ins>"
        # The work estimates are 997,817 and 1,004,454, respectively.
        assert_equal(
          "#{rendered_word * 302}z",
          DiffBuilder.new(old_text: "#{"a " * 302}z", new_text: "#{"a\t" * 302}z").body_html,
        )

        Diff::LCS.expects(:diff).never
        assert_equal(
          "#{rendered_word * 303}z",
          DiffBuilder.new(old_text: "#{"a " * 303}z", new_text: "#{"a\t" * 303}z").body_html,
        )
      end

      should "preserve formatting-only changes above the LCS token budget and keep common edges" do
        changes = [
          ["a ", "a\t", "a<del> </del><ins>\t</ins>"],
          ["a\n", "a\r\n", 'a<del><span class="paragraph-mark">¶</span></del><ins><span class="paragraph-mark">¶</span></ins><br>'],
        ]

        Diff::LCS.expects(:diff).never
        changes.each do |old_segment, new_segment, rendered_segment|
          old_text = "#{old_segment * 10_001}z"
          new_text = "#{new_segment * 10_001}z"

          assert_equal(
            "#{rendered_segment * 10_001}z",
            DiffBuilder.new(old_text:, new_text:).body_html,
          )
        end
      end

      should "preserve graphemes when formatting changes token boundaries above the LCS budget" do
        changes = [
          ["a_b ", "ab ", "a<del>_</del>b "],
          ["a b ", "ab ", "a<del> </del>b "],
          ["ab ", "a b ", "a<ins> </ins>b "],
          ["👩‍💻 e\u0301 ", "👩‍💻\te\u0301\t", "👩‍💻<del> </del><ins>\t</ins>e\u0301<del> </del><ins>\t</ins>"],
        ]

        Diff::LCS.expects(:diff).never
        changes.each do |old_segment, new_segment, rendered_segment|
          old_text = "#{old_segment * 303}z"
          new_text = "#{new_segment * 303}z"
          html = DiffBuilder.new(old_text:, new_text:).body_html

          assert_equal("#{rendered_segment * 303}z", html)
          assert_body_texts_preserved(html, old_text, new_text)
        end
      end

      should "preserve individual blank line insertions above the LCS budget" do
        old_text = "#{"line\n" * 303}end"
        new_text = "#{"line\n\n" * 303}end"

        Diff::LCS.expects(:diff).never
        html = DiffBuilder.new(old_text:, new_text:).body_html
        fragment = Nokogiri::HTML5.fragment(html)

        assert_empty(fragment.css("del"))
        assert_equal(Array.new(303, '<span class="paragraph-mark">¶</span><br>'), fragment.css("ins").map(&:inner_html))
        assert_body_texts_preserved(html, old_text, new_text)
      end

      should "escape formatting changes in SafeBuffers above the LCS work budget" do
        repeated_format = "<x>" * 400
        old_format = "#{repeated_format}<old&>"
        new_format = "_\"'#{repeated_format}"
        old_text = ActiveSupport::SafeBuffer.new("a#{old_format}z")
        new_text = ActiveSupport::SafeBuffer.new("a#{new_format}z")
        # "a" is shared content even though the new side starts with the word token "a_".
        expected = "a#{replacement_html(old_format, new_format)}z"

        Diff::LCS.expects(:diff).never
        html = DiffBuilder.new(old_text:, new_text:).body_html

        assert_equal(expected, html)
        assert_predicate(html, :html_safe?)
        assert_body_texts_preserved(html, old_text, new_text)
      end

      should "discard partial formatting diffs when content differs above the LCS budget" do
        endings = [["z", "y"], ["z", "zq"], ["zq", "z"], ["ab", "ba"], ["é", "e\u0301"], ["👩‍💻", "👨‍💻"]]

        Diff::LCS.expects(:diff).never
        endings.each do |old_ending, new_ending|
          old_middle = " #{"a " * 302}#{old_ending}"
          new_middle = "\t#{"a\t" * 302}#{new_ending}"
          old_text = "a#{old_middle}"
          new_text = "a#{new_middle}"
          html = DiffBuilder.new(old_text:, new_text:).body_html

          assert_equal("a#{replacement_html(old_middle, new_middle)}", html)
          assert_body_texts_preserved(html, old_text, new_text)
        end
      end

      should "escape all body paths even for a SafeBuffer input" do
        old_text = %{<b>&"'}.html_safe
        new_text = %{<script>&"'}.html_safe
        html = DiffBuilder.new(old_text:, new_text:).body_html

        assert_equal("<del>&lt;b&gt;</del><ins>&lt;script&gt;</ins>&amp;&quot;&#39;", html)
        assert_predicate(html, :html_safe?)
      end

      should "run LCS only once for a detailed diff" do
        old_tokens = ["old", " ", "anchor", " ", "old"]
        new_tokens = ["new", " ", "anchor", " ", "new"]
        diffs = Diff::LCS.diff(old_tokens, new_tokens, Diff::LCS::ContextDiffCallbacks.new)
        Diff::LCS.expects(:diff).once.returns(diffs)

        assert_equal(
          "<del>old</del><ins>new</ins> anchor <del>old</del><ins>new</ins>",
          DiffBuilder.new(old_text: old_tokens.join, new_text: new_tokens.join).body_html,
        )
      end

      should "run LCS once before replacing unrelated content" do
        diffs = Diff::LCS.diff(["old"], ["new"], Diff::LCS::ContextDiffCallbacks.new)
        Diff::LCS.expects(:diff).once.returns(diffs)

        assert_equal(
          "<del>old</del><ins>new</ins>",
          DiffBuilder.new(old_text: "old", new_text: "new").body_html,
        )
      end

      should "allow work exactly at the LCS budget and reject work above it" do
        # 5,001 + 5,003 + (265² + 3×163) × (1 + 13) = 1,000,000.
        old_text = repeated_tag_text(total: 5_001, x_count: 265, y_count: 3, side: "old")
        new_at_budget = repeated_tag_text(total: 5_003, x_count: 265, y_count: 163, side: "new")
        new_over_budget = repeated_tag_text(total: 5_003, x_count: 265, y_count: 164, side: "new")

        assert_not_equal(replacement_html(old_text, new_at_budget), DiffBuilder.new(old_text:, new_text: new_at_budget).body_html)

        Diff::LCS.expects(:diff).never
        assert_equal(
          replacement_html(old_text, new_over_budget),
          DiffBuilder.new(old_text:, new_text: new_over_budget).body_html,
        )
      end

      should "allow twenty thousand changed tokens and reject more" do
        old_text = anchored_tag_text(total: 10_000, side: "old")
        new_at_budget = anchored_tag_text(total: 10_000, side: "new")
        new_over_budget = anchored_tag_text(total: 10_001, side: "new")

        assert_not_equal(replacement_html(old_text, new_at_budget), DiffBuilder.new(old_text:, new_text: new_at_budget).body_html)

        Diff::LCS.expects(:diff).never
        assert_equal(
          replacement_html(old_text, new_over_budget),
          DiffBuilder.new(old_text:, new_text: new_over_budget).body_html,
        )
      end
    end
  end

  private

  def assert_body_texts_preserved(html, old_text, new_text)
    fragment = Nokogiri::HTML5.fragment(html)
    assert_empty(fragment.css("del ins, ins del, del del, ins ins"), [old_text, new_text].inspect)

    [["ins", old_text], ["del", new_text]].each do |removed_tag, expected_text|
      version = fragment.dup
      version.css("#{removed_tag}, span.paragraph-mark").remove
      version.css("br").each { |br| br.replace("\n") }

      assert_equal(expected_text.gsub(/\r?\n/, "\n"), version.text, [old_text, new_text, removed_tag].inspect)
    end
  end

  def replacement_html(old_text, new_text)
    html = "<del>#{ERB::Util.html_escape(String.new(old_text))}</del><ins>#{ERB::Util.html_escape(String.new(new_text))}</ins>"
    html.gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>')
  end

  # Construct a body with an exact token count and a controlled number of equal-token pairs.
  def repeated_tag_text(total:, x_count:, y_count:, side:)
    unique_count = total - x_count - y_count - 2
    (["<#{side}-start>"] + Array.new(x_count, "<x>") + Array.new(y_count, "<y>") +
      Array.new(unique_count) { |index| "<#{side}-#{index}>" } + ["<#{side}-end>"]).join
  end

  # Construct distinct bodies with one shared token to exercise the LCS token limit.
  def anchored_tag_text(total:, side:)
    unique_count = total - 3
    before_count = unique_count / 2
    after_count = unique_count - before_count

    (["<#{side}-start>"] + Array.new(before_count) { |index| "<#{side}-before-#{index}>" } + ["<anchor>"] +
      Array.new(after_count) { |index| "<#{side}-after-#{index}>" } + ["<#{side}-end>"]).join
  end
end
