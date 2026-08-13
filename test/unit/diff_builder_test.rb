require "test_helper"
require "diff/lcs/array"

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

      should "stream content analysis for one long token" do
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

      should "send formatting-only changes through the legacy renderer" do
        assert_equal(
          "hello<del><span class=\"paragraph-mark\">¶</span></del><ins><span class=\"paragraph-mark\">¶</span></ins><br>world",
          DiffBuilder.new(old_text: "hello\nworld", new_text: "hello\r\nworld").body_html,
        )
        assert_equal(
          "<del>hellohelloworld<span class=\"paragraph-mark\">¶</span><br></del>world",
          DiffBuilder.new(old_text: "hello\nworld", new_text: "helloworld").body_html,
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

      should "keep formatting-only changes detailed above the LCS budget" do
        old_text = "#{"a " * 10_001}z"
        new_text = "#{"a\t" * 10_001}z"
        expected = "#{"a<del> </del><ins>\t</ins>" * 10_001}z"
        old_lines = "#{"a\n" * 10_001}z"
        new_lines = "#{"a\r\n" * 10_001}z"
        diffed_line = "a<del><span class=\"paragraph-mark\">¶</span></del><ins><span class=\"paragraph-mark\">¶</span></ins><br>"

        Diff::LCS.expects(:diff).never
        assert_equal(expected, DiffBuilder.new(old_text:, new_text:).body_html)
        assert_equal("#{diffed_line * 10_001}z", DiffBuilder.new(old_text: old_lines, new_text: new_lines).body_html)
      end

      should "keep formatting-only changes detailed above the LCS work budget" do
        repeated_format = "<x>" * 400
        old_format = "#{repeated_format}<old&>"
        new_format = "_\"'#{repeated_format}"
        old_text = ActiveSupport::SafeBuffer.new("a#{old_format}z")
        new_text = ActiveSupport::SafeBuffer.new("a#{new_format}z")
        expected = "a<del>#{"&lt;x&gt;" * 400}&lt;old&amp;&gt;</del><ins>_&quot;&#39;#{"&lt;x&gt;" * 400}</ins>z"

        Diff::LCS.expects(:diff).never
        assert_equal(expected, DiffBuilder.new(old_text:, new_text:).body_html)
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

  def replacement_html(old_text, new_text)
    "<del>#{ERB::Util.html_escape(old_text)}</del><ins>#{ERB::Util.html_escape(new_text)}</ins>"
  end

  def repeated_tag_text(total:, x_count:, y_count:, side:)
    unique_count = total - x_count - y_count - 2
    (["<#{side}-start>"] + Array.new(x_count, "<x>") + Array.new(y_count, "<y>") +
      Array.new(unique_count) { |index| "<#{side}-#{index}>" } + ["<#{side}-end>"]).join
  end

  def anchored_tag_text(total:, side:)
    unique_count = total - 3
    before_count = unique_count / 2
    after_count = unique_count - before_count

    (["<#{side}-start>"] + Array.new(before_count) { |index| "<#{side}-before-#{index}>" } + ["<anchor>"] +
      Array.new(after_count) { |index| "<#{side}-after-#{index}>" } + ["<#{side}-end>"]).join
  end
end
