module ForumTopicsHelper
  def forum_topic_category_select(object, field)
    select(object, field, ForumTopic.reverse_category_mapping.to_a)
  end

  def available_min_user_levels
    ForumTopic::MIN_LEVELS.select { |name, level| level <= CurrentUser.level }.to_a
  end

  def tag_request_message(obj)
    if obj.is_a?(TagRelationship)
      if obj.is_approved?
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been approved."
      elsif obj.is_retired?
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been retired."
      elsif obj.is_deleted?
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has been rejected."
      elsif obj.is_pending?
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] is pending approval."
      elsif obj.is_errored?
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] (#{relationship} failed during processing."
      else # should never happen
        return "The #{obj.relationship} ##{obj.id} [[#{obj.antecedent_name}]] -> [[#{obj.consequent_name}]] has an unknown status."
      end
    end

    if obj.is_a?(BulkUpdateRequest)
      if obj.script.size < 700
        embedded_script = obj.script_with_links
      else
        embedded_script = "[expand]#{obj.script_with_links}[/expand]"
      end

      if obj.is_approved?
        return "The bulk update request ##{obj.id} is active.\n\n#{embedded_script}"
      elsif obj.is_pending?
        return "The \"bulk update request ##{obj.id}\":/bulk_update_requests/#{obj.id} is pending approval.\n\n#{embedded_script}"
      elsif obj.is_rejected?
        return "The bulk update request ##{obj.id} has been rejected.\n\n#{embedded_script}"
      end
    end
  end

  def parse_embedded_tag_request_text(text)
    [TagAlias, TagImplication, BulkUpdateRequest].each do |tag_request|
      text = text.gsub(tag_request.embedded_pattern) do |match|
        begin
          obj = tag_request.find($~[:id])
          tag_request_message(obj) || match

        rescue ActiveRecord::RecordNotFound
          match
        end
      end
    end

    text
  end
end
