require 'delayed/plugin'

class DelayedJobTimeoutPlugin < ::Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:execute) do |job|
      Delayed::Job.connection.execute "set statement_timeout = 0"
    end
  end
end

Delayed::Worker.logger = Logger.new(STDOUT, level: :debug)
Delayed::Worker.default_queue_name = "default"
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.plugins << DelayedJobTimeoutPlugin
