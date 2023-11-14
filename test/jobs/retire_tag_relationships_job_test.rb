require 'test_helper'

class RetireTagRelationshipsJobTest < ActiveJob::TestCase
  context "RetireTagRelationshipsJob" do
    should "create a new forum topic if one doesn't already exist" do
      create(:tag_alias, created_at: 3.years.ago, antecedent_name: "0", consequent_name: "1")
      RetireTagRelationshipsJob.perform_now

      assert_equal(true, ForumTopic.exists?(title: TagRelationshipRetirementService::FORUM_TOPIC_TITLE))
      assert_equal(true, ForumPost.exists?(body: TagRelationshipRetirementService::FORUM_TOPIC_BODY))
    end

    should "retire inactive gentag and artist aliases" do
      ta0 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "0", consequent_name: "artist")
      ta1 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "1", consequent_name: "general")
      ta2 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "2", consequent_name: "character")
      ta3 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "3", consequent_name: "copyright")
      ta4 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "4", consequent_name: "meta")

      as(User.system) do
        create(:post, created_at: 3.years.ago, tag_string: "art:artist")
        create(:post, created_at: 3.years.ago, tag_string: "gen:general")
        create(:post, created_at: 3.years.ago, tag_string: "char:character")
        create(:post, created_at: 3.years.ago, tag_string: "copy:copyright")
        create(:post, created_at: 3.years.ago, tag_string: "meta:meta")
      end

      RetireTagRelationshipsJob.perform_now

      assert_equal(true, ta0.reload.is_retired?)
      assert_equal(true, ta1.reload.is_retired?)
      assert_equal(false, ta2.reload.is_retired?)
      assert_equal(false, ta3.reload.is_retired?)
      assert_equal(false, ta4.reload.is_retired?)
    end

    should "not retire old aliases with recent posts" do
      ta0 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "0", consequent_name: "artist")
      ta1 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "1", consequent_name: "general")
      ta2 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "2", consequent_name: "character")
      ta3 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "3", consequent_name: "copyright")
      ta4 = create(:tag_alias, created_at: 3.years.ago, antecedent_name: "4", consequent_name: "meta")

      as(User.system) do
        create(:post, created_at: 1.week.ago, tag_string: "art:artist")
        create(:post, created_at: 1.week.ago, tag_string: "gen:general")
        create(:post, created_at: 1.week.ago, tag_string: "char:character")
        create(:post, created_at: 1.week.ago, tag_string: "copy:copyright")
        create(:post, created_at: 1.week.ago, tag_string: "meta:meta")
      end

      RetireTagRelationshipsJob.perform_now

      assert_equal(true, ta0.reload.is_retired?)
      assert_equal(false, ta1.reload.is_retired?)
      assert_equal(false, ta2.reload.is_retired?)
      assert_equal(false, ta3.reload.is_retired?)
      assert_equal(false, ta4.reload.is_retired?)
    end

    should "retire empty aliases" do
      create(:tag, name: "artist",    post_count: 0, category: Tag.categories.artist)
      create(:tag, name: "general",   post_count: 0, category: Tag.categories.general)
      create(:tag, name: "character", post_count: 0, category: Tag.categories.character)
      create(:tag, name: "copyright", post_count: 0, category: Tag.categories.copyright)
      create(:tag, name: "meta",      post_count: 0, category: Tag.categories.meta)

      ta0 = create(:tag_alias, antecedent_name: "0", consequent_name: "artist")
      ta1 = create(:tag_alias, antecedent_name: "1", consequent_name: "general")
      ta2 = create(:tag_alias, antecedent_name: "2", consequent_name: "character")
      ta3 = create(:tag_alias, antecedent_name: "3", consequent_name: "copyright")
      ta4 = create(:tag_alias, antecedent_name: "4", consequent_name: "meta")

      RetireTagRelationshipsJob.perform_now

      assert_equal(true, ta0.reload.is_retired?)
      assert_equal(true, ta1.reload.is_retired?)
      assert_equal(true, ta2.reload.is_retired?)
      assert_equal(true, ta3.reload.is_retired?)
      assert_equal(true, ta4.reload.is_retired?)
    end

    should "retire empty implications" do
      create(:tag, name: "artist",    post_count: 0, category: Tag.categories.artist)
      create(:tag, name: "general",   post_count: 0, category: Tag.categories.general)
      create(:tag, name: "character", post_count: 0, category: Tag.categories.character)
      create(:tag, name: "copyright", post_count: 0, category: Tag.categories.copyright)
      create(:tag, name: "meta",      post_count: 0, category: Tag.categories.meta)

      ta0 = create(:tag_implication, antecedent_name: "artist",    consequent_name: "1")
      ta1 = create(:tag_implication, antecedent_name: "general",   consequent_name: "1")
      ta2 = create(:tag_implication, antecedent_name: "character", consequent_name: "1")
      ta3 = create(:tag_implication, antecedent_name: "copyright", consequent_name: "1")
      ta4 = create(:tag_implication, antecedent_name: "meta",      consequent_name: "1")

      RetireTagRelationshipsJob.perform_now

      assert_equal(true, ta0.reload.is_retired?)
      assert_equal(true, ta1.reload.is_retired?)
      assert_equal(true, ta2.reload.is_retired?)
      assert_equal(true, ta3.reload.is_retired?)
      assert_equal(true, ta4.reload.is_retired?)
    end

    should "not retire empty banned_artist implications" do
      bkub = create(:tag, name: "bkub", post_count: 0, category: Tag.categories.artist)
      banned_artist = create(:tag, name: "banned_artist", post_count: 0, category: Tag.categories.artist)
      ti = create(:tag_implication, antecedent_name: "bkub", consequent_name: "banned_artist")

      RetireTagRelationshipsJob.perform_now

      assert_equal(false, ti.reload.is_retired?)
      assert_equal(true, bkub.implies?("banned_artist"))
    end
  end
end
