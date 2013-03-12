#!/usr/bin/env ruby

require 'mail'

class UploadErrorChecker
  def check!
    count = Upload.where("status like 'error%' and created_at >= ?", 1.hour.ago).count
    if count > 5
      mail = Mail.new do
        from "webmaster@danbooru.donmai.us"
        to "r888888888@gmail.com"
        subject "[danbooru] Upload error count at #{count}"
        body "nt"
      end
      mail.delivery_method :sendmail
      mail.deliver
    end
  end
end

