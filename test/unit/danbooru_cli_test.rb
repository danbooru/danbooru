require "test_helper"

class DanbooruCLITest < ActiveSupport::TestCase
  include IqdbTestHelper

  # Run a booructl command and return its stdout, stderr, and whether it succeeded.
  def booructl(*argv, stdin: "")
    success = true
    old_stdin = $stdin
    $stdin = StringIO.new(stdin)

    stdout, stderr = capture_subprocess_io do
      Danbooru::CLI.start(argv)
    rescue SystemExit => e
      success = e.success?
    end

    [stdout, stderr, success]
  ensure
    $stdin = old_stdin
  end

  context "booructl" do
    should "work when called with bin/booructl" do
      assert_equal(true, system(Rails.root.join("bin/booructl help > /dev/null 2>&1").to_s))
    end

    should "fail on an unknown command" do
      _, stderr, success = booructl("nonexistent")

      assert_equal(false, success)
      assert_match(/Could not find command/, stderr)
    end

    context "status command" do
      should "show the status of the instance" do
        stdout, = booructl("status")

        assert_match(/^Postgres:\s+up/, stdout)
        assert_match(/^Migrations:\s+up to date/, stdout)
        assert_match(/^Storage:\s+StorageManager::Local/, stdout)
        assert_match(/^IQDB:\s+disabled/, stdout)
      end
    end

    context "user create command" do
      should "create a user with the password from stdin" do
        stdout, _, success = booructl("user", "create", "alice", "--password-stdin", stdin: "password123\n")
        user = User.find_by_name("alice")

        assert_equal(true, success)
        assert_match(/Created user alice/, stdout)
        assert_equal(User::Levels::MEMBER, user.level)
        assert_equal(user, user.authenticate_password("password123"))
      end

      should "create a user with the given level" do
        _, _, success = booructl("user", "create", "alice", "--level", "admin", "--password-stdin", stdin: "password123\n")
        user = User.find_by_name("alice")

        assert_equal(true, success)
        assert_equal(User::Levels::ADMIN, user.level)
        assert_equal("user_level_change", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
      end

      should "fail for an invalid username" do
        _, stderr, success = booructl("user", "create", "bad name!", "--password-stdin", stdin: "password123\n")

        assert_equal(false, success)
        assert_match(/Name/, stderr)
        assert_equal(false, User.exists?(name: "bad name!"))
      end

      should "fail for an invalid level" do
        _, stderr, success = booructl("user", "create", "alice", "--level", "superuser", "--password-stdin", stdin: "password123\n")

        assert_equal(false, success)
        assert_match(/Invalid level/, stderr)
        assert_equal(false, User.exists?(name: "alice"))
      end

      should "fail if no password is given and stdin isn't a terminal" do
        _, stderr, success = booructl("user", "create", "alice")

        assert_equal(false, success)
        assert_match(/--password-stdin/, stderr)
        assert_equal(false, User.exists?(name: "alice"))
      end
    end

    context "user set-level command" do
      setup do
        @user = create(:user, name: "alice")
      end

      should "promote a user to any level, including superadmin" do
        stdout, _, success = booructl("user", "set-level", "alice", "Superadmin")

        assert_equal(true, success)
        assert_match(/alice is now Superadmin/, stdout)
        assert_equal(User::Levels::SUPERADMIN, @user.reload.level)
        assert_equal(User.system, ModAction.last.creator)
        assert_match(/promoted "alice"/, ModAction.last.description)
      end

      should "demote a user" do
        @user.update!(level: User::Levels::ADMIN)
        _, _, success = booructl("user", "set-level", "alice", "member")

        assert_equal(true, success)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
        assert_match(/demoted "alice"/, ModAction.last.description)
      end

      should "do nothing if the user is already at the given level" do
        assert_no_difference(["ModAction.count", "Dmail.count", "UserFeedback.count"]) do
          _, _, success = booructl("user", "set-level", "alice", "member")
          assert_equal(true, success)
        end
      end

      should "not demote the only superadmin" do
        @user.update!(level: User::Levels::SUPERADMIN)
        _, stderr, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(false, success)
        assert_match(/only Superadmin/, stderr)
        assert_equal(User::Levels::SUPERADMIN, @user.reload.level)
      end

      should "demote a superadmin if there's another superadmin" do
        create(:user, level: User::Levels::SUPERADMIN)
        @user.update!(level: User::Levels::SUPERADMIN)
        _, _, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(true, success)
        assert_equal(User::Levels::ADMIN, @user.reload.level)
      end

      should "fail for a nonexistent user" do
        _, stderr, success = booructl("user", "set-level", "nobody", "admin")

        assert_equal(false, success)
        assert_match(/User 'nobody' not found/, stderr)
      end

      should "fail for an invalid level" do
        _, stderr, success = booructl("user", "set-level", "alice", "anonymous")

        assert_equal(false, success)
        assert_match(/Invalid level/, stderr)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
      end

      should "fail with the validation error if the user is invalid" do
        @user.per_page = 1000
        @user.save!(validate: false)
        _, stderr, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(false, success)
        assert_match(/Posts per page must be between/, stderr)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
      end

      should "not change the system user" do
        _, stderr, success = booructl("user", "set-level", User.system.name, "admin")

        assert_equal(false, success)
        assert_match(/system user/, stderr)
      end
    end

    context "looking up users" do
      setup do
        @user = create(:user, :with_email, name: "alice")
      end

      should "find a user by name" do
        stdout, _, success = booructl("user", "show", "Alice")

        assert_equal(true, success)
        assert_match(/^ID:\s+#{@user.id}$/, stdout)
      end

      should "find a user by ID with #123" do
        stdout, _, success = booructl("user", "show", "##{@user.id}")

        assert_equal(true, success)
        assert_match(/^Name:\s+alice$/, stdout)
      end

      should "find a user by ID with id:123" do
        stdout, _, success = booructl("user", "show", "id:#{@user.id}")

        assert_equal(true, success)
        assert_match(/^Name:\s+alice$/, stdout)
      end

      should "find a user by email" do
        stdout, _, success = booructl("user", "show", @user.email_address.address.upcase)

        assert_equal(true, success)
        assert_match(/^Name:\s+alice$/, stdout)
      end

      should "find a deleted user by ID" do
        @user.update!(is_deleted: true)
        stdout, _, success = booructl("user", "show", "##{@user.id}")

        assert_equal(true, success)
        assert_match(/^Deleted:\s+yes$/, stdout)
      end

      should "fail for a nonexistent user" do
        assert_equal(false, booructl("user", "show", "nobody")[2])
        assert_equal(false, booructl("user", "show", "#0")[2])
        assert_equal(false, booructl("user", "show", "#99999999999999999999")[2])
        assert_equal(false, booructl("user", "show", "id:abc")[2])
        assert_equal(false, booructl("user", "show", "nobody@example.com")[2])

        _, stderr, = booructl("user", "show", "nobody")
        assert_match(/User 'nobody' not found/, stderr)
      end
    end

    context "user show command" do
      should "show the user's account details" do
        user = create(:user_with_2fa, :with_email, name: "alice")
        create(:login_session, user: user)
        create(:api_key, user: user)
        create(:ban, user: user, duration: 3.days, reason: "spam")

        stdout, _, success = booructl("user", "show", "alice")

        assert_equal(true, success)
        assert_match(/^Level:\s+Member$/, stdout)
        assert_match(/^Email:\s+#{Regexp.escape(user.email_address.address)} \(verified\)$/, stdout)
        assert_match(/^2FA:\s+enabled \(#{User::MAX_BACKUP_CODES} backup codes\)$/o, stdout)
        assert_match(/^Banned:\s+yes, 3 days: spam/, stdout)
        assert_match(/^Sessions:\s+1 active$/, stdout)
        assert_match(/^API keys:\s+1$/, stdout)
      end

      should "show a user without an email or 2FA" do
        create(:user, name: "alice")
        stdout, _, success = booructl("user", "show", "alice")

        assert_equal(true, success)
        assert_match(/^Email:\s+none$/, stdout)
        assert_match(/^2FA:\s+disabled$/, stdout)
        assert_match(/^Banned:\s+no$/, stdout)
      end
    end

    context "user set-password command" do
      setup do
        @user = create(:user, name: "alice")
        @session = create(:login_session, user: @user)
      end

      should "change the password and log the user out" do
        stdout, _, success = booructl("user", "set-password", "alice", "--password-stdin", "--yes", stdin: "newpassword123\n")

        assert_equal(true, success)
        assert_match(/Changed alice's password/, stdout)
        assert_match(/Logged alice out of 1 session/, stdout)
        assert_equal(@user, @user.reload.authenticate_password("newpassword123"))
        assert_equal(true, @session.reload.revoked?)
        assert_equal("user_password_change", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_equal(@user, ModAction.last.subject)
      end

      should "not log the user out with --no-logout" do
        _, _, success = booructl("user", "set-password", "alice", "--password-stdin", "--yes", "--no-logout", stdin: "newpassword123\n")

        assert_equal(true, success)
        assert_equal(true, @session.reload.active?)
      end

      should "require --yes when stdin isn't a terminal" do
        _, stderr, success = booructl("user", "set-password", "alice", "--password-stdin", stdin: "newpassword123\n")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_equal(false, @user.reload.authenticate_password("newpassword123"))
      end

      should "fail for an invalid password" do
        assert_no_difference("ModAction.count") do
          _, stderr, success = booructl("user", "set-password", "alice", "--password-stdin", "--yes", stdin: "x\n")

          assert_equal(false, success)
          assert_match(/Password is too short/, stderr)
        end

        assert_equal(true, @session.reload.active?)
      end

      should "fail for a deleted user" do
        @user.update!(is_deleted: true)
        _, stderr, success = booructl("user", "set-password", "##{@user.id}", "--password-stdin", "--yes", stdin: "newpassword123\n")

        assert_equal(false, success)
        assert_match(/deleted/, stderr)
      end
    end

    context "user reset-link command" do
      should "print a working password reset link" do
        user = create(:user, name: "alice")
        stdout, _, success = booructl("user", "reset-link", "alice")
        token = Rack::Utils.parse_nested_query(URI.parse(stdout[%r{https?://\S+}]).query).dig("user", "signed_id")

        assert_equal(true, success)
        assert_match(%r{\A#{Regexp.escape(Danbooru.config.canonical_url)}/password_reset/edit\?}, stdout)
        assert_equal(user, User.find_by_token_for(:password_reset, token))
        assert_equal("user_password_reset", ModAction.last.category)
      end

      should "warn if the user has 2FA enabled" do
        create(:user_with_2fa, name: "alice")
        _, stderr, success = booructl("user", "reset-link", "alice")

        assert_equal(true, success)
        assert_match(/disable-2fa/, stderr)
      end

      should "fail for a deleted user" do
        user = create(:user, is_deleted: true)
        _, _, success = booructl("user", "reset-link", "##{user.id}")

        assert_equal(false, success)
      end
    end

    context "user disable-2fa command" do
      setup do
        @user = create(:user_with_2fa, name: "alice")
        @session = create(:login_session, user: @user)
      end

      should "disable 2FA and log the user out" do
        stdout, _, success = booructl("user", "disable-2fa", "alice", "--yes")

        assert_equal(true, success)
        assert_match(/Disabled 2FA for alice/, stdout)
        assert_nil(@user.reload.totp_secret)
        assert_nil(@user.backup_codes)
        assert_equal(true, @session.reload.revoked?)
        assert_equal("user_2fa_disable", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
      end

      should "not log the user out with --no-logout" do
        booructl("user", "disable-2fa", "alice", "--yes", "--no-logout")

        assert_nil(@user.reload.totp_secret)
        assert_equal(true, @session.reload.active?)
      end

      should "require --yes when stdin isn't a terminal" do
        _, stderr, success = booructl("user", "disable-2fa", "alice")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_not_nil(@user.reload.totp_secret)
      end

      should "fail if the user doesn't have 2FA" do
        create(:user, name: "bob")
        _, stderr, success = booructl("user", "disable-2fa", "bob", "--yes")

        assert_equal(false, success)
        assert_match(/doesn't have 2FA enabled/, stderr)
      end
    end

    context "user send-backup-code command" do
      should "email a backup code to the user" do
        user = create(:user_with_2fa, :with_email, name: "alice")
        stdout, _, success = booructl("user", "send-backup-code", "alice")

        assert_equal(true, success)
        assert_match(/Sent a backup code to alice/, stdout)
        assert_equal("backup_code_send", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_equal(user, ModAction.last.subject)
        assert_enqueued_with(job: MailDeliveryJob, args: ->(args) { args[0..1] == %w[UserMailer send_backup_code] })
      end

      should "fail for a user without an email address" do
        create(:user_with_2fa, name: "alice")
        _, stderr, success = booructl("user", "send-backup-code", "alice")

        assert_equal(false, success)
        assert_match(/doesn't have an email address/, stderr)
        assert_no_enqueued_jobs(only: MailDeliveryJob)
      end

      should "fail for a user without backup codes" do
        create(:user, :with_email, name: "alice")
        _, stderr, success = booructl("user", "send-backup-code", "alice")

        assert_equal(false, success)
        assert_match(/doesn't have backup codes/, stderr)
      end
    end

    context "user logout command" do
      setup do
        @user = create(:user, name: "alice")
        @session = create(:login_session, user: @user)
        @other_session = create(:login_session)
        @api_key = create(:api_key, user: @user)
      end

      should "revoke the user's sessions but not their API keys" do
        stdout, _, success = booructl("user", "logout", "alice")

        assert_equal(true, success)
        assert_match(/Logged alice out of 1 session/, stdout)
        assert_equal(true, @session.reload.revoked?)
        assert_equal(true, @other_session.reload.active?)
        assert_equal(true, ApiKey.exists?(@api_key.id))
        assert_equal("user_logout", ModAction.last.category)
      end

      should "delete the user's API keys with --api-keys" do
        stdout, _, success = booructl("user", "logout", "alice", "--api-keys")

        assert_equal(true, success)
        assert_match(/Deleted 1 API key/, stdout)
        assert_equal(false, ApiKey.exists?(@api_key.id))
      end
    end

    context "user ban command" do
      setup do
        @user = create(:user, name: "alice")
        @session = create(:login_session, user: @user)
      end

      should "ban the user" do
        stdout, _, success = booructl("user", "ban", "alice", "--duration", "3days", "--reason", "spam")

        assert_equal(true, success)
        assert_match(/Banned alice for 3 days/, stdout)
        assert_equal(true, @user.reload.is_banned?)
        assert_equal(3.days, @user.active_ban.duration)
        assert_equal("spam", @user.active_ban.reason)
        assert_equal(User.system, @user.active_ban.banner)
        assert_equal("user_ban", ModAction.last.category)
        assert_equal(true, @session.reload.active?)
      end

      should "ban the user forever" do
        _, _, success = booructl("user", "ban", "alice", "--duration", "forever", "--reason", "spam")

        assert_equal(true, success)
        assert_equal(true, @user.reload.active_ban.forever?)
      end

      should "accept durations with spaces" do
        _, _, success = booructl("user", "ban", "alice", "--duration", "1 month", "--reason", "spam")

        assert_equal(true, success)
        assert_equal(1.month, @user.reload.active_ban.duration)
      end

      should "log the user out with --logout" do
        booructl("user", "ban", "alice", "--duration", "1day", "--reason", "spam", "--logout")

        assert_equal(true, @session.reload.revoked?)
      end

      should "fail for an invalid duration" do
        _, stderr, success = booructl("user", "ban", "alice", "--duration", "2days", "--reason", "spam")

        assert_equal(false, success)
        assert_match(/Invalid duration/, stderr)
        assert_equal(false, @user.reload.is_banned?)
      end

      should "fail without a reason" do
        _, _, success = booructl("user", "ban", "alice", "--duration", "1day")

        assert_equal(false, success)
        assert_equal(false, @user.reload.is_banned?)
      end

      should "fail if the user is already banned" do
        create(:ban, user: @user)
        _, stderr, success = booructl("user", "ban", "alice", "--duration", "1day", "--reason", "spam")

        assert_equal(false, success)
        assert_match(/already banned/, stderr)
      end

      should "not ban the only superadmin" do
        @user.update!(level: User::Levels::SUPERADMIN)
        _, stderr, success = booructl("user", "ban", "alice", "--duration", "1day", "--reason", "spam")

        assert_equal(false, success)
        assert_match(/only Superadmin/, stderr)
        assert_equal(false, @user.reload.is_banned?)
      end

      should "ban staff members" do
        @user.update!(level: User::Levels::ADMIN)
        _, _, success = booructl("user", "ban", "alice", "--duration", "1day", "--reason", "spam")

        assert_equal(true, success)
        assert_equal(true, @user.reload.is_banned?)
      end

      should "not ban the system user" do
        _, stderr, success = booructl("user", "ban", User.system.name, "--duration", "1day", "--reason", "spam")

        assert_equal(false, success)
        assert_match(/system user/, stderr)
      end
    end

    context "user unban command" do
      setup do
        @user = create(:user, name: "alice")
      end

      should "unban the user" do
        create(:ban, user: @user)
        stdout, _, success = booructl("user", "unban", "alice")

        assert_equal(true, success)
        assert_match(/Unbanned alice/, stdout)
        assert_equal(false, @user.reload.is_banned?)
        assert_equal(false, @user.bans.active.exists?)
        assert_equal("user_unban", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
      end

      should "fail if the user isn't banned" do
        _, stderr, success = booructl("user", "unban", "alice")

        assert_equal(false, success)
        assert_match(/isn't banned/, stderr)
      end
    end

    context "user set-email command" do
      setup do
        @user = create(:user, name: "alice")
        @session = create(:login_session, user: @user)
      end

      should "add an email address to a user without one" do
        stdout, _, success = booructl("user", "set-email", "alice", "alice@gmail.com")

        assert_equal(true, success)
        assert_match(/Changed alice's email to alice@gmail.com/, stdout)
        assert_equal("alice@gmail.com", @user.reload.email_address.address)
        assert_equal(false, @user.email_address.is_verified?)
        assert_equal(true, @session.reload.active?)
        assert_equal("email_address_update", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_equal("changed user ##{@user.id}'s email to alice@gmail.com", ModAction.last.description)
        assert_enqueued_with(job: MailDeliveryJob, args: ->(args) { args[0..1] == %w[UserMailer email_change_confirmation] })
      end

      should "change an existing email address" do
        create(:email_address, user: @user, address: "old@gmail.com")
        _, _, success = booructl("user", "set-email", "alice", "new@gmail.com")

        assert_equal(true, success)
        assert_equal("new@gmail.com", @user.reload.email_address.address)
        assert_equal("changed user ##{@user.id}'s email from old@gmail.com to new@gmail.com", ModAction.last.description)
      end

      should "mark the email as verified with --verified" do
        _, _, success = booructl("user", "set-email", "alice", "alice@gmail.com", "--verified")

        assert_equal(true, success)
        assert_equal(true, @user.reload.email_address.is_verified?)
      end

      should "log the user out with --logout" do
        booructl("user", "set-email", "alice", "alice@gmail.com", "--logout")

        assert_equal(true, @session.reload.revoked?)
      end

      should "remove the email address with --remove" do
        create(:email_address, user: @user, address: "alice@gmail.com")
        stdout, _, success = booructl("user", "set-email", "alice", "--remove")

        assert_equal(true, success)
        assert_match(/Removed alice's email/, stdout)
        assert_nil(@user.reload.email_address)
        assert_equal("email_address_update", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_equal("removed user ##{@user.id}'s email alice@gmail.com", ModAction.last.description)
      end

      should "fail to remove an email address the user doesn't have" do
        _, stderr, success = booructl("user", "set-email", "alice", "--remove")

        assert_equal(false, success)
        assert_match(/doesn't have an email address/, stderr)
      end

      should "fail if neither or both of EMAIL and --remove are given" do
        _, stderr, success = booructl("user", "set-email", "alice")
        assert_equal(false, success)
        assert_match(/--remove/, stderr)

        _, stderr, success = booructl("user", "set-email", "alice", "alice@gmail.com", "--remove")
        assert_equal(false, success)
        assert_match(/--remove/, stderr)
        assert_nil(@user.reload.email_address)
      end

      should "fail for an invalid email address" do
        _, stderr, success = booructl("user", "set-email", "alice", "not an email")

        assert_equal(false, success)
        assert_match(/Address is invalid/, stderr)
        assert_nil(@user.reload.email_address)
      end

      should "fail for an email address used by another user" do
        create(:email_address, address: "taken@gmail.com")
        _, stderr, success = booructl("user", "set-email", "alice", "taken@gmail.com")

        assert_equal(false, success)
        assert_match(/already been taken/, stderr)
        assert_nil(@user.reload.email_address)
      end

      should "fail for a deleted user" do
        @user.update!(is_deleted: true)
        _, stderr, success = booructl("user", "set-email", "##{@user.id}", "alice@gmail.com")

        assert_equal(false, success)
        assert_match(/deleted/, stderr)
      end
    end

    context "user rename command" do
      setup do
        @user = create(:user, name: "alice")
      end

      should "rename the user and send them a DMail" do
        stdout, _, success = booructl("user", "rename", "alice", "bob")

        assert_equal(true, success)
        assert_match(/Renamed alice to bob/, stdout)
        assert_equal("bob", @user.reload.name)
        assert_equal("user_name_change", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_equal("Your username has been changed", @user.dmails.last.title)
      end

      should "not send a DMail with --no-dmail" do
        assert_no_difference("Dmail.count") do
          _, _, success = booructl("user", "rename", "alice", "bob", "--no-dmail")
          assert_equal(true, success)
        end

        assert_equal("bob", @user.reload.name)
        assert_equal("user_name_change", ModAction.last.category)
      end

      should "rename a user who changed their name recently" do
        create(:user_name_change_request, user: @user, original_name: "alicia", desired_name: "alice")
        _, _, success = booructl("user", "rename", "alice", "bob")

        assert_equal(true, success)
        assert_equal("bob", @user.reload.name)
      end

      should "fail for an invalid name" do
        _, stderr, success = booructl("user", "rename", "alice", "bad name")

        assert_equal(false, success)
        assert_match(/Desired name can't contain whitespace/, stderr)
        assert_equal("alice", @user.reload.name)
      end

      should "fail for a name that's taken" do
        create(:user, name: "bob")
        _, stderr, success = booructl("user", "rename", "alice", "bob")

        assert_equal(false, success)
        assert_match(/already taken/, stderr)
        assert_equal("alice", @user.reload.name)
      end

      should "fail for a deleted user" do
        @user.update!(is_deleted: true)
        _, stderr, success = booructl("user", "rename", "##{@user.id}", "bob")

        assert_equal(false, success)
        assert_match(/deleted/, stderr)
      end
    end

    context "user deactivate command" do
      setup do
        @user = create(:user, name: "alice")
      end

      should "deactivate the user" do
        stdout, _, success = booructl("user", "deactivate", "alice", "--yes")

        assert_equal(true, success)
        assert_match(/Deactivated alice/, stdout)
        assert_equal(true, @user.reload.is_deleted?)
        assert_equal("user_#{@user.id}", @user.name)
        assert_equal("user_delete", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
        assert_enqueued_with(job: DeleteUserJob)
      end

      should "deactivate privileged users" do
        @user.update!(level: User::Levels::ADMIN)
        _, _, success = booructl("user", "deactivate", "alice", "--yes")

        assert_equal(true, success)
        assert_equal(true, @user.reload.is_deleted?)
      end

      should "require --yes when stdin isn't a terminal" do
        _, stderr, success = booructl("user", "deactivate", "alice")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_equal(false, @user.reload.is_deleted?)
      end

      should "not deactivate the only superadmin" do
        @user.update!(level: User::Levels::SUPERADMIN)
        _, stderr, success = booructl("user", "deactivate", "alice", "--yes")

        assert_equal(false, success)
        assert_match(/only Superadmin/, stderr)
        assert_equal(false, @user.reload.is_deleted?)
      end

      should "fail for a user who is already deleted" do
        @user.update!(is_deleted: true)
        _, stderr, success = booructl("user", "deactivate", "##{@user.id}", "--yes")

        assert_equal(false, success)
        assert_match(/already deactivated/, stderr)
      end
    end

    context "db commands" do
      should "print the commands they run, without the password" do
        Danbooru::CLI::DbCommand.any_instance.stubs(:pg_env).returns({ "PGHOST" => "db.example.com", "PGUSER" => "danbooru", "PGPASSWORD" => "hunter2", "PGDATABASE" => "danbooru" })
        _, stderr, success = booructl("db", "backup", "-o", "db.pg_dump", "--dry-run")

        assert_equal(true, success)
        assert_equal("$ pg_dump --host=db.example.com --username=danbooru --dbname=danbooru --format=custom --compress=zstd --file db.pg_dump\n", stderr)
        assert_no_match(/hunter2/, stderr)
      end

      should "back up and check the database" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "db.pg_dump")
          _, _, success = booructl("db", "backup", "-o", backup)
          assert_equal(true, success)

          stdout, stderr, success = booructl("db", "check", backup)
          assert_equal(true, success)
          assert_equal("$ pg_restore --file=- -- #{backup}\n", stderr)
          assert_match(/The backup has \d+ tables, \d+ rows, and \d+ indexes/, stdout)
        end
      end

      should "fail to check a corrupt backup" do
        Danbooru::Tempfile.create do |file|
          file.write("garbage")
          file.flush
          stdout, stderr, success = booructl("db", "check", file.path)

          assert_equal(false, success)
          assert_empty(stdout)
          assert_match(/incomplete or corrupt/, stderr)
        end
      end

      should "not write a backup in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "db.pg_dump")
          _, stderr, success = booructl("db", "backup", "-o", backup, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ pg_dump /, stderr)
          assert_equal(false, File.exist?(backup))
        end
      end

      should "refuse to restore into a non-empty database" do
        _, stderr, success = booructl("db", "restore", File::NULL)

        assert_equal(false, success)
        assert_match(/isn't empty/, stderr)
      end

      should "not reset the database without confirmation" do
        _, stderr, success = booructl("db", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "not reset the database in dry run mode" do
        database = ActiveRecord::Base.connection.current_database
        _, stderr, success = booructl("db", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb .*--if-exists --force -- #{database}$/, stderr)
        assert_match(/^\$ createdb .* -- #{database}$/, stderr)
        assert_match(%r{^\$ \S*bin/rails db:schema:load db:seed$}, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "not load the schema when resetting with --empty" do
        _, stderr, success = booructl("db", "reset", "--empty", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ createdb /, stderr)
        assert_no_match(/db:schema:load/, stderr)
      end

      should "empty the database before restoring with --force" do
        database = ActiveRecord::Base.connection.current_database
        _, stderr, success = booructl("db", "restore", "backup.pg_dump", "--force", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb .* -- #{database}\n\$ createdb .* -- #{database}\n\$ pg_restore .* -- backup.pg_dump$/, stderr)
        assert_no_match(/db:schema:load/, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end
    end

    context "images commands" do
      setup do
        @variant = create(:post_with_file).media_asset.variant(:original)
      end

      should "back up, check, and restore images" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "images.tar")
          _, stderr, success = booructl("images", "backup", "-o", backup)
          assert_equal(true, success)
          assert_match(/^\$ tar --create --file #{Regexp.escape(backup)} --directory #{Regexp.escape(@temp_dir)} \.$/, stderr)

          stdout, stderr, success = booructl("images", "check", backup)
          assert_equal(true, success)
          assert_equal("$ tar --list --verbose --file #{backup}\n", stderr)
          assert_match(/^The backup has 1 image \(4 files, [\d.]+ KB\)\.$/, stdout)

          FileUtils.rm_rf(Dir.glob("#{@temp_dir}/*"))
          assert_nil(@variant.open_file)

          stdout, stderr, success = booructl("images", "restore", backup)
          assert_equal(true, success)
          assert_equal("$ tar --extract --verbose --verbose --file #{backup} --directory #{@temp_dir} --no-same-owner --no-overwrite-dir\n", stderr)
          assert_match(/^Restored 1 image \(4 files, [\d.]+ KB\)\.$/, stdout)
          assert_not_nil(@variant.open_file)
        end
      end

      should "fail to check a corrupt backup" do
        Danbooru::Tempfile.create do |file|
          file.write("garbage")
          file.flush
          stdout, stderr, success = booructl("images", "check", file.path)

          assert_equal(false, success)
          assert_empty(stdout)
          assert_match(/incomplete or corrupt/, stderr)
        end
      end

      should "not write a backup in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "images.tar")
          _, stderr, success = booructl("images", "backup", "-o", backup, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ tar --create /, stderr)
          assert_equal(false, File.exist?(backup))
        end
      end

      should "delete all images on reset" do
        _, stderr, success = booructl("images", "reset", "--yes")

        assert_equal(true, success)
        assert_match(/^\$ find #{Regexp.escape(@temp_dir)} -mindepth 1 -delete$/, stderr)
        assert_nil(@variant.open_file)
        assert_equal(true, Dir.exist?(@temp_dir))
        assert_empty(Dir.children(@temp_dir))
      end

      should "not delete images without confirmation" do
        _, stderr, success = booructl("images", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "not delete images in dry run mode" do
        _, stderr, success = booructl("images", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ find /, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "refuse to work when images aren't stored locally" do
        Danbooru.config.stubs(:storage_manager).returns(StorageManager::Null.new)
        _, stderr, success = booructl("images", "backup", "-o", File::NULL)

        assert_equal(false, success)
        assert_match(/aren't stored locally/, stderr)
      end
    end

    context "instance commands" do
      setup do
        @variant = create(:post_with_file).media_asset.variant(:original)
      end

      should "back up and check the database and images" do
        Danbooru::Tempdir.create do |dir|
          backup_dir = File.join(dir.path, "backup")
          _, _, success = booructl("instance", "backup", backup_dir)
          assert_equal(true, success)
          assert_equal(%w[danbooru-database.pg_dump danbooru-images.tar], Dir.children(backup_dir).sort)

          stdout, _, success = booructl("instance", "check", backup_dir)
          assert_equal(true, success)
          assert_match(/The backup has \d+ tables/, stdout)
          assert_match(/The backup has 1 image \(4 files/, stdout)
        end
      end

      should "not write anything in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup_dir = File.join(dir.path, "backup")
          _, stderr, success = booructl("instance", "backup", backup_dir, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ pg_dump /, stderr)
          assert_match(/^\$ tar --create /, stderr)
          assert_equal(false, Dir.exist?(backup_dir))
        end
      end

      should "not reset without confirmation" do
        _, stderr, success = booructl("instance", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "print the commands to reset the database and images in dry run mode" do
        _, stderr, success = booructl("instance", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb /, stderr)
        assert_match(/^\$ createdb /, stderr)
        assert_match(/^\$ find /, stderr)
        assert_match(/db:schema:load db:seed/, stderr)
        assert_not_nil(@variant.open_file)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "empty the database before restoring with --force" do
        Danbooru::Tempdir.create do |dir|
          _, stderr, success = booructl("instance", "restore", dir.path, "--force", "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ dropdb .*\n\$ createdb .*\n\$ pg_restore /, stderr)
          assert_match(/^\$ tar --extract /, stderr)
        end
      end
    end

    context "media regenerate command" do
      setup do
        @post = create(:post_with_file)
        @asset = @post.media_asset
      end

      should "regenerate missing thumbnails" do
        @asset.variant(:"180x180").delete_file!
        stdout, _, success = booructl("media", "regenerate", "--no-ai-tags")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
        assert_nothing_raised { @asset.variant(:"180x180").open_file! }
      end

      should "only regenerate assets matching the search" do
        @asset.variant(:"180x180").delete_file!
        _, _, success = booructl("media", "regenerate", "id:#{@asset.id + 1}", "--no-ai-tags")

        assert_equal(true, success)
        assert_raises(Errno::ENOENT) { @asset.variant(:"180x180").open_file! }
      end

      should "not change anything in dry run mode" do
        @asset.variant(:"180x180").delete_file!
        stdout, _, success = booructl("media", "regenerate", "--dry-run")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
        assert_raises(Errno::ENOENT) { @asset.variant(:"180x180").open_file! }
      end

      should "work when processing media assets in parallel" do
        ApplicationRecord.connection.stubs(:transaction_open?).returns(false)
        stdout, _, success = booructl("media", "regenerate", "id:>0", "--dry-run")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
      end

      should "report failures and exit with an error" do
        @asset.variant(:original).delete_file!
        _, stderr, success = booructl("media", "regenerate", "--no-ai-tags")

        assert_equal(false, success)
        assert_match(/media asset ##{@asset.id}/, stderr)
      end
    end

    context "iqdb reindex command" do
      setup do
        @post = create(:post_with_file)
        @deleted_post = create(:post_with_file, filename: "png/test.png", is_deleted: true)
      end

      should "fail if IQDB isn't enabled" do
        _, stderr, success = booructl("iqdb", "reindex")

        assert_equal(false, success)
        assert_match(/IQDB isn't enabled/, stderr)
      end

      should "add all posts to IQDB, including deleted posts" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).with(@post)
        IqdbClient.any_instance.expects(:add_post).with(@deleted_post)

        stdout, _, success = booructl("iqdb", "reindex")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
        assert_match(/post ##{@deleted_post.id}/, stdout)
      end

      should "only add posts matching the search" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).with(@post).once
        IqdbClient.any_instance.expects(:add_post).with(@deleted_post).never

        _, _, success = booructl("iqdb", "reindex", "id:#{@post.id}")
        assert_equal(true, success)
      end

      should "work when processing posts in parallel" do
        # Outside of tests, parallel_find_each processes records in parallel instead of falling back to find_each.
        ApplicationRecord.connection.stubs(:transaction_open?).returns(false)
        mock_iqdb_enable!

        stdout, _, success = booructl("iqdb", "reindex", "--dry-run")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
        assert_match(/post ##{@deleted_post.id}/, stdout)
      end

      should "not change anything in dry run mode" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).never

        stdout, _, success = booructl("iqdb", "reindex", "--dry-run")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
      end
    end
  end
end
