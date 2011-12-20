require 'test_helper'

class AliasAndImplicationImporterTest < ActiveSupport::TestCase
  context "The alias and implication importer" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "given a valid list" do
      setup do
        @list = "create alias abc -> def\ncreate implication aaa -> bbb\n"
        @importer = AliasAndImplicationImporter.new(@list, nil)
      end
      
      should "process it" do
        assert_difference("Delayed::Job.count", 2) do
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
  end
end
