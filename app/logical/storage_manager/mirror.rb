# frozen_string_literal: true

# A StorageManager that mirrors files across multiple storage backends.
class StorageManager::Mirror < StorageManager
  attr_reader :services

  def initialize(services, **options)
    @services = services
    super(**options)
  end

  def store(src_file, dest_path)
    Parallel.each(services, in_threads: Etc.nprocessors) do |service|
      service.store(src_file, dest_path)
    end
  end

  def delete(path)
    Parallel.each(services, in_threads: Etc.nprocessors) do |service|
      service.delete(path)
    end
  end

  def open(path)
    services.first.open(path)
  end

  def file_url(path)
    services.first.file_url(path)
  end
end
