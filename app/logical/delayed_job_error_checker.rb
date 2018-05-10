#!/usr/bin/env ruby

require 'mail'

class DelayedJobErrorChecker
  def check!
    errors = Delayed::Job.where("last_error is not null").limit(100).pluck(:last_error).map {|x| x[0..100]}
    if errors.size == 100
      mail = Mail.new do
        from "webmaster@danbooru.donmai.us"
        to "r888888888@gmail.com"
        subject "[danbooru] Delayed job error count at #{errors}"
        body errors.uniq.join("\n")
      end
      mail.delivery_method :sendmail
      mail.deliver
    end
  end
end

