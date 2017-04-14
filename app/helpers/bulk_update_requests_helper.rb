module BulkUpdateRequestsHelper
  def approved?(command, antecedent, consequent)
    return false unless CurrentUser.is_moderator?

    case command
    when :create_alias
      TagAlias.where(antecedent_name: antecedent, consequent_name: consequent, status: %w(active processing queued)).exists?

    when :create_implication
      TagImplication.where(antecedent_name: antecedent, consequent_name: consequent, status: %w(active processing queued)).exists?

    when :remove_alias
      TagAlias.where(antecedent_name: antecedent, consequent_name: consequent, status: "deleted").exists? || !TagAlias.where(antecedent_name: antecedent, consequent_name: consequent).exists?

    when :remove_implication
      TagImplication.where(antecedent_name: antecedent, consequent_name: consequent, status: "deleted").exists? || !TagImplication.where(antecedent_name: antecedent, consequent_name: consequent).exists?

    when :mass_update
      !Post.raw_tag_match(antecedent).exists?

    else
      false
    end
  end

  def failed?(command, antecedent, consequent)
    return false unless CurrentUser.is_moderator?

    case command
    when :create_alias
      TagAlias.where(antecedent_name: antecedent, consequent_name: consequent).where("status like ?", "error: %").exists?

    when :create_implication
      TagImplication.where(antecedent_name: antecedent, consequent_name: consequent).where("status like ?", "error: %").exists?

    else
      false
    end
  end

  def script_with_line_breaks(script)
    escaped_script = AliasAndImplicationImporter.tokenize(script).map do |cmd, arg1, arg2|
      case cmd
      when :create_alias, :create_implication, :remove_alias, :remove_implication, :mass_update
        if approved?(cmd, arg1, arg2)
          btag = '<s class="approved">'
          etag = '</s>'
        elsif failed?(cmd, arg1, arg2)
          btag = '<s class="failed">'
          etag = "</s>"
        else
          btag = nil
          etag = nil
        end
      end

      case cmd
      when :create_alias
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "#{btag}create alias " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})#{etag}"

      when :create_implication
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "#{btag}create implication " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})#{etag}"

      when :remove_alias
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "#{btag}remove alias " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})#{etag}"

      when :remove_implication
        arg1_count = Tag.find_by_name(arg1).try(:post_count).to_i
        arg2_count = Tag.find_by_name(arg2).try(:post_count).to_i

        "#{btag}remove implication " + link_to(arg1, posts_path(:tags => arg1)) + " (#{arg1_count}) -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + " (#{arg2_count})#{etag}"

      when :mass_update
        "#{btag}mass update " + link_to(arg1, posts_path(:tags => arg1)) + " -&gt; " + link_to(arg2, posts_path(:tags => arg2)) + "#{etag}"

      end
    end.join("\n")

    escaped_script.gsub(/\n/m, "<br>").html_safe
  end
end
