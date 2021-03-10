class BigqueryExportJob < ApplicationJob
  retry_on Exception, attempts: 0

  def perform(model:, **options)
    BigqueryExportService.new(model, **options).export!
  end
end
