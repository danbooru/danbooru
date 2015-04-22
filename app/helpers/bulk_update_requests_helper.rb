module BulkUpdateRequestsHelper
  def script_with_line_breaks(script)
    escaped_script = AliasAndImplicationImporter.tokenize(script).map do |cmd, arg1, arg2|
      case cmd
      when :create_alias
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "create_alias " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})"

      when :create_implication
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "create_implication " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})"

      when :remove_alias
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "remove_alias " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})"

      when :remove_implication
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "remove_implication " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})"

      when :mass_update
        "mass_update " + link_to(arg1, posts_path(:tags => arg1)) + " -&gt; " + link_to(arg2, posts_path(:tags => arg2))

      end
    end.join("\n")

    escaped_script.gsub(/\n/m, "<br>").html_safe
  end
end
