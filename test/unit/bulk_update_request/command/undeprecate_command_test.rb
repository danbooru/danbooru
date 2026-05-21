require "test_helper"

class UndeprecateCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the undeprecate command" do
    context "on creation" do
      should "fail if the tag is not deprecated" do
        create(:tag, name: "silver_hair")
        @bur = build(:bulk_update_request, script: "undeprecate silver_hair")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't undeprecate [[silver_hair]] (tag is not deprecated)"], @bur.errors[:base])
      end
    end

    context "on approval" do
      should "undeprecate the tag" do
        @tag = create(:tag, name: "silver_hair", is_deprecated: true)
        @bur = create_bur!("undeprecate silver_hair", @admin)

        assert_equal(false, @tag.reload.is_deprecated?)
      end
    end
  end
end
