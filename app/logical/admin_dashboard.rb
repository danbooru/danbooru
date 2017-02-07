class AdminDashboard
  def tag_aliases
    TagAlias.where(status: "pending").order("id desc")
  end

  def tag_implications
    TagImplication.where(status: "pending").order("id desc")
  end

  def update_requests
    BulkUpdateRequest.where(status: "pending").order("id desc")
  end

  def forum_topics
    ForumTopic.search(category_id: 1).order("id desc").limit(20)
  end
end
