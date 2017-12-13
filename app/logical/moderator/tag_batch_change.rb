module Moderator
  class TagBatchChange < Struct.new(:antecedent, :consequent, :updater_id, :updater_ip_addr)
    class Error < Exception ; end

    def perform
      raise Error.new("antecedent is missing") if antecedent.blank?

      normalized_antecedent = TagAlias.to_aliased(::Tag.scan_tags(antecedent.mb_chars.downcase))
      normalized_consequent = TagAlias.to_aliased(::Tag.scan_tags(consequent.mb_chars.downcase))

      updater = User.find(updater_id)

      CurrentUser.without_safe_mode do
        CurrentUser.scoped(updater, updater_ip_addr) do
          ::Post.tag_match(antecedent).where("true /* Moderator::TagBatchChange#perform */").find_each do |post|
            post.reload
            tags = (post.tag_array - normalized_antecedent + normalized_consequent).join(" ")
            post.update_attributes(:tag_string => tags)
          end

          if SavedSearch.enabled?
            tags = Tag.scan_tags(antecedent, :strip_metatags => true)

            # https://www.postgresql.org/docs/current/static/functions-array.html
            saved_searches = SavedSearch.where("string_to_array(query, ' ') @> ARRAY[?]", tags)
            saved_searches.find_each do |ss|
              ss.query = (ss.query.split - tags + [consequent]).uniq.join(" ")
              ss.save
            end
          end
        end
      end

      ModAction.log("processed mass update: #{antecedent} -> #{consequent}")
    end
  end
end
