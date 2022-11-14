# frozen_string_literal: true

# Danbooru::Archive is a utility class representing a .zip, .rar, or .7z archive file. This is a wrapper around
# libarchive that adds some utility methods for extracting an archive safely.
#
# @example
#   Danbooru::Archive.extract!("foo.zip") do |dir, filenames|
#     puts dir, filenames
#   end
#
# @see https://github.com/chef/ffi-libarchive
# @see https://www.rubydoc.info/gems/ffi-libarchive/0.4.2
# @see https://github.com/libarchive/libarchive/wiki/ManualPages

module Archive
  module C
    # XXX Monkey patch ffi-libarchive to add some functions we need.
    # https://www.freebsd.org/cgi/man.cgi?query=archive_util&sektion=3&format=html
    attach_function_maybe :archive_format_name, [:pointer], :string
    attach_function_maybe :archive_filter_name, [:pointer, :int], :string
    attach_function_maybe :archive_filter_count, [:pointer], :int
  end
end

module Danbooru
  class Archive
    class Error < StandardError; end

    # Default flags when extracting files.
    # @see https://www.freebsd.org/cgi/man.cgi?query=archive_write_disk&sektion=3&format=html
    DEFAULT_FLAGS =
      ::Archive::EXTRACT_NO_OVERWRITE |
      #::Archive::EXTRACT_SECURE_NOABSOLUTEPATHS |
      ::Archive::EXTRACT_SECURE_SYMLINKS |
      ::Archive::EXTRACT_SECURE_NODOTDOT

    attr_reader :file

    # Open an archive, or raise an error if the archive can't be opened. If given a block, pass the archive to the block
    # and close the archive after the block finishes.
    #
    # @param filelike [String, File] The filename of the archive, or an open archive file.
    # @yieldparam [Danbooru::Archive] The archive.
    # @return [Danbooru::Archive] The archive.
    def self.open!(filelike, &block)
      file = filelike.is_a?(File) ? filelike : Kernel.open(filelike, binmode: true)
      archive = new(file)

      if block_given?
        begin
          yield archive
        ensure
          archive.close
        end
      else
        archive
      end
    rescue => error
      archive&.close
      raise Error, error
    end

    # Open an archive, or return nil if the archive can't be opened. See `#open!` for details.
    def self.open(filelike, &block)
      open!(filelike, &block)
    rescue Error
      nil
    end

    # Extract the archive to the given directory. If a block is given, extract the archive to a temp directory and
    # delete the directory afterwards. The block is given the name of the directory and the list of files.
    #
    # @param filelike [String, File] The filename of the archive, or an open archive file.
    # @param directory [String] The directory to extract the files to. By default, this is a temp directory the caller must clean up.
    # @yieldparam [String, Array<String>] The path to the temp directory, and the list of extracted files in the directory.
    # @return [(String, Array<String>)] The path to the directory, and the list of extracted files in the directory.
    def self.extract!(filelike, directory = nil, flags: DEFAULT_FLAGS, &block)
      open!(filelike) do |archive|
        archive.extract!(directory, flags: flags, &block)
      end
    end

    # @param file [File] The archive file.
    def initialize(file)
      @file = file
    end

    def close
      # no-op
    end

    # Iterate across each entry (file) in the archive.
    #
    # @return [Enumerator, Danbooru:Archive] If given a block, call the block on each entry and return the archive
    #   itself. If not given a block, return an Enumerator.
    def each_entry(&block)
      return enum_for(:each_entry) unless block_given?

      # XXX We have to re-open the archive on every call because libarchive is designed for streaming and doesn't
      # support iterating across the archive multiple times.
      archive = ::Archive::Reader.open_filename(file.path)
      while (entry = archive.next_header(clone_entry: true))
        yield Entry.new(archive, entry)
      end

      self
    ensure
      archive&.close
    end
    alias_method :entries, :each_entry

    # Extract the files in the archive to a directory. Subdirectories inside the archive are ignored; all files are
    # extracted to a single top-level directory.
    #
    # If a block is given, extract the archive to a temp directory and delete the directory after the block finishes.
    # Otherwise, extract to a temp directory and return the directory. The caller should delete the directory afterwards.
    #
    # @param directory [String] The directory to extract the files to. By default, this is a temp directory the caller must clean up.
    # @yieldparam [String, Array<String>] The name of the temp directory, and the list of files in the directory.
    # @return [(String, Array<String>)] The path to the directory, and the list of extracted files.
    def extract!(directory = nil, flags: DEFAULT_FLAGS, &block)
      raise ArgumentError, "can't pass directory and block at the same time" if block_given? && directory.present?

      if block_given?
        Dir.mktmpdir(["danbooru-archive-", "-" + File.basename(file.path)]) do |dir|
          filenames = extract_to!(dir, flags: flags)
          yield dir, filenames
        end
      else
        dir = directory.presence || Dir.mktmpdir(["danbooru-archive-", "-" + File.basename(file.path)])
        filenames = extract_to!(dir, flags: flags)
        [dir, filenames]
      end
    end

    # Extract the archive to a directory. See `extract!` for details.
    def extract_to!(directory, flags: DEFAULT_FLAGS)
      entries.map do |entry|
        raise Danbooru::Archive::Error, "Can't extract archive containing absolute path (path: '#{entry.pathname_utf8}')" if entry.pathname_utf8.starts_with?("/")
        raise Danbooru::Archive::Error, "'#{entry.pathname_utf8}' is not a regular file" if !entry.file?

        path = "#{directory}/#{entry.pathname_utf8.tr("/", "_")}"
        entry.extract!(path, flags: flags)
      end
    end

    # @return [Integer] The total decompressed size of all files in the archive.
    def uncompressed_size
      @uncompressed_size ||= entries.sum(&:size)
    end

    # @return [Boolean] True if any entry in the archive satisfies the condition; otherwise false.
    def exists?(&block)
      entries.with_index { |entry, index| return true if yield entry, index + 1 }
      false
    end

    # @return [Symbol] The archive format as detected by us (:zip, :rar, :7z, etc).
    def file_ext
      @file_ext ||= FileTypeDetector.new(file).file_ext
    end

    # @return [String] The archive format as returned by libarchive ("RAR", "ZIP", etc).
    def format
      @format ||= entries.lazy.map(&:format).first
    end

    # Print the archive contents in `ls -l` format.
    def ls(io = STDOUT)
      io.puts(entries.map(&:ls).join("\n"))
    end
  end

  # An entry represents a single file in an archive.
  class Entry
    attr_reader :archive, :entry
    delegate :directory?, :file?, :close, :pathname, :pathname=, :size, :strmode, :uid, :gid, :mtime, to: :entry

    # @param entry [::Archive] The archive the entry belongs to.
    # @param entry [::Archive::Entry] The archive entry.
    def initialize(archive, entry)
      @archive = archive
      @entry = entry
    end

    # Copy the entry. Called by `dup`.
    def initialize_copy(entry)
      @archive = entry.archive
      @entry = ::Archive::Entry.new(entry.ffi_ptr, clone: true)
    end

    # Extract the file to the given destination. By default, don't overwrite files, don't allow symlinks or paths
    # containing '..', and don't extract file ownership, permission, or timestamp information.
    #
    # @param destination [String] The path to extract the file to.
    # @param flags [Integer] The extraction flags.
    # @return [String] The path to the extracted file.
    def extract!(destination, flags: Danbooru::Archive::DEFAULT_FLAGS)
      entry = dup
      entry.pathname = destination

      result = ::Archive::C.archive_read_extract(entry.archive_ffi_ptr, entry.ffi_ptr, flags)
      raise Danbooru::Archive::Error, "Error extracting '#{entry.pathname_utf8}': #{archive.error_string}" if result != ::Archive::C::OK

      entry.pathname_utf8
    end

    # @return [String] The pathname encoded as UTF-8 instead of ASCII-8BIT. May be wrong if the original pathname wasn't UTF-8.
    def pathname_utf8
      pathname.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
    end

    # @return [String] The archive entry format ("RAR", "ZIP", etc).
    def format
      ::Archive::C::archive_format_name(archive_ffi_ptr)
    end

    # @return [Array<String>] The list of filters for the entry.
    def filters
      count = ::Archive::C::archive_filter_count(archive_ffi_ptr)

      count.times.map do |n|
        ::Archive::C::archive_filter_name(archive_ffi_ptr, n)
      end
    end

    # @return [String] The entry in `ls -l` format.
    def ls
      "#{strmode} #{uid} #{gid} #{"%9d" % size} #{mtime.to_fs(:db)} #{pathname_utf8}"
    end

    def archive_ffi_ptr
      archive.send(:archive)
    end

    # @return [FFI::Pointer] The pointer to the libarchive entry object.
    def ffi_ptr
      entry.entry
    end
  end
end
