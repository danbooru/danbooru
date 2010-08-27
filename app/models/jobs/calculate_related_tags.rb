module Jobs
  class CalculateRelatedTags < Struct.new(:tag_id)
    def perform
      tag = Tag.find_by_id(tag_id)

      if tag
        tag.update_related
        tag.save
      end
    end
  end
end
