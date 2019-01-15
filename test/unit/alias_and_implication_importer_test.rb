require 'test_helper'

class AliasAndImplicationImporterTest < ActiveSupport::TestCase
  context "The alias and implication importer" do
    setup do
      CurrentUser.user = FactoryBot.create(:admin_user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "category command" do
      setup do
        @tag = Tag.find_or_create_by_name("hello")
        @list = "category hello -> artist\n"
        @importer = AliasAndImplicationImporter.new(@list, nil)
      end

      should "work" do
        @importer.process!
        @tag.reload
        assert_equal(Tag.categories.value_for("artist"), @tag.category)
      end
    end

    context "#affected_tags" do
      setup do
        FactoryBot.create(:post, tag_string: "aaa")
        FactoryBot.create(:post, tag_string: "bbb")
        FactoryBot.create(:post, tag_string: "ccc")
        FactoryBot.create(:post, tag_string: "ddd")
        FactoryBot.create(:post, tag_string: "eee")

        @script = "create alias aaa -> 000\n" +
          "create implication bbb -> 111\n" +
          "remove alias ccc -> 222\n" +
          "remove implication ddd -> 333\n" +
          "mass update eee -> 444\n"
      end

      subject { AliasAndImplicationImporter.new(@script, nil) }

      should "return the correct tags" do
        assert_equal(%w(aaa 000 bbb 111 ccc 222 ddd 333 eee 444), subject.affected_tags)
      end
    end

    context "#estimate_update_count" do
      setup do
        FactoryBot.create(:post, tag_string: "aaa")
        FactoryBot.create(:post, tag_string: "bbb")
        FactoryBot.create(:post, tag_string: "ccc")
        FactoryBot.create(:post, tag_string: "ddd")
        FactoryBot.create(:post, tag_string: "eee")

        @script = "create alias aaa -> 000\n" +
          "create implication bbb -> 111\n" +
          "remove alias ccc -> 222\n" +
          "remove implication ddd -> 333\n" +
          "mass update eee -> 444\n"
      end

      subject { AliasAndImplicationImporter.new(@script, nil) }

      should "return the correct count" do
        assert_equal(3, subject.estimate_update_count)
      end
    end

    context "given a valid list" do
      setup do
        @list = "create alias abc -> def\ncreate implication aaa -> bbb\n"
        @importer = AliasAndImplicationImporter.new(@list, nil)
      end

      should "process it" do
        @importer.process!
        assert(TagAlias.exists?(antecedent_name: "abc", consequent_name: "def"))
        assert(TagImplication.exists?(antecedent_name: "aaa", consequent_name: "bbb"))
      end
    end

    context "given a list with an invalid command" do
      setup do
        @list = "zzzz abc -> def\n"
        @importer = AliasAndImplicationImporter.new(@list, nil)
      end

      should "throw an exception" do
        assert_raises(RuntimeError) do
          @importer.process!
        end
      end
    end

    context "given a list with a logic error" do
      setup do
        @list = "remove alias zzz -> yyy\n"
        @importer = AliasAndImplicationImporter.new(@list, nil)
      end

      should "throw an exception" do
        assert_raises(RuntimeError) do
          @importer.process!
        end
      end
    end

    should "rename an aliased tag's artist entry and wiki page" do
      tag1 = FactoryBot.create(:tag, :name => "aaa", :category => 1)
      tag2 = FactoryBot.create(:tag, :name => "bbb")
      artist = FactoryBot.create(:artist, :name => "aaa", :notes => "testing")
      @importer = AliasAndImplicationImporter.new("create alias aaa -> bbb", "", "1")
      @importer.process!
      artist.reload
      assert_equal("bbb", artist.name)
      assert_equal("testing", artist.notes)
    end

    context "remove alias and remove implication commands" do
      setup do
        @ta = FactoryBot.create(:tag_alias, antecedent_name: "a", consequent_name: "b", status: "active")
        @ti = FactoryBot.create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "active")
        @script = %{
          remove alias a -> b
          remove implication c -> d
        }
        @importer = AliasAndImplicationImporter.new(@script, nil)
      end

      should "set aliases and implications as deleted" do
        @importer.process!

        assert_equal("deleted", @ta.reload.status)
        assert_equal("deleted", @ti.reload.status)
      end

      should "create modactions for each removal" do
        assert_difference(-> { ModAction.count }, 2) do
          @importer.process!
        end
      end

      should "only remove active aliases and implications" do
        @ta2 = FactoryBot.create(:tag_alias, antecedent_name: "a", consequent_name: "b", status: "pending")
        @ti2 = FactoryBot.create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "pending")

        @importer.process!
        assert_equal("pending", @ta2.reload.status)
        assert_equal("pending", @ti2.reload.status)
      end
    end
  end
end
