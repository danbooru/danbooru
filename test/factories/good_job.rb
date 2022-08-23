FactoryBot.define do
  factory :good_job, class: GoodJob::Job do
    transient do
      job { VacuumDatabaseJob.new }
    end

    id { SecureRandom.uuid }
    active_job_id { job.job_id }
    queue_name { job.queue_name }
    priority { job.priority }
    serialized_params do
      { job_class: job.class.name, **job.as_json }
    end
  end
end
