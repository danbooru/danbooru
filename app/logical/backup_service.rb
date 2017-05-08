class BackupService
  def backup(file_path, options = {})
    raise NotImplementedError.new("#{self.class}.backup not implemented")
  end
end
