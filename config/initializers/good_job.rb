GoodJob.active_record_parent_class = "ApplicationRecord"
GoodJob.retry_on_unhandled_error = false
GoodJob.preserve_job_records = true
Rails.application.config.good_job.smaller_number_is_higher_priority = true

# Called when a background job raises an unhandled exception. Only called for background jobs run with `perform_later`,
# not foreground jobs run with `perform_now`.
GoodJob.on_thread_error = ->(exception) do
  DanbooruLogger.log(exception)
end

# Start the metrics server on http://0.0.0.0:9090/metrics when bin/good_job is run.
if GoodJob::CLI.within_exe?
  Rails.application.config.after_initialize do
    RackMetricsServer.new.start
  end
end

ActiveSupport.on_load(:good_job_application_controller) do
  # Here we are inside GoodJob::ApplicationController. This doesn't inherit from our own ApplicationController, so
  # we need to include our own authentication and exception handling methods.

  include ApplicationController::AuthenticationMethods
  include ApplicationController::ExceptionHandlingMethods
  include Pundit::Authorization

  # Needed to render the default layout for error pages.
  helper ApplicationHelper
  helper IconHelper
  helper UsersHelper

  before_action :set_current_user
  before_action :authorize_user
  rescue_from Exception, with: :rescue_exception

  def authorize_user
    authorize(self, :can_view_good_job_dashboard?, policy_class: BackgroundJobPolicy)
  end

  def current_user
    CurrentUser.user
  end
end
