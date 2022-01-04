# frozen_string_literal: true

# A job that exports a database table to Google Cloud Storage and to Google
# BigQuery. Spawned daily by {DanbooruMaintenance}.
#
# @see BigqueryExportService
class BigqueryExportJob < ApplicationJob
  def perform(model:, **options)
    BigqueryExportService.new(model, **options).export!
  end
end
