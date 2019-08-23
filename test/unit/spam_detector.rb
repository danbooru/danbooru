require "test_helper"

class SpamDetectorTest < ActiveSupport::TestCase
  context "SpamDetector" do
    setup do
      skip "SpamDetector not working: API key not configured, not valid, or akismet is down" if !SpamDetector.working?
      SpamDetector.stubs(:enabled?).returns(true)

      @user = create(:gold_user)
      @spammer = create(:user, email: "akismet-guaranteed-spam@example.com")
    end

    context "for dmails" do
      should "detect spam" do
        Dmail.create_split(from: @spammer, to: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @user.dmails.last
        assert(SpamDetector.new(dmail).spam?)
        assert(dmail.is_spam?)
      end

      should "not detect gold users as spammers" do
        Dmail.create_split(from: @user, to: @spammer, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @spammer.dmails.last
        refute(SpamDetector.new(dmail).spam?)
        refute(dmail.is_spam?)
      end
    end
  end
end
