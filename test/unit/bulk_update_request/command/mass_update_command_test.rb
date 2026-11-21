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

      should "not allow disallowed metatags in mass update destinations" do
        assert_invalid_bur(
          script: "update xyz -> favgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{favgroup:xyz}} ('favgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -favgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> {{-favgroup:xyz}} ('-favgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> newfavgroup:xyz",
          errors: ["Can't mass update [[xyz]] -> [[newfavgroup:xyz]] ('newfavgroup:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> status:banned",
          errors: ["Can't mass update [[xyz]] -> {{status:banned}} ('status:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> score:5",
          errors: ["Can't mass update [[xyz]] -> {{score:5}} ('score:' metatag is not allowed)"],
        )
        assert_invalid_bur(
          script: "update xyz -> -rating:s",
          errors: ["Can't mass update [[xyz]] -> {{-rating:s}} ('-rating:' metatag is not allowed)"],
        )
      end

      should "allow safe post-edit metatags and regular tags with colons in mass update destinations" do
        assert_equal(true, build(:bulk_update_request, script: "update xyz -> rating:s source:https://example.com pool:foo -pool:bar newpool:baz parent:1 -parent:2 child:3 -child:4 char:a -char:b re:zero").valid?)
        assert_equal(true, build(:bulk_update_request, script: "update favgroup:xyz -> foo").valid?)
      end

      should "render simple tags as wiki links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update bunny_ears -> rabbit_ears")
        create(:tag_alias, consequent_name: "bunny_ears", antecedent_name: "rabbit_ears")

        assert_equal("mass update [[bunny_ears]] -> [[rabbit_ears]]", @bur.processor.to_dtext)
      end

      should "link tags with category prefixes to the tag's wiki in dtext" do
        @bur = build(:bulk_update_request, script: "mass update aaa -> char:bbb")

        assert_equal("mass update [[aaa]] -> [[bbb|char:bbb]]", @bur.processor.to_dtext)
      end

      should "render complex queries as search links in dtext" do
        @bur = build(:bulk_update_request, script: "mass update source:imageboard -> source:Imageboard")

        assert_equal("mass update {{source:imageboard}} -> {{source:Imageboard}}", @bur.processor.to_dtext)
      end

      should "strip category prefixes from tags in the list of affected tags" do
        @bur = create(:bulk_update_request, script: "mass update aaa -> char:bbb ccc -ddd COPY:Eee rating:s")

        assert_equal(%w[aaa bbb ccc ddd eee], @bur.tags)
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
