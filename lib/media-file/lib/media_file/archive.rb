# frozen_string_literal: true

# A class for reading and extracting .zip, .rar, and .7z archives. The archives are read by `bin/archive` in a separate
# process inside the ExternalCommand sandbox, so a bug in libarchive or rubyzip can't be exploited by a malicious file
# to take over the Rails process.
#
# @example
#   MediaFile::Archive.extract!("foo.zip") do |dir, filenames|
#     puts dir, filenames
#   end
#
# @see bin/archive
# @see https://github.com/chef/ffi-libarchive
# @see https://github.com/libarchive/libarchive/wiki/ManualPages
class MediaFile
  class Archive
    extend Memoist

    # An archive that can't be read. By default, the message doesn't say why, because the details aren't useful to users.
    # bin/archive uses the same message.
    class InvalidArchiveError < MediaFile::InvalidFileError
      def initialize(message = "invalid or corrupt archive")
        super
      end
    end

    # The archive types that can be read. Ugoiras are .zip files too, but they're read by `MediaFile::Ugoira` instead.
    FILE_TYPES = %i[zip rar 7z].freeze

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
    # @raise [InvalidArchiveError] If the command crashed, or printed too much.
    # @raise [MediaFile::TimeoutError] If the command timed out.
    # @raise [MediaFile::ExternalCommand::SyscallError] If the command was killed by the sandbox. This isn't wrapped, so the file
    #   can be quarantined (see `MediaAsset.handle_blocked_file`).
    def self.run!(*args, read: [], write: [], timeout: MediaFile::ExternalCommand::TIMEOUT, file_size_limit: MediaFile.config.max_file_size.to_i)
      result = MediaFile::ExternalCommand.run_script("bin/archive", *args, gems: %w[ffi ffi-libarchive rubyzip], read:, write:, timeout:, memory_limit: MEMORY_LIMIT, file_size_limit:)
      raise InvalidArchiveError unless result && (result["error"].nil? || result["error"].is_a?(String))

      result
    rescue MediaFile::ExternalCommand::OutputLimitError
      raise InvalidArchiveError, "too many files"
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
    # @raise [InvalidArchiveError] If any path isn't directly inside the directory, or isn't a regular file.
    def self.verify_extracted_files!(paths, directory)
      raise InvalidArchiveError unless paths.is_a?(Array) && paths.all?(String)

      paths.each do |path|
        # The path is compared as a string, not resolved, so the directory can be under a symlink (e.g. /tmp on macOS).
        # bin/archive can't replace the directory itself, or create symlinks or hardlinks, so a path directly inside it
        # that isn't a symlink can't point anywhere else.
        raise InvalidArchiveError if File.dirname(path) != directory.to_s || !File.lstat(path).file?
      end

      File.chmod(0o600, *paths)
      paths
    rescue SystemCallError
      raise InvalidArchiveError
    end

    # Read the file lists of several archives with one call to bin/archive, instead of starting a process for each
    # archive. Each archive keeps its list, so `#entries` doesn't read it again. If one archive is invalid, its
    # `#entries` raises the error.
    #
    # @param archives [Array<MediaFile::Archive>] The archives.
    # @return [Array<MediaFile::Archive>] The archives.
    # @raise [InvalidArchiveError] If bin/archive failed.
    #   If bin/archive called a blocked syscall, the SyscallError is the error's `cause`.
    def self.list!(archives)
      pending = archives.reject(&:listed?)
      return archives if pending.empty?

      args = pending.flat_map { [it.file_ext, it.path, it.max_entries] }
      result = run!("list", MAX_PATHNAME_SIZE, *args, read: pending.map(&:path), timeout: LIST_TIMEOUT)
      raise InvalidArchiveError, result["error"] if result["error"]

      results = result["archives"]
      raise InvalidArchiveError unless results.is_a?(Array) && results.size == pending.size

      pending.zip(results) do |archive, listing|
        listing = { "error" => InvalidArchiveError.new.message } unless valid_listing?(listing, archive.max_entries)
        archive.listing = listing
      end

      archives
    rescue MediaFile::ExternalCommand::SyscallError
      raise InvalidArchiveError
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
    # @yieldparam [MediaFile::Archive] The archive.
    # @return [MediaFile::Archive] The archive, or the block's result if given a block.
    # @raise [InvalidArchiveError] If the file can't be opened, or the block raises an error.
    def self.open!(filelike, max_entries: MAX_ENTRIES, &block)
      file = filelike.respond_to?(:path) ? filelike : File.open(filelike, binmode: true)
      archive = new(file, max_entries:)
      return archive unless block_given?

      begin
        yield archive
      ensure
        file.close unless file.equal?(filelike)
      end
    rescue MediaFile::InvalidFileError
      raise
    # Other errors, like a missing file or a bug in the block, can have details that aren't for users, like file paths.
    # The original error is kept as the `cause`.
    rescue StandardError
      raise InvalidArchiveError
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
    # @raise [InvalidArchiveError] If the archive is invalid.
    def listing
      self.class.list!([self]) unless listed?
      raise InvalidArchiveError, @listing["error"] if @listing["error"]

      @listing
    end

    # @return [Boolean] True if the archive's file list has been read, even if reading it failed.
    def listed?
      !@listing.nil?
    end

    # @return [Array<MediaFile::Archive::Entry>] The first `max_entries` entries in the archive. The rest of the archive
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
    # @raise [InvalidArchiveError] If the archive couldn't be extracted. If bin/archive called a blocked syscall, the
    #   SyscallError is the error's `cause`.
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
    rescue MediaFile::ExternalCommand::SyscallError
      raise InvalidArchiveError
    end

    # Extract the archive to a directory with bin/archive. See `extract!` for details.
    #
    # @return [Hash{String => String}] The path on disk and the name in the archive of each extracted file.
    # @raise [InvalidArchiveError] If the archive couldn't be extracted.
    def extract_to!(directory)
      # libarchive won't extract through symlinks (EXTRACT_SECURE_SYMLINKS), so a directory under a symlink like /tmp on
      # macOS has to be resolved first.
      directory = File.realpath(directory)
      result = self.class.run!("extract", file_ext, path, directory, read: [path], write: [directory])
      raise InvalidArchiveError, result["error"] if result["error"]

      files = result["files"]
      raise InvalidArchiveError unless files.is_a?(Array) && files.all? { it in { path: String, name: String, **nil } }

      self.class.verify_extracted_files!(files.pluck("path"), directory)
      files.to_h { [it["path"], it["name"]] }
    end

    # Check that the archive can be read and is safe to extract. Only the first `max_entries` files are checked, so
    # `max_entries` must be more than `max_files` to detect archives with too many files.
    #
    # @param max_files [Integer] The most files the archive can contain.
    # @param max_size [Integer] The largest total uncompressed size of the files, in bytes.
    # @param name [String] The name of the archive in error messages, like the name of the file the user uploaded.
    # @raise [InvalidArchiveError] If the archive can't be read, or isn't safe to extract.
    def validate!(max_files:, max_size:, name: File.basename(path))
      raise InvalidArchiveError, "'#{name}' is not a supported file type" unless file_ext.in?(FILE_TYPES)

      begin
        entries
      rescue MediaFile::InvalidFileError => e
        raise InvalidArchiveError, "'#{name}' couldn't be read (#{e.user_message})"
      end

      if file_count == 0
        raise InvalidArchiveError, "'#{name}' doesn't contain any files"
      elsif file_count > max_files
        raise InvalidArchiveError, "'#{name}' contains too many files (max #{max_files} files)"
      elsif uncompressed_size > max_size
        raise InvalidArchiveError, "'#{name}' is too large (uncompressed size: #{uncompressed_size.to_fs(:human_size)}; max size: #{max_size.to_fs(:human_size)})"
      elsif entries.any?(&:pathname_too_long?)
        raise InvalidArchiveError, "'#{name}' contains a path that's too long (max #{MAX_PATHNAME_SIZE} bytes)"
      elsif (entry = entries.find { it.pathname.starts_with?("/") })
        raise InvalidArchiveError, "'#{entry.pathname}' in '#{name}' can't start with '/'"
      elsif (entry = entries.find(&:directory_traversal?))
        raise InvalidArchiveError, "'#{entry.pathname}' in '#{name}' can't contain '..' components"
      elsif (entry = entries.find { !it.file? && !it.directory? })
        raise InvalidArchiveError, "'#{entry.pathname}' in '#{name}' isn't a regular file"
      end
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
      MediaFile::FileTypeDetector.new(file).file_ext
    end

    # @return [String] The MD5 hash of the archive file, as a hex string.
    memoize def md5
      Digest::MD5.file(path).hexdigest
    end

    # @!method file_size
    #   @return [Integer] The size of the archive file in bytes.
    delegate :size, to: :file, prefix: true
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
