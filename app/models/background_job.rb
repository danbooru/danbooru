# frozen_string_literal: true

# A BackgroundJob is a job in the good_jobs table. This class is simply an
# extension of GoodJob::ActiveJobJob, with a few extra methods for searching jobs.
#
# @see https://github.com/bensheldon/good_job/blob/main/lib/good_job/active_job_job.rb
class BackgroundJob < GoodJob::ActiveJobJob
  concerning :SearchMethods do
    class_methods do
      def default_order
        order(created_at: :desc)
      end

      def status_matches(status)
        case status.downcase
        when "queued"
          queued
        when "running"
          running
        when "finished"
          finished
        when "discarded"
          discarded
        else
          all
        end
      end

      def name_matches(name)
        class_name = name.tr(" ", "_").classify + "Job"
        where_json_contains(:serialized_params, { job_class: class_name })
      end

      def search(params)
        q = search_attributes(params, :id, :created_at, :updated_at, :queue_name, :priority, :serialized_params, :scheduled_at, :performed_at, :finished_at, :error, :active_job_id, :concurrency_key, :cron_key, :retried_good_job_id, :cron_at)

        if params[:name].present?
          q = q.name_matches(params[:name])
        end

        if params[:status].present?
          q = q.status_matches(params[:status])
        end

        q.apply_default_order(params)
      end
    end
  end
end
