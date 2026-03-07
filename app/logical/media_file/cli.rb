# frozen_string_literal: true

require "find"
require "etc"
require "optparse"

# A command-line tool like `ls` or `exiftool`, but for listing properties of media files. See bin/media-ls for the tool
# that uses this class.
#
# Usage: `bin/media-ls [options] [FILE|DIR ...]`
class MediaFile::CLI
  # The list of columns that can be displayed. Each column corresponds to a method on MediaFile, or a special case handled in Entry#value_for_column.
  AVAILABLE_COLUMNS = %w[
    type dir permissions user group size mtime dimensions mpixels width height duration video_codec audio_codec codecs
    pix_fmt video_bit_rate audio_bit_rate video_streams audio_streams silence_duration silence_percentage
    average_loudness peak_loudness loudness_range frame_count frame_rate mime_type md5 pixel_hash has_audio is_corrupt
    error dirname path name metadata
  ]

  attr_reader :columns, :groups, :colors, :sort_specs, :options

  # Initialize default options. The actual options are populated by `parse_options!` when `run!` is called.
  def initialize(*argv, env: ENV, stdout: $stdout, stderr: $stderr)
    @argv = argv.dup
    @env = env
    @stdout = stdout
    @stderr = stderr
    @paths = []
    @columns = []
    @format = "table"
    @groups = []
    @sort_specs = {}
    @colors = {}

    @options = {
      columns: [],
      group: %w[dirname],
      color: "auto",
      detailed: false,
      human_readable: false,
      json: false,
      long: false,
      precision: 1,
      recursive: false,
      sort: { "dir" => -1, "name" => 1 },
      units: "iec",
    }
  end

  def self.run!(...)
    new(...).run!
  end

  # @return [Boolean] Runs the CLI and returns true if the command succeeded, false if it failed with an error.
  def run!
    parse_options!

    case @format
    when "table"
      render_table
    when "detailed"
      render_detailed
    when "json"
      render_json
    end

    true
  rescue Errno::EPIPE
    true # Ignore EPIPE errors when the output is piped to a command like `head` that closes the pipe early.
  rescue SystemExit => e
    e.success?
  rescue StandardError => e
    @stderr.puts e.message
    false
  end

  # Parse the command-line options. Raise an exceptions if the options are invalid.
  def parse_options!
    OptionParser.new do |opts|
      program_name = File.basename($PROGRAM_NAME)
      terminal_width = @env.fetch("COLUMNS", 80).to_i

      opts.banner = <<~EOS
        #{program_name} - List properties of media files

        Usage: #{program_name} [options] [FILE|DIR ...]
      EOS

      # --columns=type,size,dimensions -> ["type", "size", "dimensions"]
      opts.accept(:columns) do |value|
        columns = value.split(",")
        invalid = columns - AVAILABLE_COLUMNS

        raise "invalid columns: #{invalid.join(", ")}" if invalid.present?
        columns
      end

      # --sort=dir:desc,type:asc,name -> { "dir" => -1, "type" => 1, "name" => 1 }
      opts.accept(:sort) do |value|
        value.scan(/([^,:]+)(?::(asc|desc))?/).to_h do |column, direction|
          raise "invalid sort option: #{column}:#{direction}" unless column.in?(AVAILABLE_COLUMNS) && direction.in?(["asc", "desc", nil])
          [column, (direction == "desc") ? -1 : 1]
        end
      end

      opts.separator ""
      opts.on("-d", "--detailed", "Detailed exiftool-like output")
      opts.on("-j", "--json", "JSON output")
      opts.on("-l", "--long", "`ls --long`-like output")
      opts.on("-R", "--recursive", "Recurse into directories")
      opts.on("-h", "--human-readable", "Print sizes in human-readable format") { @options[:human_readable] = true }
      opts.on("-u", "--units=UNITS", %w[iec si], "Units for -h output (iec: 1KiB=1024B, si: 1KB=1000B)")
      opts.on("-p", "--precision=N", Integer, "Digits after decimal point (default: #{@options[:precision]})")
      opts.on("--color=WHEN", %w[auto always never], "When to colorize output (auto, always, never). Default: #{@options[:color]}")
      opts.on("-c", "--columns=COL[,...]", :columns, "Select output columns (default: #{default_columns.join(",")})")
      opts.on("-g", "--group=COL[,...]", :columns, "Group output by column(s) (default: #{@options[:group].join(",")})")
      opts.on("-s", "--sort=COL[:asc|:desc]", :sort, "Sort output by column(s) (default: dir:desc,name:asc)")

      opts.on("--help", "Show this help message") do
        @stdout.puts opts
        raise SystemExit
      end

      opts.separator ""
      opts.separator "Supported output columns:"
      opts.separator AVAILABLE_COLUMNS.join(", ").scan(/.{1,#{terminal_width - 4}}(?:, |$)/).join("\n").indent(4)

      opts.parse!(@argv, into: @options)
    end

    @paths = @argv.presence || [Dir.pwd]
    @columns = @options[:columns].presence || default_columns
    @groups = @options[:group]
    @sort_specs = @options[:sort]

    if @options[:json]
      @format = "json"
    elsif @options[:detailed]
      @format = "detailed"
    else
      @format = "table"
    end

    case @options[:color]
    when "always"
      @colors = ls_colors
    when "never", "none"
      @colors = {}
    when "auto"
      @colors = ls_colors if @stdout.tty? && @env["NO_COLOR"].blank?
    else
      raise "invalid color option: #{@options[:color]}"
    end
  end

  # @return [Array<Entry>] The list of file Entry objects representing the files to be listed.
  def entries
    @entries ||= expanded_paths.map do |path|
      Entry.new(path: path, cli: self)
    end
  end

  # @return [Hash<String, Array<Entry>>] The file entries after being grouped and sorted.
  def grouped_entries
    @grouped_entries ||= entries.group_by { |entry| entry.attributes.values_at(*groups) }.transform_values(&:sort).sort_by(&:first).to_h
  end

  # @return [Array<String>] The list of file paths to process, after expanding directories if necessary.
  def expanded_paths
    @expanded_paths ||= @paths.flat_map do |path|
      if !File.exist?(path)
        raise "#{path.inspect}: no such file or directory"
      elsif File.directory?(path) && @options[:recursive]
        Find.find(path).reject { |entry| entry == path }
      elsif File.directory?(path)
        Dir.children(path).map { |child| File.join(path, child) }
      else
        [File.expand_path(path)]
      end
    end
  end

  # @return [Array<String>] The default columns to display when no --columns option is given.
  def default_columns
    if @options[:long]
      %w[permissions user group size mtime name]
    elsif @options[:detailed]
      (AVAILABLE_COLUMNS - %w[dir])
    else
      %w[type size dimensions duration name]
    end
  end

  # Render the output in tabular ls-like format.
  def render_table
    grouped_entries.each do |group_key, entries|
      @stdout.puts if group_key != grouped_entries.keys.first
      @stdout.puts "#{group_key.join(", ")}:" if grouped_entries.keys.size > 1

      column_widths = @columns.map do |column|
        max_width = entries.map { |entry| entry.format_value(column).length }.max.clamp(column.length..)
        justification = (column == @columns.last) ? :ljust : :rjust
        [column, max_width, justification]
      end

      header = column_widths.map do |column, width, justification|
        column.titleize.upcase.send(justification, width)
      end.join("  ")
      @stdout.puts header

      entries.each do |entry|
        values = column_widths.map do |column, width, justification|
          entry.colorize_value(column).send(justification, width)
        end

        @stdout.puts values.join("  ")
      end
    end
  end

  # Render the output in vertical exiftool-like format, with one key-value pair per line.
  def render_detailed
    grouped_entries.each do |group_key, entries|
      @stdout.puts if group_key != grouped_entries.keys.first
      @stdout.puts "#{group_key.join(", ")}:" if grouped_entries.keys.size > 1

      entries.each do |entry|
        @stdout.puts "======== #{entry.path}"

        # Output the metadata hash last.
        sorted_columns = @columns.sort_by { |key| entry.attributes[key].is_a?(Hash) ? 1 : 0 }

        # Flatten the nested metadata hash into `"Key:Subkey" => value` format
        pairs = sorted_columns.flat_map do |key|
          value = entry.attributes[key]

          if value.is_a?(Hash)
            value.map { |sub_key, sub_value| ["#{key.titleize}:#{sub_key.titleize}", sub_value] }
          else
            [[key.titleize, entry.format_value(key)]]
          end
        end.to_h

        # Align the keys by padding them to the same width, and print the key-value pairs.
        width = pairs.keys.map(&:length).max
        pairs.each do |key, value|
          @stdout.puts format("%-#{width}s : %s", key, value)
        end
      end
    end
  end

  # Render the output in JSON format.
  def render_json
    json = entries.map(&:as_json)
    @stdout.puts JSON.pretty_generate(json)
  end

  # @return [Hash<String, String>] The mapping of file patterns to ANSI color codes
  def ls_colors
    # LS_COLORS="*.mkv=01;35:*.webm=01;35"
    @ls_colors ||= @env["LS_COLORS"].to_s.scan(/([^:=]*)=([^:=]*)/).to_h
  end

  # An Entry represents a single file or directory. It collects the attributes for the requested columns and provides
  # methods for formatting and sorting entries.
  class Entry
    attr_reader :path, :attributes

    # @param path [String] File or directory path to inspect.
    # @param cli [MediaFile::CLI] The CLI instance, used to access options and column specifications.
    def initialize(path:, cli:)
      @path = path
      @media = nil

      @columns = cli.columns
      @groups = cli.groups
      @sort_specs = cli.sort_specs
      @colors = cli.colors
      @units = cli.options[:units]
      @precision = cli.options[:precision]
      @human_readable = cli.options[:human_readable]

      # Preload the column values so we can close the file as soon as we've calculated all the requested columns.
      @attributes = (@columns | @sort_specs.keys | @groups).index_with do |column|
        value_for_column(column)
      end

      @media&.close
    end

    # @return [MediaFile, nil] The MediaFile object for this entry, or nil if it's a not a regular file (a directory, device file, etc).
    def media
      @media ||= MediaFile.open(@path) if File.file?(@path)
    end

    # @return [Object] The value of the named output column.
    def value_for_column(column)
      case column
      when "path"
        @path
      when "dir"
        stat.directory?
      when "dirname"
        File.dirname(@path)
      when "name"
        File.basename(@path)
      when "permissions"
        format_permissions
      when "user"
        Etc.getpwuid(stat.uid).name rescue stat.uid.to_s
      when "group"
        Etc.getgrgid(stat.gid).name rescue stat.gid.to_s
      when "size"
        stat.size
      when "mtime"
        stat.mtime
      when "type"
        media&.file_ext&.to_s || "dir"
      when "dimensions"
        "#{media.width} x #{media.height}" if media&.width.to_i > 0 && media&.height.to_i > 0
      when "mpixels"
        (media.width * media.height) / 1_000_000.0 if media&.width.to_i > 0 && media&.height.to_i > 0
      when "video_streams", "audio_streams"
        media.try(column)&.size
      when "codecs"
        [media.try(:video_codec), media.try(:audio_codec)].compact_blank.join(",").presence
      when "has_audio"
        media&.has_audio?
      when "is_corrupt"
        media&.is_corrupt?
      when "metadata"
        media&.metadata.to_h
      else
        media.try(column)
      end
    end

    # @return [String] The formatted and colorized value of the column.
    def colorize_value(column)
      text = format_value(column)
      return text unless @colors.present? && column.in?(%w[name path])

      if stat.directory?
        color_code = @colors["di"]
      elsif stat.file? && stat.executable?
        color_code = @colors["ex"]
      elsif File.symlink?(@path)
        color_code = @colors["ln"]
      else
        color_code = @colors["*#{File.extname(@path)}"] || @colors["fi"]
      end

      "\e[#{color_code || "0"}m#{text}\e[0m"
    end

    # @return [String] The formatted value of the column.
    def format_value(column)
      value = @attributes[column]

      if column == "size" && @human_readable && value.present?
        format_human_size(value)
      elsif column == "duration" && @human_readable && value.present?
        format_duration(value)
      elsif value.is_a?(Float)
        format("%.#{@precision}f", value)
      elsif value.is_a?(Hash) || value.is_a?(Array)
        value.to_json
      elsif value.is_a?(Time)
        value.utc.iso8601
      else
        value.to_s
      end
    end

    # @return [String] The file permissions formatted like "drwxr-xr-x".
    def format_permissions
      type = { file: "-", directory: "d", link: "l", characterSpecial: "c", blockSpecial: "b", socket: "s", fifo: "p" }[stat.ftype.to_sym]

      perms = [0o400, 0o200, 0o100, 0o040, 0o020, 0o010, 0o004, 0o002, 0o001].zip("rwxrwxrwx".chars).map do |bit, char|
        (stat.mode & bit == 0) ? "-" : char
      end

      "#{type}#{perms.join}"
    end

    # @return [String] The file size formatted like "1.5 MiB" or "1.5 MB"
    def format_human_size(value)
      if @units == "si"
        base, labels = 1000.0, %w[KB MB GB TB PB]
      else
        base, labels = 1024.0, %w[KiB MiB GiB TiB PiB]
      end

      begin
        value /= base
        unit = labels.shift
      end until value < base || unit.nil?

      "#{format("%.#{@precision}f", value)} #{unit}"
    end

    # @return [String] The duration formatted like "0:12" or "0:12.34".
    def format_duration(seconds)
      minutes, remaining_seconds = seconds.to_f.round(@precision).divmod(60)

      if @precision.zero?
        format("%d:%02d", minutes, remaining_seconds.round)
      else
        total_width = 2 + 1 + @precision
        second_text = format("%0#{total_width}.#{@precision}f", remaining_seconds)
        format("%d:%s", minutes, second_text)
      end
    end

    # Compare entries for sorting based on the columns selected by the --sort option.
    # @return [Integer] -1 if this entry comes before the other entry, 1 if it comes after, or 0 if they are equal.
    def <=>(other)
      @sort_specs.map do |column, direction|
        (sort_key(column) <=> other.sort_key(column)) * direction
      end.find(&:nonzero?) || 0
    end

    # @return [Object] The value of the column, normalized for sorting (e.g. booleans converted to integers).
    def sort_key(column)
      value = @attributes[column]
      case value when true then 1 when false then 0 else value end
    end

    # @return [File::Stat] The permissions/size/ownership/etc information for the file.
    def stat
      @stat ||= File.stat(@path)
    end

    # @return [Hash<String, Object>] The (column, value) hash for JSON output.
    def as_json
      @attributes.slice(*@columns)
    end
  end
end
