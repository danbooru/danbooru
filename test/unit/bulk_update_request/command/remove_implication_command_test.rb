require "test_helper"

class RemoveImplicationCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the remove implication command" do
    context "on creation" do
      should "fail to validate if the implication isn't active" do
        create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "deleted")
        @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't remove implication [[foo]] -> [[bar]] (implication doesn't exist)"], @bur.errors[:base])
      end

      should "fail to validate if the implication doesn't already exist" do
        @bur = build(:bulk_update_request, script: "remove implication foo -> bar")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't remove implication [[foo]] -> [[bar]] (implication doesn't exist)"], @bur.errors[:base])
      end
    end

    context "on approval" do
      should "remove an implication" do
        create(:tag_implication, antecedent_name: "foo", consequent_name: "bar", status: "active")
        @bur = create_bur!("remove implication foo -> bar", @admin)

        @implication = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
        assert_equal(true, @implication.present?)
        assert_equal(true, @implication.is_deleted?)
        assert_equal("approved", @bur.reload.status)
      end

      should "allow reapproving a failed BUR when the implication has already been removed" do
        @implication = create(:tag_implication, antecedent_name: "foo", consequent_name: "bar")
        @bur = create(:bulk_update_request, script: "unimply foo -> bar", status: "failed")
        @implication.reject!

        @bur.approve!(@admin)
        perform_enqueued_jobs

        assert_equal(true, @implication.reload.is_deleted?)
        assert_equal("approved", @bur.reload.status)
      end
    end
  end
end
