# frozen_string_literal: true

# Receives Content-Security-Policy violation reports sent by browsers and logs them.
#
# @see config/initializers/content_security_policy.rb
# @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/report-uri
class CSPReportsController < ApplicationController
  MAX_REPORT_SIZE = 10.kilobytes

  skip_forgery_protection

  def create
    authorize nil, policy_class: CSPReportPolicy

    report = JSON.parse(request.body.read(MAX_REPORT_SIZE).to_s)
    DanbooruLogger.info("Content-Security-Policy violation: #{report.to_json}")

    head 204
  rescue JSON::ParserError
    head 400
  end
end
