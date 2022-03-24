module UploadTestHelper
  extend ActiveSupport::Concern

  def create_upload!(source_or_file_path, user:, **params)
    if source_or_file_path =~ %r{\Ahttps?://}i
      skip "Login credentials not configured for #{source_or_file_path}" unless Source::Extractor.find(source_or_file_path).class.enabled?
      source = { source: source_or_file_path }
    else
      file = Rack::Test::UploadedFile.new(Rails.root.join(source_or_file_path))
      source = { files: { "0" => file } }
    end

    perform_enqueued_jobs do
      post_auth uploads_path(format: :json), user, params: { upload: { **source, **params }}
    end
  end

  def assert_successful_upload(source_or_file_path, user: create(:user), **params)
    create_upload!(source_or_file_path, user: user, **params)

    upload = Upload.last
    assert_response 201
    assert_equal("", upload&.error.to_s)
    assert_equal("completed", upload.status)
    assert_operator(upload.media_assets.count, :>, 0)
    upload
  end

  class_methods do
    def should_upload_successfully(source)
      should "upload successfully from #{source}" do
        assert_successful_upload(source, user: create(:user))
      end
    end
  end
end
