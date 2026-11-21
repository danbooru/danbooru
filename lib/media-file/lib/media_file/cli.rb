# frozen_string_literal: true

require "optparse"

# The `bin/media-cli` command. It runs the subcommand given as the first argument. Each subcommand is a method below,
# except `analyze`, which is in `MediaFile::CLI::Analyze`.
#
# Usage: `bin/media-cli <command> [options] [args]`
class MediaFile::CLI
  attr_reader :stdout, :stderr

  # @see #initialize
  # @return [Boolean] True if the command succeeded, false if it failed.
  def self.run!(...)
    new(...).run!
  end

  # @param argv [Array<String>] The command and its arguments, like `["validate", "foo.jpg"]`.
  # @param env [Hash] The environment variables.
  # @param stdout [IO] Where to print output.
  # @param stderr [IO] Where to print errors.
  def initialize(*argv, env: ENV, stdout: $stdout, stderr: $stderr)
    @argv = argv.dup
    @env = env
    @stdout = stdout
    @stderr = stderr
  end

  # @return [Boolean] True if the command succeeded, false if it failed.
  def run!
    command, *args = @argv

    case command
    when "analyze" then return MediaFile::CLI::Analyze.run!(*args, env: @env, stdout:, stderr:)
    when "validate" then validate(args)
    when "preview" then preview(args)
    when "convert" then convert(args)
    when "hash" then hashes(args)
    when "archive" then archive(args)
    when "doctor" then doctor(args)
    when "-h", "--help", "help" then stdout.puts usage
    when nil
      stdout.puts usage
      @failed = true
    else
      stderr.puts "unknown command: #{command}\n\n#{usage}"
      @failed = true
    end

    !@failed
  rescue Errno::EPIPE
    true # Ignore EPIPE errors when the output is piped to a command like `head` that closes the pipe early.
  rescue SystemExit => e
    e.success?
  rescue OptionParser::ParseError, MediaFile::Error, SystemCallError, ArgumentError => e
    stderr.puts e.message
    false
  end

  private

  def usage
    <<~EOS
      media-cli - Read, validate, and convert images, videos, and ugoiras

      Usage: media-cli <command> [options] [args]

      Commands:
        analyze [FILE|DIR ...]  List the properties of media files, like `ls` or `exiftool`
        validate FILE...        Check that files can be processed safely
        preview FILE            Make a thumbnail of an image, video, or ugoira
        convert FILE            Convert a ugoira to a video
        hash FILE...            Print the MD5 and pixel hash of files
        archive FILE...         List the files in .zip, .rar, or .7z archives and check that they're safe to extract
        doctor                  Check that the programs the library needs are installed

      Run `media-cli <command> --help` for a command's options.

      Set MEDIA_FILE_DISABLE_SANDBOX=true to run the programs without the sandbox, on kernels without Landlock.
    EOS
  end

  # Parse the command's options. Prints the help and exits for --help.
  #
  # @param args [Array<String>] The arguments. The options are removed from it.
  # @param usage [String] The usage line, like "validate [options] FILE...".
  # @param description [String] What the command does.
  # @yieldparam opts [OptionParser] The parser, to add the command's options to.
  def parse_options!(args, usage, description)
    OptionParser.new do |opts|
      opts.banner = "Usage: media-cli #{usage}\n\n#{description}\n"
      opts.separator ""
      yield opts if block_given?

      opts.on("-h", "--help", "Show this help message") do
        stdout.puts opts
        raise SystemExit
      end
    end.parse!(args)
  end

  # Raise an error if no files were given.
  def require_files!(args)
    raise ArgumentError, "no files given (see `media-cli #{@argv.first} --help`)" if args.empty?
  end

  def validate(args)
    max_duration = nil
    parse_options!(args, "validate [options] FILE...", "Check that files can be processed safely. Prints \"ok\" or why each file is invalid.") do |opts|
      opts.on("--max-duration=SECONDS", Integer, "The longest a video or animation can be (default: no limit)") { max_duration = it }
    end
    require_files!(args)

    args.each do |path|
      MediaFile.open(path) { |file| file.validate!(max_duration:) }
      stdout.puts "#{path}: ok"
    rescue MediaFile::InvalidFileError => e
      stdout.puts "#{path}: #{e.message}"
      @failed = true
    end
  end

  def preview(args)
    width, height = 150, 150
    options = {}
    output = nil

    parse_options!(args, "preview [options] FILE", "Make a thumbnail of an image, video, or ugoira that fits in the given size.") do |opts|
      opts.on("-s", "--size=WxH", /\A\d+x\d+\z/, "The max width and height (default: 150x150)") { width, height = it.split("x").map(&:to_i) }
      opts.on("-f", "--format=FORMAT", %w[jpeg webp], "The output format: jpeg or webp (default: jpeg)") { options[:format] = it.to_sym }
      opts.on("-q", "--quality=N", Integer, "The quality, from 1 to 100 (default: 85)") { options[:quality] = it }
      opts.on("-o", "--output=FILE", "Write the thumbnail to FILE (default: preview.jpg or preview.webp)") { output = it }
    end
    require_files!(args)

    output ||= "preview.#{(options[:format] == :webp) ? "webp" : "jpg"}"
    MediaFile.open(args.first) do |file|
      preview = file.preview!(width, height, **options)
      FileUtils.cp(preview.path, output)
      stdout.puts "#{output}: #{preview.width}x#{preview.height}"
    ensure
      preview&.close
    end
  end

  def convert(args)
    options = {}
    output = "out.webm"

    parse_options!(args, "convert [options] FILE", "Convert a ugoira to a video.") do |opts|
      opts.on("-o", "--output=FILE", "Write the video to FILE (default: out.webm)") { output = it }
      opts.on("-f", "--format=FORMAT", %w[mp4 webm mkv], "The video format: mp4, webm, or mkv (default: from the output file's extension)") { options[:format] = it.to_sym }
      opts.on("-c", "--codec=CODEC", %w[h264 h265 vp8 vp9 av1], "The video codec: h264, h265, vp8, vp9, or av1") { options[:codec] = it.to_sym }
      opts.on("-q", "--quality=QUALITY", %w[high lossless], "The quality: high or lossless") { options[:quality] = it.to_sym }
      opts.on("-s", "--scale=WxH", /\A\d+x\d+\z/, "Resize to the given size") { options[:width], options[:height] = it.split("x").map(&:to_i) }
      opts.on("--pix-fmt=PIX_FMT", %w[yuv420p yuva420p yuv444p], "The pixel format: yuv420p, yuva420p, or yuv444p") { options[:pix_fmt] = it.to_sym }
      opts.on("-t", "--[no-]two-pass", "Use two-pass encoding (slower but better quality). Default: yes for vp8 and vp9, no for the others") { options[:two_pass] = it }
    end
    require_files!(args)

    options[:format] ||= File.extname(output).delete_prefix(".").to_sym
    MediaFile.open(args.first) do |file|
      raise ArgumentError, "#{args.first} isn't a ugoira" unless file.is_a?(MediaFile::Ugoira)

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      video = file.convert(**options)
      FileUtils.cp(video.path, output)
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

      ratio = video.file_size.to_f / file.file_size
      stdout.puts "#{output} - #{video.width}x#{video.height} #{video.file_size.to_fs(:human_size)}/#{file.file_size.to_fs(:human_size)} (#{ratio.round(2)}x) in #{time.round(3)}s/#{file.duration}s (#{(file.duration / time).round(2)}x encoding speed)"
    ensure
      video&.close
    end
  end

  def hashes(args)
    parse_options!(args, "hash FILE...", "Print the MD5 of each file, and the MD5 of its pixels, which is the same for images with the same pixels.")
    require_files!(args)

    args.each do |path|
      MediaFile.open(path) { |file| stdout.puts "#{file.md5} #{file.pixel_hash} #{path}" }
    end
  end

  def archive(args)
    max_files = MediaFile::Archive::MAX_ENTRIES
    max_size = MediaFile.config.max_file_size

    parse_options!(args, "archive [options] FILE...", "List the files in .zip, .rar, or .7z archives, and check that they're safe to extract.") do |opts|
      opts.on("--max-files=N", Integer, "The most files an archive can contain (default: #{max_files})") { max_files = it }
      opts.on("--max-size=BYTES", Integer, "The largest total size of the files (default: #{max_size})") { max_size = it }
    end
    require_files!(args)

    args.each do |path|
      MediaFile::Archive.open!(path, max_entries: max_files + 1) do |archive|
        archive.validate!(max_files:, max_size:)
        archive.entries.each { |entry| stdout.puts format("%-9s %12d %s", entry.filetype, entry.size, entry.pathname) }
        stdout.puts "#{path}: ok"
      end
    rescue MediaFile::InvalidFileError => e
      stdout.puts "#{path}: #{e.message}"
      @failed = true
    end
  end

  def doctor(args)
    parse_options!(args, "doctor", "Check that the programs the library runs are installed, and that the sandbox works.")

    versions = MediaFile.dependency_versions
    versions.each { |name, version| stdout.puts "#{name}: #{version || "not installed"}" }

    landlock = MediaFile::Landlock.supported?
    stdout.puts "landlock: #{landlock ? "supported (ABI version #{MediaFile::Landlock.abi_version})" : "not supported"}"
    stdout.puts "sandbox: #{MediaFile.config.sandbox ? "enabled" : "disabled"}"
    stdout.puts "The sandbox needs Landlock. Set MEDIA_FILE_DISABLE_SANDBOX=true to run without it." if MediaFile.config.sandbox && !landlock

    @failed = true unless versions.values.all? && (landlock || !MediaFile.config.sandbox)
  end
end

require_relative "cli/analyze"
