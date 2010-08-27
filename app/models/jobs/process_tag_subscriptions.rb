module Jobs
  class ProcessTagSubscriptions < Struct.new(:last_run)
    def perform
      if last_run.nil? || last_run < 20.minutes.ago
        TagSubscription.process_all
        Delayed::Job.enqueue(ProcessTagSubscriptions.new(Time.now))
      end
    end
  end
end
