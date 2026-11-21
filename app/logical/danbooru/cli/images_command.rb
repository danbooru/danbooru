# frozen_string_literal: true

# `bin/booructl images` commands for backing up, restoring, and resetting images. Only works when images are stored
# locally.
class Danbooru::CLI::ImagesCommand < Danbooru::CLI::Command
  namespace "images"

  class_option :dry_run, type: :boolean, default: false, desc: "Print the commands that would be run without running them"

  desc "backup", "Back up images to a tar file"
  long_desc <<~EOS
    Back up all images, thumbnails, and samples to a tar file. Writes to stdout unless --output is given.

    Example: bin/booructl images backup > danbooru-images.tar
  EOS
  option :output, aliases: "-o", type: :string, default: "-", desc: "The file to write the backup to"
  def backup
    run_command(["tar", "--create", "--file", options[:output], "--directory", image_dir, "."], error: "Backup failed.")
  end

  desc "check [FILE]", "Check a backup and show how many images it has"
  long_desc <<~EOS
    Check a backup made by `bin/booructl images backup`. Reads from stdin if FILE isn't given.

    Example: bin/booructl images check danbooru-images.tar
  EOS
  def check(file = "-")
    summary = run_command(["tar", "--list", "--verbose", "--file", file], error: "The backup is incomplete or corrupt.") { |listing| summarize_files(listing) }
    say "The backup has #{summary}." if summary
  end

  desc "restore [FILE]", "Restore images from a tar file"
  long_desc <<~EOS
    Restore images from a backup made by `bin/booructl images backup`. Reads from stdin if FILE isn't given. Existing
    images with the same name are overwritten.

    Example: bin/booructl images restore danbooru-images.tar
  EOS
  def restore(file = "-")
    summary = run_command(["tar", "--extract", "--verbose", "--verbose", "--file", file, "--directory", image_dir, "--no-same-owner", "--no-overwrite-dir"], error: "Restore failed.") { |listing| summarize_files(listing) }
    say "Restored #{summary}." if summary
  end

  desc "reset", "Delete all images"
  long_desc <<~EOS
    Delete all images, thumbnails, and samples.

    Example: bin/booructl images reset --yes
  EOS
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  def reset
    dir = image_dir
    raise Thor::Error, "Refusing to delete images in #{dir}." unless Pathname.new(dir).absolute? && Pathname.new(dir).cleanpath.to_s != "/"

    confirm!("This will permanently delete all images in #{dir}.")
    run_command(["find", dir, "-mindepth", "1", "-delete"], error: "Couldn't delete images in #{dir}.")
  end

  private

  # Summarize the file listing from `tar --list --verbose` or `tar --extract --verbose --verbose`. Each file is a line like
  # `-rw-r--r-- danbooru/danbooru 28086 2024-01-01 00:00 ./original/ec/ef/ecef68c4.jpg`. Files under ./original/ are
  # counted as images; everything else is thumbnails and samples.
  #
  # @return [String] A summary like "1 image (4 files, 71.3 KB)".
  def summarize_files(listing)
    files = listing.each_line.lazy.filter_map { |line| line.split(" ", 6) if line.start_with?("-") }
    count, images, bytes = files.reduce([0, 0, 0]) do |(count, images, bytes), (_, _, size, _, _, path)|
      [count + 1, images + (path.start_with?("./original/") ? 1 : 0), bytes + size.to_i]
    end

    "#{images} #{"image".pluralize(images)} (#{count} files, #{bytes.to_fs(:human_size)})"
  end

  def image_dir
    storage = Danbooru.config.storage_manager
    raise Thor::Error, "Images aren't stored locally (storage is #{storage.class.name}). Manage them manually." unless storage.is_a?(StorageManager::Local)

    storage.base_dir.to_s
  end
end
