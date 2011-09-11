require 'test_helper'

class DmailTest < ActiveSupport::TestCase
  context "A dmail" do
    setup do
      MEMCACHE.flush_all
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end
    
    teardown do
      CurrentUser.user = nil
    end
    
    context "search" do
      should "return results based on title contents" do
        dmail = Factory.create(:dmail, :title => "xxx", :owner => @user)
        matches = Dmail.search_message("xxx")
        assert(matches.any?)
        matches = Dmail.search_message("aaa")
        assert(matches.empty?)
      end
      
      should "return results based on body contents" do
        dmail = Factory.create(:dmail, :body => "xxx", :owner => @user)
        matches = Dmail.search_message("xxx")
        assert(matches.any?)
        matches = Dmail.search_message("aaa")
        assert(matches.empty?)
      end
    end
    
    should "should parse user names" do
      dmail = Factory.build(:dmail, :owner => @user)
      dmail.to_id = nil
      dmail.to_name = @user.name
      assert(dmail.to_id == @user.id)
    end
    
    should "construct a response" do
      dmail = Factory.create(:dmail, :owner => @user)
      response = dmail.build_response
      assert_equal("Re: #{dmail.title}", response.title)
      assert_equal(dmail.from_id, response.to_id)
      assert_equal(dmail.to_id, response.from_id)
    end
    
    should "create a copy for each user" do
      assert_difference("Dmail.count", 2) do
        Dmail.create_split(:to_id => @user.id, :title => "foo", :body => "foo")
      end
    end

    should "send an email if the user wants it" do
      user = Factory.create(:user, :receive_email_notifications => true)
      assert_difference("ActionMailer::Base.deliveries.size", 1) do
        Factory.create(:dmail, :to => user, :owner => @user)
      end
    end
    
    should "be marked as read after the user reads it" do
      dmail = Factory.create(:dmail, :owner => @user)
      assert(!dmail.is_read?)
      dmail.mark_as_read!
      assert(dmail.is_read?)
    end
    
    should "notify the recipient he has mail" do
      dmail = Factory.create(:dmail, :owner => @user)
      assert(dmail.to(true).has_mail?)
      dmail.mark_as_read!
      assert(!dmail.to(true).has_mail?)
    end
  end
end
