require "test_helper"

class NukeCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the nuke command" do
    context "on creation" do
      should "raise an error when trying to nuke a pool that doesn't exist (by name)" do
        assert_invalid_bur(
          script: "nuke pool:mario_quest",
          errors: ["Can't nuke {{pool:mario_quest}} (pool doesn't exist)"],
        )
      end

      should "raise an error when trying to nuke a pool that doesn't exist (by ID)" do
        assert_invalid_bur(
          script: "nuke pool:12345678",
          errors: ["Can't nuke {{pool:12345678}} (pool doesn't exist)"],
        )
      end
    end

    context "on approval" do
      should "remove tags" do
        @post = create(:post, tag_string: "foo bar")
        @bur = create_bur!("nuke bar", @admin)

        assert_equal("foo", @post.reload.tag_string)
        assert_equal("approved", @bur.reload.status)
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "remove implications" do
        @ti1 = create(:tag_implication, antecedent_name: "fly", consequent_name: "insect")
        @ti2 = create(:tag_implication, antecedent_name: "insect", consequent_name: "bug")
        @bur = create_bur!("nuke insect", @admin)

        assert_equal("deleted", @ti1.reload.status)
        assert_equal("deleted", @ti2.reload.status)
        assert_equal("approved", @bur.reload.status)
      end

      should "remove pools by id" do
        @pool = create(:pool, id: 123)
        @post = create(:post, tag_string: "bar pool:123")
        @bur = create_bur!("nuke pool:123", @admin)

        assert_equal([], @pool.post_ids)
        assert_equal("approved", @bur.reload.status)
        assert_equal(User.system, @pool.versions.last.updater)
      end

      should "remove pools by name" do
        @pool = create(:pool, name: "asd")
        @post = create(:post, tag_string: "bar pool:asd")
        @bur = create_bur!("nuke pool:asd", @admin)

        assert_equal([], @pool.post_ids)
        assert_equal("approved", @bur.reload.status)
        assert_equal(User.system, @pool.versions.last.updater)
      end
    end
  end
end
