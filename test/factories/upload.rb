FactoryBot.define do
  factory(:upload) do
    uploader factory: :user
    uploader_ip_addr { "127.0.0.1" }

    status { "pending" }
    source { "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg" }

    factory(:completed_source_upload) do
      status { "completed" }
      upload_media_assets { [build(:upload_media_asset)] }
    end

    factory(:completed_file_upload) do
      status { "completed" }
      source { nil }
      file { Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg") }

      upload_media_assets do
        [build(:upload_media_asset, media_asset: build(:media_asset, file: "test/files/test.jpg"))]
      end
    end
  end
end
