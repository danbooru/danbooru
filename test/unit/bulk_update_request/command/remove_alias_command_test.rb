require "test_helper"

class RemoveAliasCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the remove alias command" do
    context "on creation" do
      should "fail to validate if the alias isn't active" do
        create(:tag_alias, antecedent_name: "foo", consequent_name: "bar", status: "deleted")

        assert_invalid_bur(
          script: "remove alias foo -> bar",
          errors: ["Can't remove alias [[foo]] -> [[bar]] (alias doesn't exist)"],
        )
      end

      should "fail to validate if the alias doesn't already exist" do
        assert_invalid_bur(
          script: "remove alias foo -> bar",
          errors: ["Can't remove alias [[foo]] -> [[bar]] (alias doesn't exist)"],
        )
      end
    end

    context "on approval" do
      should "remove an alias" do
        create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
        @bur = create_bur!("remove alias foo -> bar", @admin)

        @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
        assert_equal(true, @alias.present?)
        assert_equal(true, @alias.is_deleted?)
        assert_equal("approved", @bur.reload.status)
      end

      should "allow reapproving a failed BUR when the alias has already been removed" do
        @alias = create(:tag_alias, antecedent_name: "foo", consequent_name: "bar")
        @bur = create(:bulk_update_request, script: "unalias foo -> bar", status: "failed")
        @alias.reject!

        @bur.approve!(@admin)
        perform_enqueued_jobs

        assert_equal(true, @alias.reload.is_deleted?)
        assert_equal("approved", @bur.reload.status)
      end

      should "be processed sequentially after the create alias command" do
        @bur = create_bur!("create alias foo -> bar\nremove alias foo -> bar", @admin)

        @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
        assert_equal(true, @alias.present?)
        assert_equal(true, @alias.is_deleted?)
        assert_equal("approved", @bur.reload.status)
      end
    end
  end
end
