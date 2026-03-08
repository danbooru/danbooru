require "test_helper"

class RegeneratePostCountsJobTest < ActiveJob::TestCase
  context "RegeneratePostCountsJob" do
    should "regenerate all incorrect tag post counts" do
      create(:tag, name: "touhou", post_count: -10)
      create(:tag, name: "bkub", post_count: 10)
      create(:tag, name: "chen", post_count: 10)
      create(:post, tag_string: "touhou bkub")

      RegeneratePostCountsJob.perform_now

      assert_equal(1, Tag.find_by_name!("touhou").post_count)
      assert_equal(1, Tag.find_by_name!("bkub").post_count)
      assert_equal(0, Tag.find_by_name!("chen").post_count)
    end
  end
end
