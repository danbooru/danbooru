class TagBatchChangeJob < ApplicationJob
  class Error < Exception; end

  queue_as :default

  def perform(antecedent, consequent, updater, updater_ip_addr)
    raise Error.new("antecedent is missing") if antecedent.blank?

    normalized_antecedent = TagAlias.to_aliased(::Tag.scan_tags(antecedent.mb_chars.downcase))
    normalized_consequent = TagAlias.to_aliased(::Tag.scan_tags(consequent.mb_chars.downcase))

    CurrentUser.without_safe_mode do
      CurrentUser.scoped(updater, updater_ip_addr) do
        migrate_posts(normalized_antecedent, normalized_consequent)
        migrate_saved_searches(normalized_antecedent, normalized_consequent)
        migrate_blacklists(normalized_antecedent, normalized_consequent)

        ModAction.log("processed mass update: #{antecedent} -> #{consequent}", :mass_update)
      end
    end
  end

  def self.estimate_update_count(antecedent, consequent)
    CurrentUser.without_safe_mode do
      Post.tag_match(antecedent).count
    end
  end

  def migrate_posts(normalized_antecedent, normalized_consequent)
    ::Post.tag_match(normalized_antecedent.join(" ")).find_each do |post|
      post.reload
      tags = (post.tag_array - normalized_antecedent + normalized_consequent).join(" ")
      post.update(tag_string: tags)
    end
  end

  def migrate_saved_searches(normalized_antecedent, normalized_consequent)
    tags = Tag.scan_tags(normalized_antecedent.join(" "), strip_metatags: true)

    # https://www.postgresql.org/docs/current/static/functions-array.html
    saved_searches = SavedSearch.where("string_to_array(query, ' ') @> ARRAY[?]", tags)
    saved_searches.find_each do |ss|
      ss.query = (ss.query.split - tags + normalized_consequent).uniq.join(" ")
      ss.save
    end
  end

  # this can't handle negated tags or other special cases
  def migrate_blacklists(normalized_antecedent, normalized_consequent)
    query = normalized_antecedent
    adds = normalized_consequent
    arel = query.inject(User.none) do |scope, x|
      scope.or(User.where("blacklisted_tags like ?", "%" + x.to_escaped_for_sql_like + "%"))
    end

    arel.find_each do |user|
      changed = false

      begin
        repl = user.blacklisted_tags.split(/\r\n|\r|\n/).map do |line|
          list = Tag.scan_tags(line)

          if (list & query).size != query.size
            next line
          end

          changed = true
          (list - query + adds).join(" ")
        end

        if changed
          user.update(blacklisted_tags: repl.join("\n"))
        end
      rescue Exception => e
        DanbooruLogger.log(e)
      end
    end
  end
end
