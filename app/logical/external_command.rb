# frozen_string_literal: true

# Runs the external programs that we use on untrusted files (ffmpeg, ffprobe, mkvmerge, exiftool) with time and memory
# limits, so that a malicious file can't make them run forever or use all the memory.
class ExternalCommand
  class TimeoutError < StandardError; end

  TIMEOUT = 1.minute
  MEMORY_LIMIT = 4.gigabytes

  # The environment variables passed to commands. Commands use jemalloc (see the Dockerfile) to stay under the memory limit.
  ENVIRONMENT = %w[PATH LD_PRELOAD MALLOC_CONF].freeze

  # Run a command and return its output. The command is killed if it runs longer than the timeout. We can't use Ruby's
  # `Timeout` for this, because it waits for the command to finish before raising the timeout error.
  #
  # The command isn't run through a shell, and it only gets the variables in ENVIRONMENT, so it can't see secrets like
  # database passwords or API keys.
  #
  # @param command [String] The command to run. Arguments must already be shell-escaped.
  # @param timeout [Integer] The maximum number of seconds the command can run.
  # @param memory_limit [Integer] The maximum number of bytes of memory the command can use.
  # @return [Array<(String, Process::Status)>] The combined stdout and stderr of the command, and its exit status.
  # @raise [TimeoutError] If the command ran longer than the timeout.
  def self.run(command, timeout: TIMEOUT, memory_limit: MEMORY_LIMIT)
    # Disable core dumps, otherwise a command that crashes when it hits the memory limit can fill the disk.
    output, status = Open3.capture2e(
      ENV.slice(*ENVIRONMENT), "timeout", "--kill-after=10", timeout.to_i.to_s, *command.shellsplit,
      unsetenv_others: true, rlimit_as: memory_limit.to_i, rlimit_core: 0,
    )

    # `timeout` exits with 124 if it stopped the command, or 137 if it had to kill it.
    raise TimeoutError, "#{command.shellsplit.first} timed out after #{timeout.to_i} seconds" if status.exitstatus.in?([124, 137])

    [output, status]
  end
end
