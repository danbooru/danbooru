require 'test_helper'

class TagChangeRequestPrunerTest < ActiveSupport::TestCase
  setup do
    CurrentUser.user = FactoryBot.create(:admin_user)
    CurrentUser.ip_addr = "127.0.0.1"

    @forum_topic = create(:forum_topic)
    @tag_alias = create(:tag_alias, forum_topic: @forum_topic)
    @tag_implication = create(:tag_implication, antecedent_name: "ccc", consequent_name: "ddd", forum_topic: @forum_topic)
    @bulk_update_request = create(:bulk_update_request, script: "alias eee -> fff", forum_topic: @forum_topic)
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  subject { TagChangeRequestPruner.new }

  context '#warn_old' do
    setup do
      [TagAlias, TagImplication, BulkUpdateRequest].each do |model|
        model.update_all(status: "pending", created_at: (TagRelationship::EXPIRY_WARNING + 1).days.ago)
      end
    end

    should "update the forum topic for an alias" do
      ForumUpdater.any_instance.expects(:update)
      subject.warn_old(TagAlias)
    end

    should "update the forum topic for an implication" do
      ForumUpdater.any_instance.expects(:update)
      subject.warn_old(TagImplication)
    end

    should "update the forum topic for a bulk update request" do
      ForumUpdater.any_instance.expects(:update)
      subject.warn_old(BulkUpdateRequest)
    end
  end

  context '#reject_expired' do
    setup do
      [TagAlias, TagImplication, BulkUpdateRequest].each do |model|
        model.update_all(status: "pending", created_at: (TagRelationship::EXPIRY + 1).days.ago)
      end
    end

    should "reject the alias" do
      TagAlias.any_instance.expects(:reject!)
      subject.reject_expired(TagAlias)
    end

    should "reject the implication" do
      TagImplication.any_instance.expects(:reject!)
      subject.reject_expired(TagImplication)
    end

    should "reject the bulk update request" do
      BulkUpdateRequest.any_instance.expects(:reject!)
      subject.reject_expired(BulkUpdateRequest)
    end
  end
end
