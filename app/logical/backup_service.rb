class BackupService
  def backup(file_path, options = {})
    raise NotImplementedError.new("#{self.class}.backup not implemented")
  end

  def delete(file_path, options = {})
    raise NotImplementedError.new("#{self.class}.delete not implemented")
  end
end
