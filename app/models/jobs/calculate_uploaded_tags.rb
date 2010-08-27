module Jobs
  class CalculateUploadedTags < Struct.new(:user_id)
    def perform
      tags = []
      user = User.find(user_id)
      CONFIG["tag_types"].values.uniq.each do |tag_type|
        tags += user.calculate_uploaded_tags(tag_type)
      end
      user.update_attribute(:uploaded_tags, tags.join("\n"))
    end
  end
end

