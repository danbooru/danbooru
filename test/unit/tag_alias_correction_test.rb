require 'test_helper'

class TagAliasCorrectionTest < ActiveSupport::TestCase
  context "A tag alias correction" do
    setup do
      @mod = FactoryBot.create(:moderator_user)
      CurrentUser.user = @mod
      CurrentUser.ip_addr = "127.0.0.1"
      @post = FactoryBot.create(:post, :tag_string => "aaa")
      @tag_alias = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      @tag_alias.update_posts
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "with a bad post count" do
      setup do
        Tag.where(:name => "aaa").update_all("post_count = -3")
        @correction = TagAliasCorrection.new(@tag_alias.id)
      end

      should "have the correct statistics hash" do
        assert_equal(-3, @correction.statistics_hash["antecedent_count"])
        assert_equal(1, @correction.statistics_hash["consequent_count"])
      end

      should "render to json" do
        assert_nothing_raised do
          @correction.to_json
        end

        assert_nothing_raised do
          JSON.parse(@correction.to_json)
        end
      end

      context "that is fixed" do
        setup do
          @correction.fix!
        end

        should "now have the correct count" do
          assert_equal(0, Tag.find_by_name("aaa").post_count)
        end
      end
    end
  end
end
