# frozen_string_literal: true

# `bin/booructl user` commands for creating, managing, and recovering users. Changes are made as the system user, with
# no privilege checks, so they work on admins and superadmins too, and are logged as mod actions.
#
# Commands that take a USER accept a name ("alice"), an ID ("#123" or "id:123"), or an email address.
class Danbooru::CLI::UserCommand < Danbooru::CLI::Command
  namespace "user"

  desc "create NAME", "Create a new user"
  long_desc <<~EOS
    Create a new user. Prompts for the password, unless --password-stdin is given. The first user created on a new
    instance automatically becomes a Superadmin.

    Example: echo "$PASSWORD" | bin/booructl user create alice --level Admin --password-stdin
  EOS
  option :level, type: :string, desc: "The user's level (#{User.level_hash.keys.without("Anonymous").join(", ")})"
  option :password_stdin, type: :boolean, default: false, desc: "Read the password from stdin"
  def create(name)
    level = parse_level(options[:level]) if options[:level]
    password = read_password

    User.transaction do
      user = User.create(name:, password:, password_confirmation: password)
      raise Thor::Error, user.errors.full_messages.join(", ") if user.errors.any?

      # The first user on a new instance is automatically a Superadmin. Don't demote them.
      set_level!(user, level) if level && !user.is_superadmin?
      say "Created user #{user.name} (#{user.level_string})"
    end
  end

  desc "set-level USER LEVEL", "Promote or demote a user to the given level"
  long_desc <<~EOS
    Promote or demote a user to the given level. Levels: #{User.level_hash.keys.without("Anonymous").join(", ")}.

    The user is sent a DMail and a neutral feedback, and a mod action is logged, the same as promoting them on the site.
  EOS
  def set_level(identifier, level)
    user = find_user!(identifier)

    set_level!(user, parse_level(level))
    say "#{user.name} is now #{user.level_string}"
  end

  desc "show USER", "Show a user's account details"
  def show(identifier)
    user = find_user!(identifier, modify: false)
    ban = user.active_ban
    email = user.email_address

    if email.nil?
      email_status = "none"
    else
      email_status = "#{email.address} (#{email.is_verified? ? "verified" : "unverified"})"
    end

    if ban.present?
      ban_status = "yes, #{ban.humanized_duration}: #{ban.reason} (expires #{ban.expires_at})"
    elsif user.is_banned?
      ban_status = "yes (expired)"
    else
      ban_status = "no"
    end

    print_table([
      ["ID:", user.id.to_s],
      ["Name:", user.name],
      ["Level:", user.level_string],
      ["Created:", user.created_at],
      ["Last login:", user.last_logged_in_at || "never"],
      ["Last IP:", user.last_ip_addr || "unknown"],
      ["Email:", email_status],
      ["2FA:", user.has_2fa? ? "enabled (#{user.backup_codes.to_a.size} backup codes)" : "disabled"],
      ["Banned:", ban_status],
      ["Deleted:", user.is_deleted? ? "yes" : "no"],
      ["Sessions:", "#{user.login_sessions.active.count} active"],
      ["API keys:", user.api_keys.count.to_s],
    ])
  end

  desc "set-password USER", "Set a user's password"
  long_desc <<~EOS
    Set a user's password immediately and log them out everywhere. Prompts for the password, unless
    --password-stdin is given. No email is sent.

    Prefer `reset-link`, which lets the user choose their own password.
  EOS
  option :password_stdin, type: :boolean, default: false, desc: "Read the password from stdin"
  option :logout, type: :boolean, default: true, desc: "Log the user out of all their sessions"
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  def set_password(identifier) # rubocop:disable Naming/AccessorMethodName -- Thor names the command after the method
    user = find_user!(identifier)
    confirm!("Change #{user.name}'s password?")
    password = read_password

    user.with_lock do
      raise Thor::Error, "#{user.name} is deleted. Undelete them first." if user.is_deleted?
      raise Thor::Error, user.errors.full_messages.join(", ") unless user.update(password:, password_confirmation: password)

      ModAction.log("changed password for user ##{user.id}", :user_password_change, subject: user, user: User.system)
      say "Changed #{user.name}'s password"
      revoke_sessions!(user) if options[:logout]
    end
  end

  desc "reset-link USER", "Print a link the user can use to choose a new password"
  long_desc <<~EOS
    Print a password reset link for the user, without emailing it to them. Send it to them yourself. The link expires
    in 30 minutes, and stops working once the password is changed. Resetting the password logs the user out everywhere.

    If the user has 2FA enabled, they'll still need a 2FA or backup code to reset their password. Use `disable-2fa`
    first if they've lost them.
  EOS
  def reset_link(identifier)
    user = find_user!(identifier)
    raise Thor::Error, "#{user.name} is deleted. Undelete them first." if user.is_deleted?

    path = Rails.application.routes.url_helpers.edit_password_reset_path(user: { signed_id: user.generate_token_for(:password_reset) })
    ModAction.log("generated a password reset link for user ##{user.id}", :user_password_reset, subject: user, user: User.system)

    say "#{Danbooru.config.canonical_url}#{path}"
    say_error "Warning: #{user.name} has 2FA enabled. They'll need a 2FA or backup code to use this link, unless you run `booructl user disable-2fa` first." if user.has_2fa?
  end

  desc "disable-2fa USER", "Disable two-factor authentication for a user"
  long_desc <<~EOS
    Disable 2FA for a user who lost their 2FA device and backup codes, and log them out everywhere. Their backup codes
    are deleted too. They can enable 2FA again from their account settings.
  EOS
  option :logout, type: :boolean, default: true, desc: "Log the user out of all their sessions"
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  def disable_2fa(identifier)
    user = find_user!(identifier)
    confirm!("Disable 2FA for #{user.name}?")

    user.with_lock do
      raise Thor::Error, "#{user.name} doesn't have 2FA enabled" unless user.has_2fa?
      raise Thor::Error, user.errors.full_messages.join(", ") unless user.update(totp_secret: nil, backup_codes: nil)

      ModAction.log("disabled 2FA for user ##{user.id}", :user_2fa_disable, subject: user, user: User.system)
      say "Disabled 2FA for #{user.name}"
      revoke_sessions!(user) if options[:logout]
    end
  end

  desc "send-backup-code USER", "Email one of a user's 2FA backup codes to them"
  long_desc <<~EOS
    Email one of the user's 2FA backup codes to their email address, the same as sending one from their account page.
    The email is sent by a background job, so email and the job worker must be set up.
  EOS
  def send_backup_code(identifier)
    user = find_user!(identifier)

    user.send_backup_code!(User.system)
    raise Thor::Error, "#{user.name} #{user.errors.full_messages.join(", ")}" if user.errors.any?

    say "Sent a backup code to #{user.name}"
  end

  desc "logout USER", "Log a user out of all their sessions"
  option :api_keys, type: :boolean, default: false, desc: "Delete the user's API keys too"
  def logout(identifier)
    user = find_user!(identifier)

    user.with_lock do
      revoke_sessions!(user)

      if options[:api_keys]
        count = user.api_keys.destroy_all.size
        say "Deleted #{count} API #{"key".pluralize(count)}"
      end

      ModAction.log("logged out user ##{user.id}#{" and deleted their API keys" if options[:api_keys]}", :user_logout, subject: user, user: User.system)
    end
  end

  desc "ban USER", "Ban a user"
  long_desc <<~EOS
    Ban a user, the same as banning them on the site. They're sent a DMail and a negative feedback. Banned users can
    still log in, unless --logout is given.
  EOS
  option :duration, type: :string, required: true, desc: "1day, 3days, 7days, 1month, 3months, 6months, 1year, or forever"
  option :reason, type: :string, required: true, desc: "The reason for the ban, shown to the user"
  option :logout, type: :boolean, default: false, desc: "Log the user out of all their sessions"
  def ban(identifier)
    user = find_user!(identifier)
    raise Thor::Error, "#{user.name} is the only Superadmin. Promote another user to Superadmin first." if only_superadmin?(user)

    # "3days" or "3 days" => 3.days
    durations = Ban::DURATIONS.index_by { |duration| Ban.new(duration:).humanized_duration.delete(" ") }
    duration = durations.fetch(options[:duration].downcase.gsub(/[[:space:]]/, "")) do
      raise Thor::Error, "Invalid duration '#{options[:duration]}'. Valid durations: #{durations.keys.join(", ")}"
    end

    ban = Ban.create(user:, banner: User.system, duration:, reason: options[:reason])
    raise Thor::Error, ban.errors.full_messages.join(", ") if ban.errors.any?

    say "Banned #{user.name} #{ban.forever? ? "forever" : "for #{ban.humanized_duration}"}"
    revoke_sessions!(user) if options[:logout]
  end

  desc "unban USER", "Unban a user"
  def unban(identifier)
    user = find_user!(identifier)
    raise Thor::Error, "#{user.name} isn't banned" unless user.is_banned? || user.bans.active.exists?

    User.transaction do
      user.bans.active.find_each do |ban|
        ban.updater = User.system
        ban.destroy!
      rescue ActiveRecord::RecordNotDestroyed
        raise Thor::Error, ban.errors.full_messages.join(", ")
      end

      user.unban!
    end

    say "Unbanned #{user.name}"
  end

  desc "set-email USER [EMAIL]", "Change or remove a user's email address"
  long_desc <<~EOS
    Change a user's email address, or remove it with --remove. The new address is unverified unless --verified is
    given. Either way, a confirmation email is sent to the new address.
  EOS
  option :remove, type: :boolean, default: false, desc: "Remove the user's email address"
  option :verified, type: :boolean, default: false, desc: "Mark the new address as verified"
  option :logout, type: :boolean, default: false, desc: "Log the user out of all their sessions"
  def set_email(identifier, address = nil)
    raise Thor::Error, "Give either an email address or --remove." if address.present? == options[:remove]
    user = find_user!(identifier)

    user.with_lock do
      raise Thor::Error, "#{user.name} is deleted. Undelete them first." if user.is_deleted?
      email = user.email_address

      if options[:remove]
        raise Thor::Error, "#{user.name} doesn't have an email address" if email.nil?

        email.updater = User.system
        email.destroy!
        say "Removed #{user.name}'s email"
      else
        email ||= user.build_email_address
        email.assign_attributes(address:, updater: User.system)
        email.is_verified = true if options[:verified]
        raise Thor::Error, email.errors.full_messages.join(", ") unless email.save

        say "Changed #{user.name}'s email to #{email.address}"
      end

      revoke_sessions!(user) if options[:logout]
    end
  end

  desc "rename USER NEW_NAME", "Change a user's name"
  long_desc <<~EOS
    Change a user's name, the same as a moderator renaming them on the site. The once-a-week limit on name changes
    doesn't apply. The user is sent a DMail saying their old name was invalid or broke the rules, unless --no-dmail is
    given.
  EOS
  option :dmail, type: :boolean, default: true, desc: "Send the user a DMail about the name change"
  def rename(identifier, new_name)
    user = find_user!(identifier)

    user.with_lock do
      raise Thor::Error, "#{user.name} is deleted. Undelete them first." if user.is_deleted?
      old_name = user.name

      name_change = UserNameChangeRequest.create(user:, original_name: old_name, desired_name: new_name, updater: User.system, skip_dmail: !options[:dmail])
      raise Thor::Error, name_change.errors.full_messages.join(", ") if name_change.errors.any?

      say "Renamed #{old_name} to #{user.name}"
    end
  rescue ActiveRecord::RecordInvalid => e
    raise Thor::Error, e.record.errors.full_messages.join(", ")
  end

  desc "deactivate USER", "Deactivate a user's account"
  long_desc <<~EOS
    Deactivate a user's account, the same as the user deleting it themselves. They're renamed to user_<id>, their
    password is scrambled, and their email, 2FA, API keys, settings, saved searches, and private favorites are deleted.
    Some of this is done by a background job. This can't be undone.
  EOS
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  def deactivate(identifier)
    user = find_user!(identifier)
    raise Thor::Error, "#{user.name} is already deactivated" if user.is_deleted?
    raise Thor::Error, "#{user.name} is the only Superadmin. Promote another user to Superadmin first." if only_superadmin?(user)

    confirm!("Deactivate #{user.name}? This deletes their email, 2FA, API keys, and settings, and can't be undone.")
    old_name = user.name
    UserDeletion.new(user:, deleter: User.system).delete!(validate: false)

    say "Deactivated #{old_name} (now #{user.reload.name})"
  end

  private

  # Look up a user by name ("alice"), ID ("#123" or "id:123"), or email address ("alice@example.com"). Names can't
  # start with "#" or contain ":" or "@", so these can't be confused with each other.
  #
  # @param identifier [String] The name, ID, or email address.
  # @param modify [Boolean] If true, refuse to return the system user, so commands can't change it.
  # @return [User] The user.
  def find_user!(identifier, modify: true)
    case identifier
    when /\A(?:#|id:)([0-9]+)\z/
      user = User.find_by(id: $1)
    when /@/
      user = User.find_by_email(identifier)
    else
      user = User.find_by_name(identifier)
    end

    raise Thor::Error, "User '#{identifier}' not found" if user.nil?
    raise Thor::Error, "Can't change the system user" if modify && user.name == Danbooru.config.system_user
    user
  end

  def read_password
    raise Thor::Error, "No password given. Use --password-stdin to read the password from stdin." if !options[:password_stdin] && !$stdin.tty?
    options[:password_stdin] ? $stdin.gets.to_s.chomp : ask("Password:", echo: false).tap { say }
  end

  def revoke_sessions!(user)
    sessions = user.login_sessions.active.to_a
    sessions.each(&:revoke!)
    say "Logged #{user.name} out of #{sessions.size} #{"session".pluralize(sessions.size)}"
  end

  # @return [Integer] The level number for a level name like "admin".
  def parse_level(level)
    User.level_hash.except("Anonymous").transform_keys(&:downcase).fetch(level.downcase) do
      raise Thor::Error, "Invalid level '#{level}'. Valid levels: #{User.level_hash.keys.without("Anonymous").join(", ")}"
    end
  end

  # If there are no superadmins, the next person to sign up becomes one (see User#promote_to_superadmin_if_first_user).
  def only_superadmin?(user)
    user.is_superadmin? && User.where(level: User::Levels::SUPERADMIN).count == 1
  end

  def set_level!(user, level)
    return if level == user.level
    raise Thor::Error, "#{user.name} is the only Superadmin. Promote another user to Superadmin first." if level < User::Levels::SUPERADMIN && only_superadmin?(user)

    UserPromotion.new(user, User.system, level).promote!(validate: false)
  rescue ActiveRecord::RecordInvalid => e
    raise Thor::Error, e.record.errors.full_messages.join(", ")
  end
end
