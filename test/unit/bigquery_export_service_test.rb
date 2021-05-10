require 'test_helper'

class BigqueryExportServiceTest < ActiveSupport::TestCase
  context "BigqueryExportService: " do
    context "#async_export_all! method" do
      should "export all tables to BigQuery" do
        @post = create(:post, tag_string: "tagme")
        @bigquery = BigqueryExportService.new(dataset_name: "testbooru_export")
        skip unless @bigquery.enabled?

        BigqueryExportService.async_export_all!(dataset_name: "testbooru_export")
        perform_enqueued_jobs

        assert_equal(1, @bigquery.dataset.table("posts").rows_count)
        assert_equal(1, @bigquery.dataset.table("tags").rows_count)
      end
    end
  end
end
