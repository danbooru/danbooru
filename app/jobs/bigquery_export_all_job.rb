# frozen_string_literal: true

# A job that runs daily to export all tables to BigQuery. Spawned by {DanbooruMaintenance}.
class BigqueryExportAllJob < ApplicationJob
  def perform
    BigqueryExportService.async_export_all!
  end
end
