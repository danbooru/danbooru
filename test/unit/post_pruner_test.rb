require 'test_helper'

class PostPrunerTest < ActiveSupport::TestCase
  def setup
    @old_post = FactoryBot.create(:post, :created_at => 5.days.ago, :is_pending => true)
    @unresolved_flagged_post = FactoryBot.create(:post, :is_flagged => true)
    @resolved_flagged_post = FactoryBot.create(:post, :is_flagged => true)

    @flagger = create(:gold_user, created_at: 2.weeks.ago)
    @unresolved_post_flag = create(:post_flag, creator: @flagger, created_at: 5.days.ago, is_resolved: false, post: @unresolved_flagged_post)
    @resolved_post_flag = create(:post_flag, creator: @flagger, created_at: 5.days.ago, is_resolved: true, post: @resolved_flagged_post)

    PostPruner.new.prune!
  end

  should "prune old pending posts" do
    @old_post.reload
    assert(@old_post.is_deleted?)
  end

  should "prune old flagged posts that are still unresolved" do
    @unresolved_flagged_post.reload
    assert(@unresolved_flagged_post.is_deleted?)
  end

  should "not prune old flagged posts that are resolved" do
    @resolved_flagged_post.reload
    assert(!@resolved_flagged_post.is_deleted?)
  end
end
