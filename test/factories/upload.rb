FactoryBot.define do
  factory(:upload) do
    uploader factory: :user

    status { "pending" }
    source { "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg" }
    error { nil }

    factory(:completed_source_upload) do
      status { "completed" }
      media_asset_count { 1 }
      upload_media_assets { [build(:upload_media_asset, source_url: "https://example.com/file.jpg", status: "active")] }
    end

    factory(:completed_file_upload) do
      status { "completed" }
      source { nil }
      media_asset_count { 1 }
      files { { "0" => Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg") } }

      upload_media_assets do
        [build(:upload_media_asset, media_asset: build(:media_asset, file: "test/files/test.jpg"), source_url: "file://test.jpg", status: "active")]
      end
    end
  end
end
