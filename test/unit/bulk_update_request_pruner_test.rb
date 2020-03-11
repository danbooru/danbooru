require 'test_helper'

class BulkUpdateRequestPrunerTest < ActiveSupport::TestCase
  context '#warn_old' do
    should "update the forum topic for a bulk update request" do
      forum_topic = as(create(:user)) { create(:forum_topic) }
      bur = create(:bulk_update_request, status: "pending", forum_topic: forum_topic, created_at: (TagRelationship::EXPIRY_WARNING + 1).days.ago)

      BulkUpdateRequestPruner.warn_old
      assert_equal("pending", bur.reload.status)
      assert_match(/pending automatic rejection/, ForumPost.last.body)
    end
  end

  context '#reject_expired' do
    should "reject the bulk update request" do
      forum_topic = as(create(:user)) { create(:forum_topic) }
      bur = create(:bulk_update_request, status: "pending", forum_topic: forum_topic, created_at: (TagRelationship::EXPIRY + 1).days.ago)

      BulkUpdateRequestPruner.reject_expired
      assert_equal("rejected", bur.reload.status)
      assert_match(/rejected because it was not approved within 60 days/, bur.forum_post.body)
    end
  end
end
