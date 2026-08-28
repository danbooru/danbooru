require "test_helper"

class ApproverPrunerTest < ActiveSupport::TestCase
  context "ApproverPruner" do
    setup do
      Danbooru.config.stubs(:approver_pruning_enabled?).returns(true)
      @approver = create(:approver)
    end

    should "demote inactive approvers who have received a warning dmail" do
      travel_to(Date.parse("2020-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      travel_to(Date.parse("2020-02-01")) do
        assert_equal([@approver.id], ApproverPruner.warned_inactive_approvers.map(&:id))
        assert_nothing_raised { ApproverPruner.prune! }
      end

      assert_equal(User::Levels::CONTRIBUTOR, @approver.reload.level)
      assert_equal(2, @approver.dmails.received.count)
      assert_equal("Approver inactivity", @approver.dmails.received.first.title)
    end

    # @see https://github.com/danbooru/danbooru/issues/5435
    should "not demote inactive approvers who have not received a warning dmail" do
      assert_equal([@approver.id], ApproverPruner.inactive_approvers.map(&:id))
      assert_equal([], ApproverPruner.warned_inactive_approvers.map(&:id))

      assert_nothing_raised { ApproverPruner.prune! }
      assert_equal(User::Levels::APPROVER, @approver.reload.level)
      assert_equal(0, @approver.dmails.received.count)
    end

    should "not demote inactive approvers who were warned less than a week ago" do
      travel_to(Date.parse("2020-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      travel_to(Date.parse("2020-01-24")) do # only 4 days after the warning
        assert_equal([], ApproverPruner.warned_inactive_approvers.map(&:id))
        assert_nothing_raised { ApproverPruner.prune! }
      end

      assert_equal(User::Levels::APPROVER, @approver.reload.level)
      assert_equal(1, @approver.dmails.received.count)
    end

    should "demote inactive approvers who were warned a week or more ago" do
      travel_to(Date.parse("2020-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      travel_to(Date.parse("2020-01-27")) do # exactly a week after the warning
        assert_equal([@approver.id], ApproverPruner.warned_inactive_approvers.map(&:id))
        assert_nothing_raised { ApproverPruner.prune! }
      end

      assert_equal(User::Levels::CONTRIBUTOR, @approver.reload.level)
    end

    should "not demote inactive approvers based on a warning dmail from a past cycle" do
      # The approver went inactive and was warned once, 2 years before the
      # current cycle below, but became active again afterwards and was never
      # demoted. Now they've gone inactive a second time; the old warning
      # shouldn't count towards this new cycle.
      travel_to(Date.parse("2018-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      travel_to(Date.parse("2020-01-15")) do
        assert_equal([@approver.id], ApproverPruner.inactive_approvers.map(&:id))
        assert_equal([], ApproverPruner.warned_inactive_approvers.map(&:id))
        assert_nothing_raised { ApproverPruner.prune! }
      end
      assert_equal(User::Levels::APPROVER, @approver.reload.level)

      # Once they receive a fresh warning for the current cycle, demotion proceeds as normal.
      travel_to(Date.parse("2020-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      travel_to(Date.parse("2020-01-27")) do
        assert_equal([@approver.id], ApproverPruner.warned_inactive_approvers.map(&:id))
        assert_nothing_raised { ApproverPruner.prune! }
      end

      assert_equal(User::Levels::CONTRIBUTOR, @approver.reload.level)
    end

    should "not demote active approvers" do
      posts = create_list(:post, ApproverPruner::MINIMUM_APPROVALS + 1, is_pending: true)
      posts.each { |post| create(:post_approval, post: post, user: @approver) }

      assert_equal([], ApproverPruner.inactive_approvers.map(&:id))
    end

    should "not demote recently promoted approvers" do
      as(create(:admin_user)) do
        @user = create(:user)
        @user.promote_to!(User::Levels::APPROVER)
      end

      assert_not_includes(ApproverPruner.inactive_approvers.map(&:id), @user.id)
    end

    should "dmail inactive approvers" do
      travel_to(Date.parse("2020-01-20")) do
        ApproverPruner.dmail_inactive_approvers!
      end

      assert_equal("You will lose approval privileges soon", @approver.dmails.received.last.title)
    end

    should "not demote inactive approvers if the config option is disabled" do
      Danbooru.config.stubs(:approver_pruning_enabled?).returns(false)

      assert_equal([@approver.id], ApproverPruner.inactive_approvers.map(&:id))
      assert_nothing_raised { ApproverPruner.prune! }
      assert_equal(User::Levels::APPROVER, @approver.reload.level)
      assert_equal(0, @approver.dmails.received.count)
    end

    # @see https://github.com/danbooru/danbooru/issues/5435
    should "not demote inactive approvers before the first of the month" do
      monthly_event = Clockwork.manager.instance_variable_get(:@events).find { |event| event.to_s == "monthly" }

      # Simulate the cron container restarting on some day in the middle of the
      # month, which resets Clockwork's in-memory record of when the job last ran.
      monthly_event.instance_variable_set(:@last, nil)

      travel_to(Date.parse("2020-01-20")) { ApproverPruner.dmail_inactive_approvers! }

      (Date.parse("2020-01-15")...Date.parse("2020-02-01")).each do |date|
        travel_to(date) do
          monthly_event.run(Time.current) if monthly_event.run_now?(Time.current)
          perform_enqueued_jobs
        end
      end

      assert_equal(User::Levels::APPROVER, @approver.reload.level)

      travel_to(Date.parse("2020-02-01")) do
        monthly_event.run(Time.current) if monthly_event.run_now?(Time.current)
        perform_enqueued_jobs
      end

      assert_equal(User::Levels::CONTRIBUTOR, @approver.reload.level)
    end
  end
end
