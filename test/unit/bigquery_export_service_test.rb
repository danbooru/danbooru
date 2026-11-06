require "test_helper"

class BigqueryExportServiceTest < ActiveSupport::TestCase
  context "BigqueryExportService: " do
    context "the models method" do
      should "not export private tables" do
        assert_not_includes(BigqueryExportService.models, IpGeolocation)
        assert_not_includes(BigqueryExportService.models, BackgroundJob)
        assert_not_includes(BigqueryExportService.models, GoodJob::ConcurrencyClaim)
      end
    end

    context "the records method" do
      should "not include IP geolocation data for anonymous users" do
        IpGeolocation.create!(ip_addr: "1.2.3.4", is_proxy: false, latitude: 1.0, longitude: 2.0, city: "Paris")

        assert_equal(0, IpGeolocation.visible(User.anonymous).count)
        assert_equal(0, BigqueryExportService.new(IpGeolocation).records.count)
        assert_equal(1, IpGeolocation.visible(create(:moderator_user)).count)
      end
    end

    context "#async_export_all! method" do
      should "export all tables to BigQuery" do
        @post = create(:post, tag_string: "tagme")
        @bigquery = BigqueryExportService.new(dataset_name: "testbooru_export")
        skip unless @bigquery.enabled?

        BigqueryExportService.async_export_all!(dataset_name: "testbooru_export")
        perform_enqueued_jobs(only: BigqueryExportAllJob)

        assert_equal(1, @bigquery.dataset.table("posts").rows_count)
        assert_equal(1, @bigquery.dataset.table("tags").rows_count)
      end
    end
  end
end
