module Moderator
  class TagBatchChange < Struct.new(:antecedent, :consequent, :updater_id, :updater_ip_addr)
    class Error < Exception ; end

    def perform
      raise Error.new("antecedent is missing") if antecedent.blank?

      normalized_antecedent = TagAlias.to_aliased(::Tag.scan_tags(antecedent))
      normalized_consequent = TagAlias.to_aliased(::Tag.scan_tags(consequent))

      updater = User.find(updater_id)

      CurrentUser.without_safe_mode do
        CurrentUser.scoped(updater, updater_ip_addr) do
          ::Post.tag_match(antecedent).each do |post|
            tags = (post.tag_array - normalized_antecedent + normalized_consequent).join(" ")
            post.update_attributes(:tag_string => tags)
          end
        end
      end
    end
  end
end
