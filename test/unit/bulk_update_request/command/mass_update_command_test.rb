require "test_helper"

class MassUpdateCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the mass update command" do
    context "on creation" do
      should "not allow invalid searches in mass updates" do
        assert_invalid_bur(
          script: "mass update (foo -> bar",
          errors: ["Can't mass update {{(foo}} -> {{bar}} (the search {{(foo}} has a syntax error)"],
        )
      end

      should "render simple tags as wiki links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update bunny_ears -> rabbit_ears")
        create(:tag_alias, consequent_name: "bunny_ears", antecedent_name: "rabbit_ears")

        assert_equal("mass update [[bunny_ears]] -> [[rabbit_ears]]", @bur.processor.to_dtext)
      end

      should "render complex queries as search links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update source:imageboard -> source:Imageboard")

        assert_equal("mass update {{source:imageboard}} -> {{source:Imageboard}}", @bur.processor.to_dtext)
      end
    end

    context "on approval" do
      should "update the tags" do
        @post = create(:post, tag_string: "foo")
        @bur = create_bur!("mass update foo -> bar baz", @admin)

        assert_equal("bar baz foo", @post.reload.tag_string)
        assert_equal("approved", @bur.reload.status)
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "be case-sensitive" do
        @post = create(:post, source: "imageboard")
        @bur = create_bur!("mass update source:imageboard -> source:Imageboard", @admin)

        assert_equal("Imageboard", @post.reload.source)
        assert_equal("approved", @bur.reload.status)
      end

      should "not raise a validation error for updates containing nonexisting pools" do
        @bur = create_bur!("update pool:123 -> test", @admin)

        assert_equal("approved", @bur.reload.status)
      end
    end
  end
end
