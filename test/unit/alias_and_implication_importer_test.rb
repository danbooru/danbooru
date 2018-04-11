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
  end
end
