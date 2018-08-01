require 'test_helper'

class TagRelationshipRetirementServiceTest < ActiveSupport::TestCase
  context ".forum_topic" do
    subject { TagRelationshipRetirementService }

    should "create a new topic if one doesn't already exist" do
      assert_difference(-> { ForumTopic.count }) do
        subject.forum_topic
      end
    end

    should "create a new post if one doesn't already exist" do
      assert_difference(-> { ForumPost.count }) do
        subject.forum_topic
      end
    end
  end

  context ".each_candidate" do
    subject { TagRelationshipRetirementService }

    setup do
      subject.stubs(:is_unused?).returns(true)

      @user = FactoryBot.create(:user)
      as_user do
        @new_alias = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")

        travel_to(3.years.ago) do
          @old_alias = FactoryBot.create(:tag_alias, antecedent_name: "ccc", consequent_name: "ddd")
        end
      end
    end

    should "find old tag relationships" do
      subject.each_candidate(TagAlias) do |rel|
        assert_equal(@old_alias, rel)
      end
    end

    should "not find new tag relationships" do
      subject.each_candidate(TagAlias) do |rel|
        assert_not_equal(@new_alias, rel)
      end
    end
  end

  context ".is_unused?" do
    subject { TagRelationshipRetirementService }

    setup do
      @user = FactoryBot.create(:user)

      as_user do
        @new_alias = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
        @new_post = FactoryBot.create(:post, tag_string: "bbb")

        travel_to(3.years.ago) do
          @old_alias = FactoryBot.create(:tag_alias, antecedent_name: "ccc", consequent_name: "ddd")
          @old_post = FactoryBot.create(:post, tag_string: "ddd")
        end
      end
    end

    should "return true if no recent post exists" do
      assert(subject.is_unused?("ddd"))
    end

    should "return false if a recent post exists" do
      refute(subject.is_unused?("bbb"))      
    end
  end
end

