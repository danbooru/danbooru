require 'test_helper'

class BulkUpdateRequestProcessorTest < ActiveSupport::TestCase
  context "The bulk update request processor" do
    setup do
      CurrentUser.user = create(:admin_user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "category command" do
      should "change the tag's category" do
        @tag = create(:tag, name: "hello")
        @script = "category hello -> artist\n"
        @processor = BulkUpdateRequestProcessor.new(@script)
        @processor.process!(CurrentUser.user)

        assert_equal(Tag.categories.value_for("artist"), @tag.reload.category)
      end
    end

    context "#affected_tags" do
      setup do
        create(:post, tag_string: "aaa")
        create(:post, tag_string: "bbb")
        create(:post, tag_string: "ccc")
        create(:post, tag_string: "ddd")
        create(:post, tag_string: "eee")

        @script = "create alias aaa -> 000\n" +
          "create implication bbb -> 111\n" +
          "remove alias ccc -> 222\n" +
          "remove implication ddd -> 333\n" +
          "mass update eee -> 444\n"
      end

      should "return the correct tags" do
        @processor = BulkUpdateRequestProcessor.new(@script)
        assert_equal(%w(000 111 222 333 444 aaa bbb ccc ddd eee), @processor.affected_tags)
      end
    end

    context "given a valid list" do
      should "process it" do
        @list = "create alias abc -> def\ncreate implication aaa -> bbb\n"
        @processor = BulkUpdateRequestProcessor.new(@list)
        @processor.process!(CurrentUser.user)

        assert(TagAlias.exists?(antecedent_name: "abc", consequent_name: "def"))
        assert(TagImplication.exists?(antecedent_name: "aaa", consequent_name: "bbb"))
      end
    end

    context "given a list with an invalid command" do
      should "throw an exception" do
        @list = "zzzz abc -> def\n"
        @processor = BulkUpdateRequestProcessor.new(@list)

        assert_raises(BulkUpdateRequestProcessor::Error) do
          @processor.process!(CurrentUser.user)
        end
      end
    end

    context "given a list with a logic error" do
      should "throw an exception" do
        @list = "remove alias zzz -> yyy\n"
        @processor = BulkUpdateRequestProcessor.new(@list)

        assert_raises(BulkUpdateRequestProcessor::Error) do
          @processor.process!(CurrentUser.user)
        end
      end
    end

    should "rename an aliased tag's artist entry and wiki page" do
      tag1 = create(:tag, name: "aaa", category: 1)
      tag2 = create(:tag, name: "bbb")
      wiki = create(:wiki_page, title: "aaa")
      artist = create(:artist, name: "aaa")

      @processor = BulkUpdateRequestProcessor.new("create alias aaa -> bbb")
      @processor.process!(CurrentUser.user)
      perform_enqueued_jobs

      assert_equal("bbb", artist.reload.name)
      assert_equal("bbb", wiki.reload.title)
    end

    context "remove alias and remove implication commands" do
      setup do
        @ta = create(:tag_alias, antecedent_name: "a", consequent_name: "b", status: "active")
        @ti = create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "active")
        @script = %{
          remove alias a -> b
          remove implication c -> d
        }
        @processor = BulkUpdateRequestProcessor.new(@script)
      end

      should "set aliases and implications as deleted" do
        @processor.process!(CurrentUser.user)

        assert_equal("deleted", @ta.reload.status)
        assert_equal("deleted", @ti.reload.status)
      end

      should "create modactions for each removal" do
        assert_difference(-> { ModAction.count }, 2) do
          @processor.process!(CurrentUser.user)
        end
      end

      should "only remove active aliases and implications" do
        @ta2 = create(:tag_alias, antecedent_name: "a", consequent_name: "b", status: "pending")
        @ti2 = create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "pending")

        @processor.process!(CurrentUser.user)
        assert_equal("pending", @ta2.reload.status)
        assert_equal("pending", @ti2.reload.status)
      end
    end
  end
end
