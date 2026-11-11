require "test_helper"

class ProcessUploadMediaAssetJobTest < ActiveJob::TestCase
  # Pretend another worker is in the middle of performing a job with the given labels.
  def create_running_job(labels: [])
    GoodJob::Job.create!(active_job_id: SecureRandom.uuid, job_class: "ProcessUploadMediaAssetJob", labels: labels, performed_at: Time.zone.now)
  end

  context "ProcessUploadMediaAssetJob" do
    setup do
      # Concurrency limits are only enforced when jobs are run by GoodJob, not by the test adapter.
      ProcessUploadMediaAssetJob.stubs(:queue_adapter).returns(GoodJob::Adapter.new(execution_mode: :inline))
    end

    context "for a site with a concurrent download limit" do
      setup do
        @source_url = "https://ac.arca.live/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig"
      end

      should "wait for a free download slot when the limit is reached" do
        2.times { create_running_job(labels: ["downloads:Arca.live"]) }
        Source::Extractor::ArcaLive.any_instance.expects(:download_file!).never

        upload_media_asset = create(:upload_media_asset, source_url: @source_url, media_asset: nil)
        job = GoodJob::Job.order(:created_at).last

        assert_equal("pending", upload_media_asset.reload.status)
        assert_equal(["downloads:Arca.live"], job.labels)
        assert_nil(job.finished_at)
        assert_operator(job.scheduled_at, :>, Time.zone.now)
      end

      should "download the file when the limit isn't reached" do
        create_running_job(labels: ["downloads:Arca.live"])
        Source::Extractor::ArcaLive.any_instance.expects(:download_file!).returns(MediaFile.open("test/files/jpg/test.jpg"))

        upload_media_asset = create(:upload_media_asset, source_url: @source_url, media_asset: nil)

        assert_equal("active", upload_media_asset.reload.status)
      end
    end

    context "for a site without a concurrent download limit" do
      should "not limit concurrent downloads" do
        2.times { create_running_job(labels: ["downloads:Arca.live"]) }
        5.times { create_running_job }
        Source::Extractor::Twitter.any_instance.expects(:download_file!).returns(MediaFile.open("test/files/jpg/test.jpg"))

        upload_media_asset = create(:upload_media_asset, source_url: "https://pbs.twimg.com/media/FQjQA1mVgAMcHLv.jpg:orig", media_asset: nil)
        job = GoodJob::Job.order(:created_at).last

        assert_equal("active", upload_media_asset.reload.status)
        assert_empty(job.labels.to_a)
      end
    end
  end
end
