module UploadTestHelper
  extend ActiveSupport::Concern

  def upload_from_file(filepath)
    UploadService.new(file: upload_file(filepath)).start!
  end

  def upload_file(path)
    file = Tempfile.new(binmode: true)
    IO.copy_stream("#{Rails.root}/#{path}", file.path)
    uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: File.basename(path))

    yield uploaded_file if block_given?
    uploaded_file
  end

  def assert_successful_upload(source_or_file_path, user: @user, **params)
    if source_or_file_path =~ %r{\Ahttps?://}i
      return "Login credentials not configured for #{source_or_file_path}" unless Sources::Strategies.find(source_or_file_path).class.enabled?
      source = { source: source_or_file_path }
    else
      file = Rack::Test::UploadedFile.new(Rails.root.join(source_or_file_path))
      source = { file: file }
    end

    assert_difference(["Upload.count"]) do
      post_auth uploads_path, user, params: { upload: { tag_string: "abc", rating: "e", **source, **params }}
    end

    upload = Upload.last
    assert_response :redirect
    assert_redirected_to upload
    assert_equal("completed", upload.status)
    assert_equal(Post.last, upload.post)
    assert_equal(upload.post.md5, upload.md5)
    assert_not_nil(upload.media_asset)
    assert_operator(upload.media_asset.media_metadata.metadata.count, :>=, 1)
    upload
  end

  class_methods do
    def should_upload_successfully(source)
      should "upload successfully from #{source}" do
        assert_successful_upload(source, user: create(:user, created_at: 1.month.ago))
      end
    end
  end
end
