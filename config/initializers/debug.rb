# frozen_string_literal: true

# When a process forks, the debug gem keeps the debugger attached to both the parent and the child by default. This
# leaks a file and an at_exit handler in the parent on every fork, and ExternalCommand forks once per command, so keep
# the debugger attached to the parent only. Set RUBY_DEBUG_FORK_MODE to override this.
#
# @see https://github.com/ruby/debug#configuration
DEBUGGER__::CONFIG[:fork_mode] = :parent if defined?(DEBUGGER__::CONFIG) && ENV["RUBY_DEBUG_FORK_MODE"].blank?
