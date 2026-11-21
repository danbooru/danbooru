# frozen_string_literal: true

# `bin/booructl user` commands for creating and managing users. Changes are made as the system user, with no
# privilege checks, so admins and superadmins can be created.
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

    raise Thor::Error, "No password given. Use --password-stdin to read the password from stdin." if !options[:password_stdin] && !$stdin.tty?
    password = options[:password_stdin] ? $stdin.gets.to_s.chomp : ask("Password:", echo: false).tap { say }

    User.transaction do
      user = User.create(name:, password:, password_confirmation: password)
      raise Thor::Error, user.errors.full_messages.join(", ") if user.errors.any?

      # The first user on a new instance is automatically a Superadmin. Don't demote them.
      set_level!(user, level) if level && !user.is_superadmin?
      say "Created user #{user.name} (#{user.level_string})"
    end
  end

  desc "set-level NAME LEVEL", "Promote or demote a user to the given level"
  long_desc <<~EOS
    Promote or demote a user to the given level. Levels: #{User.level_hash.keys.without("Anonymous").join(", ")}.

    The user is sent a DMail and a neutral feedback, and a mod action is logged, the same as promoting them on the site.
  EOS
  def set_level(name, level)
    user = User.find_by_name(name)
    raise Thor::Error, "User '#{name}' not found" if user.nil?

    set_level!(user, parse_level(level))
    say "#{user.name} is now #{user.level_string}"
  end

  private

  # @return [Integer] The level number for a level name like "admin".
  def parse_level(level)
    User.level_hash.except("Anonymous").transform_keys(&:downcase).fetch(level.downcase) do
      raise Thor::Error, "Invalid level '#{level}'. Valid levels: #{User.level_hash.keys.without("Anonymous").join(", ")}"
    end
  end

  def set_level!(user, level)
    return if level == user.level

    # If there are no superadmins, the next person to sign up becomes one (see User#promote_to_superadmin_if_first_user).
    if user.is_superadmin? && level < User::Levels::SUPERADMIN && User.where(level: User::Levels::SUPERADMIN).count == 1
      raise Thor::Error, "#{user.name} is the only Superadmin. Promote another user to Superadmin first."
    end

    UserPromotion.new(user, User.system, level).promote!(validate: false)
  rescue ActiveRecord::RecordInvalid => e
    raise Thor::Error, e.record.errors.full_messages.join(", ")
  end
end
