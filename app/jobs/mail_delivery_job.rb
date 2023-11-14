# frozen_string_literal: true

# A replacement for the default ActionMailer::MailDeliveryJob that inherits from ApplicationJob, so
# it inherits the same behavior as other jobs. It also inserts the job ID into the mail headers
# for logging purposes.
#
# @see https://github.com/rails/rails/blob/main/actionmailer/lib/action_mailer/mail_delivery_job.rb
# @see https://guides.rubyonrails.org/configuring.html#config-action-mailer-delivery-job
# @see config/application.rb (config.action_mailer.delivery_job = "MailDeliveryJob")
class MailDeliveryJob < ApplicationJob
  def perform(mailer, mail_method, delivery_method, args:, kwargs: nil, params: nil)
    mailer_class = mailer.constantize.with(params.to_h)                # mailer_class = UserMailer.with(params)
    mail = mailer_class.public_send(mail_method, *args, **kwargs.to_h) # mail = UserMailer.welcome_user(user)

    mail.headers(
      "X-Danbooru-Job-Id": job_id,
      "X-Danbooru-Enqueued-At": enqueued_at,
    )

    mail.send(delivery_method) # mail.deliver_now
  end
end
