# frozen_string_literal: true

# A class for reading and extracting .zip, .rar, and .7z archives. The archives are read by `bin/archive` in a separate
# process inside the ExternalCommand sandbox, so a bug in libarchive or rubyzip can't be exploited by a malicious file
# to take over the Rails process.
#
# @example
#   Danbooru::Archive.extract!("foo.zip") do |dir, filenames|
#     puts dir, filenames
#   end
#
# @see bin/archive
# @see https://github.com/chef/ffi-libarchive
# @see https://github.com/libarchive/libarchive/wiki/ManualPages
module Danbooru
  class Archive
    extend Memoist

    class Error < StandardError; end

    # The error shown to users when an archive can't be read. The details aren't useful to users. bin/archive uses the
    # same error.
    INVALID_ARCHIVE = "invalid or corrupt archive"

    # The default number of entries to read. Archives with more files are only read up to this many files.
    MAX_ENTRIES = 1_000

    # The longest pathname listed by `#entries`, in bytes. Longer pathnames are truncated.
    MAX_PATHNAME_SIZE = 1024

    # The most address space bin/archive can use. Ruby reserves about 400 MB at startup, and decompressing needs about
    # as much memory as the archive's dictionary size, which is at most 128 MB for a 100 MB archive. Archives that
    # declare a bigger dictionary fail to extract.
    MEMORY_LIMIT = 1.gigabyte

    # The timeout for listing files. Listing only reads the headers of the first few files, so it should be fast, and
    # it happens during the upload request.
    LIST_TIMEOUT = 10.seconds

    attr_reader :file, :max_entries

    # Set by `.list!`, which reads the file lists of several archives at once.
    attr_writer :listing

    delegate :path, to: :file

    # Run a bin/archive command in the sandbox.
    #
    # @param args [Array<String>] The arguments to bin/archive.
    # @param read [Array<String>] The files the command can read.
    # @param write [Array<String>] The files and directories the command can write to.
    # @param timeout [Integer] The maximum number of seconds the command can run.
    # @param file_size_limit [Integer, nil] The largest file the command can write. By default, the max upload size.
    # @return [Hash] The parsed JSON output of the command. Has an "error" key if the archive is invalid.
    # @raise [Error] If the command crashed, timed out, or printed too much.
    # @raise [ExternalCommand::SyscallError] If the command was killed by the sandbox. This isn't wrapped, so the file
    #   can be quarantined (see `MediaAsset.handle_blocked_file`).
    def self.run!(*args, read: [], write: [], timeout: ExternalCommand::TIMEOUT, file_size_limit: Danbooru.config.max_file_size.to_i)
      result = ExternalCommand.run_script("bin/archive", *args, gems: %w[ffi ffi-libarchive rubyzip], read:, write:, timeout:, memory_limit: MEMORY_LIMIT, file_size_limit:)
      raise Error, INVALID_ARCHIVE unless result && (result["error"].nil? || result["error"].is_a?(String))

      result
    rescue ExternalCommand::TimeoutError
      raise Error, "timed out"
    rescue ExternalCommand::OutputLimitError
      raise Error, "too many files"
    end

    # Check that the files bin/archive says it extracted are regular files directly inside the directory it was given,
    # then make them readable. bin/archive parses untrusted files, so its output can't be trusted, otherwise a
    # compromised bin/archive could make us read other files on the server. The files keep the permissions from the
    # archive when they're extracted, which may make them unreadable. They're fixed here instead of in bin/archive,
    # because the sandbox can't limit which files chmod can change.
    #
    # @param paths [Array<String>] The paths of the extracted files.
    # @param directory [String] The directory the files were extracted to.
    # @return [Array<String>] The paths.
    # @raise [Error] If any path isn't directly inside the directory, or isn't a regular file.
    def self.verify_extracted_files!(paths, directory)
      raise Error, INVALID_ARCHIVE unless paths.is_a?(Array) && paths.all?(String)

      paths.each do |path|
        # The path is compared as a string, not resolved, so the directory can be under a symlink (e.g. /tmp on macOS).
        # bin/archive can't replace the directory itself, or create symlinks or hardlinks, so a path directly inside it
        # that isn't a symlink can't point anywhere else.
        raise Error, INVALID_ARCHIVE if File.dirname(path) != directory.to_s || !File.lstat(path).file?
      end

      File.chmod(0o600, *paths)
      paths
    rescue SystemCallError
      raise Error, INVALID_ARCHIVE
    end

    # Read the file lists of several archives with one call to bin/archive, instead of starting a process for each
    # archive. Each archive keeps its list, so `#entries` doesn't read it again. If one archive is invalid, its
    # `#entries` raises the error.
    #
    # @param archives [Array<Danbooru::Archive>] The archives.
    # @return [Array<Danbooru::Archive>] The archives.
    # @raise [Error] If bin/archive failed, for example because it timed out.
    def self.list!(archives)
      pending = archives.reject(&:listed?)
      return archives if pending.empty?

      args = pending.flat_map { [it.file_ext, it.path, it.max_entries] }
      result = run!("list", MAX_PATHNAME_SIZE, *args, read: pending.map(&:path), timeout: LIST_TIMEOUT)
      raise Error, result["error"] if result["error"]

      results = result["archives"]
      raise Error, INVALID_ARCHIVE unless results.is_a?(Array) && results.size == pending.size

      pending.zip(results) do |archive, listing|
        listing = { "error" => INVALID_ARCHIVE } unless valid_listing?(listing, archive.max_entries)
        archive.listing = listing
      end

      archives
    end

    # Check that a file list from bin/archive has the expected format, in case bin/archive was compromised by a
    # malicious file, so that it fails like any other invalid archive.
    #
    # @return [Boolean] True if the file list is valid, or if it's a valid error.
    def self.valid_listing?(listing, max_entries)
      case listing
      in { error: String, **nil }
        true
      in { entries: Array => entries, **nil }
        entries.size <= max_entries && entries.all? do |entry|
          entry in { pathname: String, pathname_too_long: true | false, size: Integer, filetype: "file" | "directory" | "other", **nil } and
            entry["pathname"].bytesize <= MAX_PATHNAME_SIZE && entry["size"] >= 0
        end
      else
        false
      end
    end

    # Open an archive. The archive isn't read until its entries are needed. If given a block, pass the archive to the
    # block, and close the file afterwards if it was opened here.
    #
    # @param filelike [String, File] The filename of the archive, or an open archive file.
    # @param max_entries [Integer] The most entries to read from the archive. See `#entries`.
    # @yieldparam [Danbooru::Archive] The archive.
    # @return [Danbooru::Archive] The archive, or the block's result if given a block.
    # @raise [Error] If the file can't be opened, or the block raises an error.
    def self.open!(filelike, max_entries: MAX_ENTRIES, &block)
      file = filelike.respond_to?(:path) ? filelike : File.open(filelike, binmode: true)
      archive = new(file, max_entries:)
      return archive unless block_given?

      begin
        yield archive
      ensure
        file.close unless file.equal?(filelike)
      end
    rescue StandardError => e
      raise Error, e
    end

    # Extract the archive to the given directory. If a block is given, extract the archive to a temp directory and
    # delete the directory afterwards. The block is given the name of the directory and the list of files.
    #
    # @param filelike [String, File] The filename of the archive, or an open archive file.
    # @param directory [String] The directory to extract the files to. By default, this is a temp directory the caller must clean up.
    # @yieldparam [String, Array<String>] The path to the temp directory, and the list of extracted files in the directory.
    # @return [(String, Array<String>)] The path to the directory, and the list of extracted files in the directory.
    def self.extract!(filelike, directory = nil, &block)
      open!(filelike) do |archive|
        archive.extract!(directory, &block)
      end
    end

    # @param file [File] The archive file.
    # @param max_entries [Integer] The most entries to read from the archive. See `#entries`.
    def initialize(file, max_entries: MAX_ENTRIES)
      @file = file
      @max_entries = max_entries
    end

    # @return [Hash] The first `max_entries` entries in the archive.
    # @raise [Error] If the archive is invalid.
    def listing
      self.class.list!([self]) unless listed?
      raise Error, @listing["error"] if @listing["error"]

      @listing
    end

    # @return [Boolean] True if the archive's file list has been read, even if reading it failed.
    def listed?
      !@listing.nil?
    end

    # @return [Array<Danbooru::Archive::Entry>] The first `max_entries` entries in the archive. The rest of the archive
    #   isn't read, so it isn't checked for errors.
    memoize def entries
      listing["entries"].map { |entry| Entry.new(**entry.symbolize_keys) }
    end

    # Extract the files in the archive to a directory. The files are saved as numbered files in the directory, not under
    # their names in the archive.
    #
    # If a block is given, extract the archive to a temp directory and delete the directory after the block finishes.
    # Otherwise, extract to a temp directory and return the directory. The caller should delete the directory afterwards.
    #
    # @param directory [String] The directory to extract the files to. By default, this is a temp directory the caller must clean up.
    # @yieldparam [String, Hash{String => String}] The name of the temp directory, and the path and name in the archive of each extracted file.
    # @return [(String, Hash{String => String})] The path to the directory, and the path and name in the archive of each extracted file.
    def extract!(directory = nil, &block)
      raise ArgumentError, "can't pass directory and block at the same time" if block_given? && directory.present?

      if block_given?
        Dir.mktmpdir(["danbooru-archive-", "-#{File.basename(file.path)}"]) do |dir|
          filenames = extract_to!(dir)
          yield dir, filenames
        end
      elsif directory.present?
        [directory, extract_to!(directory)]
      else
        begin
          dir = Dir.mktmpdir(["danbooru-archive-", "-#{File.basename(file.path)}"])
          result = [dir, extract_to!(dir)]
        ensure
          FileUtils.rm_rf(dir) if dir && result.nil?
        end
      end
    end

    # Extract the archive to a directory with bin/archive. See `extract!` for details.
    #
    # @return [Hash{String => String}] The path on disk and the name in the archive of each extracted file.
    # @raise [Error] If the archive couldn't be extracted.
    def extract_to!(directory)
      # libarchive won't extract through symlinks (EXTRACT_SECURE_SYMLINKS), so a directory under a symlink like /tmp on
      # macOS has to be resolved first.
      directory = File.realpath(directory)
      result = self.class.run!("extract", file_ext, path, directory, read: [path], write: [directory])
      raise Error, result["error"] if result["error"]

      files = result["files"]
      raise Error, INVALID_ARCHIVE unless files.is_a?(Array) && files.all? { it in { path: String, name: String, **nil } }

      self.class.verify_extracted_files!(files.pluck("path"), directory)
      files.to_h { [it["path"], it["name"]] }
    end

    # @return [Integer] The number of files in the archive, up to `max_entries`.
    def file_count
      entries.size
    end

    # @return [Integer] The total decompressed size of the first `max_entries` files in the archive.
    def uncompressed_size
      entries.sum(&:size)
    end

    # @return [Boolean] True if any of the first `max_entries` entries in the archive satisfies the condition; otherwise false.
    def exists?(&block)
      entries.each.with_index(1).any?(&block)
    end

    # @return [Symbol] The archive format as detected by us (:zip, :rar, :7z, etc).
    memoize def file_ext
      FileTypeDetector.new(file).file_ext
    end
  end

  # An entry represents a single file in an archive.
  #
  # @!attribute pathname [String] The path of the file in the archive, as UTF-8 with invalid bytes replaced. Truncated
  #   to MAX_PATHNAME_SIZE bytes.
  # @!attribute pathname_too_long [Boolean] True if the pathname was truncated.
  # @!attribute filetype [String] "file", "directory", or "other" (symlinks, hardlinks, devices, etc).
  Archive::Entry = Data.define(:pathname, :pathname_too_long, :size, :filetype) do
    alias_method :pathname_too_long?, :pathname_too_long

    def file?
      filetype == "file"
    end

    def directory?
      filetype == "directory"
    end

    # @see https://security.snyk.io/research/zip-slip-vulnerability
    # @return [Boolean] True if the pathname contains any ".." components, e.g. "../../../../../etc/passwd"
    def directory_traversal?
      pathname.split("/").compact_blank.grep("..").any?
    end
  end
end
