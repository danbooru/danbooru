# frozen_string_literal: true

# The base class for bin/booructl subcommands.
class Danbooru::CLI::Command < Thor
  def self.exit_on_failure?
    true
  end

  private

  # Call the block on each record in parallel, printing each success to stdout and each failure to stderr. Skip calling
  # the block if --dry-run is given. Fail at the end if any record failed.
  def process_each(relation, name)
    failures = Concurrent::AtomicFixnum.new

    # Searches may be ordered, but batches are always processed in ID order.
    relation.reorder(nil).parallel_find_each do |record|
      yield record unless options[:dry_run]
      say "#{name} ##{record.id}"
    rescue StandardError => e
      failures.increment
      say_error "#{name} ##{record.id}: #{e.class}: #{e.message}"
    end

    raise Thor::Error, "#{failures.value} #{name.pluralize(failures.value)} failed" if failures.value > 0
  end

  # Print a shell command (or a pipeline of commands) to stderr, then run it unless --dry-run is given.
  #
  # @param commands [Array<Array<String>>] The commands to run. Multiple commands are run as a pipeline.
  # @param env [Hash] Environment variables for the commands. These aren't printed, so they can contain secrets.
  # @param error [String] The error message to show if the command fails.
  # @yieldparam output [IO] If a block is given, the command's stdout is passed to it instead of printed.
  # @return [Object, nil] The block's result, or nil if --dry-run is given.
  def run_command(*commands, env: {}, error: "Command failed")
    # Quote arguments with single quotes, unless they only contain safe characters. Shellwords works too, but the result is harder to read.
    quoted = commands.map { |command| command.map { |arg| arg.match?(%r{\A[\w@%+=:,./-]+\z}) ? arg : "'#{arg.gsub("'") { "'\\''" }}'" }.join(" ") }
    say_error "$ #{quoted.join(" | ")}"
    return if options[:dry_run]

    commands = commands.map { |command| [env, *command] }
    if block_given?
      result, statuses = Open3.pipeline_r(*commands) { |output, threads| [yield(output), threads.map(&:value)] }
    else
      statuses = Open3.pipeline(*commands)
    end

    raise Thor::Error, error unless statuses.all?(&:success?)
    result
  end

  # Ask the user to confirm a destructive action. Skipped if --yes or --dry-run is given.
  def confirm!(message)
    return if options[:yes] || options[:dry_run]
    raise Thor::Error, "#{message} Use --yes to confirm." unless $stdin.tty?

    answer = ask("#{message} Type 'yes' to continue:")
    raise Thor::Error, "Aborted." unless answer == "yes"
  end
end
