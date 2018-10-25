#!/usr/bin/env ruby

require 'mail'

class UploadErrorChecker
  def check!
    uploads = Upload.where("status like 'error%' and status not like 'error: Upload::Error - Post with MD5%' and status not like 'error: ActiveRecord::RecordInvalid - Validation failed: Md5 duplicate%' and created_at >= ?", 1.hour.ago)
    if uploads.size > 5
      mail = Mail.new do
        from Danbooru.config.contact_email
        to Danbooru.config.contact_email
        CurrentUser.as_system do
          subject "[#{Danbooru.config.app_name}] Upload error count at #{uploads.size}"
        end
        body uploads.map {|x| x.status}.join("\n")
      end
      mail.delivery_method :sendmail
      mail.deliver
    end
  end
end

