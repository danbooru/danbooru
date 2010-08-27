module Jobs
  class ProcessUploads
    def perform
      Upload.find_each(:conditions => ["status = ?", "pending"]) do |upload|
        upload.process!
      end
    end
  end
end
