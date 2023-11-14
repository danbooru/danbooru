# frozen_string_literal: true

# A BackgroundJob is a job in the good_jobs table. This class is simply an
# extension of GoodJob::Job, with a few extra methods for searching jobs.
#
# @see https://github.com/bensheldon/good_job
class BackgroundJob < GoodJob::Job
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
        class_name = name.tr(" ", "_").gsub("/", "::").camelize + "Job"
        where_json_contains(:serialized_params, { job_class: class_name })
      end

      def search(params, current_user)
        q = search_attributes(params, [:id, :created_at, :updated_at, :queue_name, :priority, :serialized_params, :scheduled_at, :performed_at, :finished_at, :error, :active_job_id, :concurrency_key, :cron_key, :retried_good_job_id, :cron_at], current_user: current_user)

        if params[:name].present?
          q = q.name_matches(params[:name])
        end

        if params[:status].present?
          q = q.status_matches(params[:status])
        end

        case params[:order]
        when "created_at"
          q = q.order(created_at: :desc)
        when "updated_at"
          q = q.order(updated_at: :desc)
        when "scheduled_at"
          q = q.order(scheduled_at: :desc)
        when "performed_at"
          q = q.order(performed_at: :desc)
        when "finished_at"
          q = q.order(finished_at: :desc)
        else
          q = q.apply_default_order(params)
        end
      end
    end

    def pretty_name
      job_class.titleize.delete_suffix(" Job")
    end

    def job_duration
      finished_at - performed_at if finished_at
    end

    def queue_delay
      performed_at - created_at if performed_at
    end
  end
end
