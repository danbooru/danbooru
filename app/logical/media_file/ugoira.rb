# frozen_string_literal: true

# A MediaFile for a Pixiv ugoira file.
#
# A ugoira is an animation format that consists of a zip file containing JPEG or PNG images, one per frame, plus a JSON
# object containing the inter-frame delay timings. Each frame can have a different delay, therefore ugoiras can have a
# variable framerate.
#
# The frame data isn't stored inside the zip file in ugoiras created by Pixiv, so it must be passed around separately.
# Some tools like gallery-dl, PixivUtil2, and PixivToolkit can store the frame data in an animation.json file inside the
# zip file. The exact format of this file varies slightly between tools. This supports them all.
#
# @see https://www.pixiv.help/hc/en-us/articles/235584628-What-are-Ugoira
# @see https://github.com/pixiv/zip_player (Pixiv's Javascript ugoira player)
# @see https://marcan.st/talks/2014_pixiv_ugoku_player/
class MediaFile::Ugoira < MediaFile
  class Error < StandardError; end

  MIN_DELAY = 10 # The mininum delay allowed for a single frame in a ugoira. 10ms is the minimum on Pixiv.
  MAX_DELAY = 30_000 # The maximum delay allowed for a single frame in a ugoira. 30s is the max on Pixiv.
  MAX_FRAME_COUNT = 500 # The maximum number of frames allowed in a ugoira. 500 is the max on Pixiv.
  MAX_ANIMATION_JSON_SIZE = 50.kilobytes # The maximum size of the animation.json file. This is enough for 500 frames + extra.

  # @return [Concurrent::ReentrantReadWriteLock] A lock to make sure we don't extract the .zip file more than once when
  #   called from multiple threads (such as during upload when generating samples in parallel).
  attr_reader :lock

  # Open a ugoira. The ugoira can be a .zip file or an unpacked array of files. One of the files may be an
  # animation.json file containing the frame delays, or the delays can be passed in separately.
  #
  # @param file_or_files [File, Array<File>, Array<String>] The .zip file, or an array of files or filenames.
  # @param frame_delays [Array<Integer>] The frame delays in milliseconds.
  def initialize(file_or_files, frame_delays: nil, **options)
    @lock = Concurrent::ReentrantReadWriteLock.new
    @frame_delays = frame_delays

    if file_or_files.respond_to?(:path)
      super(file_or_files, **options)
      @files = nil
    elsif file_or_files.respond_to?(:to_a)
      @files = file_or_files.to_a.map { |file| file.respond_to?(:path) ? file : File.open(file) }
    else
      raise ArgumentError, "expected a file or an array of files"
    end
  end

  # Close the ugoira and delete all extracted files. The caller should call this when done with the ugoira, otherwise
  # there may be a long delay before the object is garbage collected and the files are deleted.
  def close
    synchronize do
      super
      @preview_frame&.close
      @frames&.each(&:close)
      @files&.each(&:close)
      @tmpdir&.close
      @preview_frame = nil
      @frames = nil
      @files = nil
      @tmpdir = nil
    end
  end

  # @return [String, nil] Return the error message if the ugoira is invalid, or nil if it is valid.
  memoize def error
    zip = Zip::File.open(file.path)
    stream = Zip::InputStream.open(file.path)
    file_n = 0
    frame_n = 0

    while (entry = stream.get_next_entry)
      if entry.name == "animation.json"
        return "animation.json file must come first or last" if file_n != 0 && file_n + 1 != zip.size
        return "animation.json file is too large" if entry.size > MAX_ANIMATION_JSON_SIZE
      else
        return "cannot have more than #{MAX_FRAME_COUNT} frames" if frame_n + 1 > MAX_FRAME_COUNT

        if !entry.name.match?(/\A#{"%06d" % frame_n}\.(jpg|png|gif)\z/)
          return "file '#{entry.name}' has invalid name (expected '#{"%06d" % frame_n}#{File.extname(entry.name)}')"
        end
      end

      return "file '#{entry.name}' cannot have comments" if entry.comment_size > 0
      return "file '#{entry.name}' cannot have extra fields (fields: #{entry.extra.keys.join(", ")})" if entry.extra_size > 0
      return "file '#{entry.name}' cannot be compressed" if entry.compression_method != Zip::Entry::STORED
      return "file '#{entry.name}' cannot be compressed" if entry.compressed_size != entry.size
      return "file '#{entry.name}' cannot be a #{entry.ftype}" if entry.ftype != :file
      return "file '#{entry.name}' has unsupported general purpose flags (#{"%.8b" % entry.gp_flags})" if entry.gp_flags != 0
      return "file '#{entry.name}' has unsupported header size (expected #{entry.name.size + 30}, got #{entry.calculate_local_header_size})" if entry.calculate_local_header_size != entry.name.size + 30
      # return "file '#{entry.name}' has invalid CRC" if entry.crc != Zlib.crc32(entry.get_input_stream.read) # XXX this reads the entire file into memory

      %i[crc name extra_size comment_size ftype compression_method compressed_size size].each do |field|
        if entry.send(field) != zip.entries[file_n].send(field)
          return "field '#{field}' in file '#{entry.name}' is inconsistent with central directory"
        end
      end

      file_n += 1
      frame_n += 1 unless entry.name == "animation.json"
    end

    return "number of files is inconsistent with end-of-central-directory count" if file_n != zip.size
    return "number of files is inconsistent with central directory count" if file_n != zip.entries.size
    return "number of files is inconsistent with animation.json" if animation_json.present? && file_n != animation_json_frames.size + 1
    return "unrecognized animation.json format" if animation_json_format == "unknown"

    animation_json_frames.each_with_index do |json, i|
      # skip animation.json if it's the first entry in the zip file
      entry = (zip.entries.first.name == "animation.json") ? zip.entries[i + 1] : zip.entries[i]

      return "'#{json["file"]}' in animation.json doesn't match '#{entry.name}' in zip file" if json["file"] != entry.name
      return "'#{json["file"]}' in animation.json has invalid delay" if !json["delay"].in?(MIN_DELAY..MAX_DELAY)
    end

    frames.each do |frame|
      return "file '#{File.basename(frame.path)}' is not an image file" if !frame.file_ext.in?(%i[jpg gif png])
      return "file '#{File.basename(frame.path)}' is animated" if frame.is_animated?
      return "file '#{File.basename(frame.path)}' is corrupt" if frame.is_corrupt?
    end

    return "must have at least two frames" if frames.size < 2
    return "frames must have the same dimensions" if frames.map(&:dimensions).uniq.size > 1
    return "frames must have the same file type" if frames.map(&:file_ext).uniq.size > 1

    nil
  ensure
    zip&.close rescue nil # work around for https://github.com/rubyzip/rubyzip/issues/216; triggered by files with UniversalTime extra field
    stream&.close
  end

  def file_ext
    :zip # XXX Should return :ugoira in the future.
  end

  # @return [Mime::Type] The MIME type of the ugoira.
  def mime_type
    Mime::Type.lookup("video/x-ugoira")
  end

  # @return [ExifTool::Metadata] The metadata for the file.
  memoize def metadata
    data = super.reject { |key, value| key.starts_with?("ZIP:") }

    data.merge(
      "Ugoira:FrameDelays" => frame_delays,
      "Ugoira:FrameOffsets" => frame_offsets,
      "Ugoira:FrameCount" => frame_delays.size,
      "Ugoira:FrameRate" => frame_rate,
      "Ugoira:FrameMimeType" => frames.first&.mime_type.to_s,
      "Ugoira:AnimationJsonFormat" => animation_json_format
    )
  end

  # @return [Array<Integer>] The list of offsets to each frame in the .zip file. Used by the ugoira player to locate
  #   frames without needing to parse the zip file first.
  memoize def frame_offsets
    Zip::File.open(file.path) do |zip|
      zip.entries.reject { |entry| entry.name == "animation.json" }.map(&:local_header_offset)
    end
  end

  memoize def dimensions
    frames.first.dimensions
  end

  def preview!(width, height, **options)
    preview_frame.preview!(width, height, **options)
  end

  def duration
    (frame_delays.sum / 1000.0)
  end

  def frame_count
    frame_delays.count
  end

  # @return [Float] The frame rate of the ugoira. If the ugoira has a variable framerate, this will be the average framerate.
  def frame_rate
    frame_count / duration
  end

  # @return [Array<Integer>] The list of frame delays in milliseconds.
  def frame_delays
    @frame_delays ||= animation_json_frames.pluck("delay")
  end

  # @return [String] The pixel hash of the ugoira.
  memoize def pixel_hash
    data = {
      frames: frames.map.with_index do |frame, i|
        { pixel_hash: frame.pixel_hash, duration: frame_delays[i] }
      end,
    }

    Digest::MD5.hexdigest(data.to_json)
  end

  # @return [Array<Hash>, nil] The 'frames' array from the animation.json file, if present.
  memoize def animation_json_frames
    case animation_json
    in Array => frames
      frames.map(&:with_indifferent_access)
    in { frames: Array => frames }
      frames.map(&:with_indifferent_access)
    in { ugokuIllustData: { frames: Array => frames } }
      frames.map(&:with_indifferent_access)
    else
      []
    end
  end

  # @return [String] The format of the animation.json file.
  def animation_json_format
    case animation_json
    # [{ "file": "000001.jpg", "delay": 100 }]
    in Array if animation_json_frames.all? { |frame| frame in { file: String, delay: Integer, **nil } }
      "gallery-dl"
    # { "frames": [{ "file": "000001.jpg", "delay": 100, md5: "..." }] }
    in { frames: Array } if animation_json_frames.all? { |frame| frame in { file: String, delay: Integer, md5: String, **nil } }
      "Danbooru"
    # { "frames": [{ "file": "000001.jpg", "delay": 100 }] }
    in { frames: Array } if animation_json_frames.all? { |frame| frame in { file: String, delay: Integer, **nil } }
      "PixivUtil2"
    # { "ugokuIllustData": { "frames": [{ "file": "000001.jpg", "delay": 100 }] } }
    in { ugokuIllustData: { frames: Array } } if animation_json_frames.all? { |frame| frame in { file: String, delay: Integer, **nil } }
      "PixivToolkit"
    # No animation.json file
    in nil
      "none"
    else
      "unknown"
    end
  end

  # @return [Hash, Array, nil] The contents of the animation.json file, if present. May be in gallery-dl, PixivUtil2, or PixivTookit format.
  def animation_json
    synchronize do
      @animation_json ||= files.find { |file| file.path.ends_with?(".json") }&.read&.parse_json
    end
  end

  # @return [Array<MediaFile>] The list of images in the ugoira.
  def frames
    synchronize do
      @frames ||= files.filter_map { |file| MediaFile.open(file) unless file.path.ends_with?(".json") }
    end
  end

  # @return [Array<File>] The list of all files in the ugoira, including the animation.json file containing the frame
  #   delays and metadata (if present).
  def files
    synchronize do
      @files ||= Danbooru::Archive.extract!(file, tmpdir.path).second.map { |filename| File.open(filename) }
    end
  end

  # @return [String] The path to the temporary directory where the ugoira was extracted.
  def tmpdir
    synchronize do
      @tmpdir ||= Danbooru::Tempdir.create(["danbooru-ugoira-", "-#{File.basename(file&.path.to_s)}"])
    end
  end

  # Create a new ugoira from the given images and frame delays.
  #
  # @param frames [Array<MediaFile>] The list of images to include in the ugoira, in the order they should be displayed.
  # @param frame_delays [Array<Integer>] The frame delays in milliseconds.
  # @param mtime [Time] The timestamp to set on the files in the zip file.
  # @param data [Hash] Extra data to include in the animation.json file.
  # @return [MediaFile] The new ugoira.
  def self.create(frames, frame_delays:, mtime: Time.new(1980, 1, 1), data: {})
    new(frames, frame_delays:).create_copy(data:, mtime:)
  end

  # Create a copy of the current ugoira, with a new animation.json file added to it.
  #
  # @param file [File] The output file to write the new ugoira to.
  # @param mtime [Time] The timestamp to set on the files in the zip file.
  # @param data [Hash] Extra data to include in the animation.json file.
  # @return [MediaFile] The new ugoira.
  def create_copy(file: Danbooru::Tempfile.new(%w[danbooru-ugoira- .zip]), mtime: Time.new(1980, 1, 1), data: {})
    ziptime = Zip::DOSTime.new(mtime.year, mtime.month, mtime.day, mtime.hour, mtime.min, mtime.sec)

    animation_meta = {
      **data,
      width: width,
      height: height,
      mime_type: frames.first&.mime_type.to_s,
      frames: frames.map.with_index do |frame, n|
        { file: "#{"%06d" % n}.#{frame.file_ext}", delay: frame_delays[n], md5: frame.md5 }
      end,
    }

    # XXX Use rubyzip because libarchive adds some things to the zip that we don't want (extra UniversalTime fields for
    # timestamps and CRCs after the file data).
    Danbooru::Tempfile.create do |animation_json_file|
      Zip::File.open(file, create: true) do |zip|
        entries = frames.map.with_index do |frame, n|
          [Zip::Entry.new(zip, "#{"%06d" % n}.#{frame.file_ext}"), frame]
        end

        animation_json_file.pwrite(animation_meta.to_json, 0)
        entries << [Zip::Entry.new(zip, "animation.json"), animation_json_file]

        entries.each do |entry, filepath|
          zip.add(entry, filepath)

          entry.compression_method = Zip::Entry::STORED
          entry.unix_perms = 0o0644
          entry.internal_file_attributes = 0 # 0 for binary filetype, 1 for text
          entry.instance_variable_set(:@time, ziptime) # set manually to avoid rubyzip creating UniversalTime extra field
        end
      end
    end

    # XXX rubyzip writes to a different file then moves it on top of the file we passed in, so we need to reopen our file to get the new file.
    file.reopen(file, "rb")
    MediaFile::Ugoira.new(file)
  end

  # Convert a ugoira to a webm.
  # XXX should take width and height and resize image
  def convert
    synchronize do
      @convert ||= begin
        raise NotImplementedError, "can't convert ugoira to webm: ffmpeg or mkvmerge not installed" unless self.class.videos_enabled?
        raise RuntimeError, "can't convert ugoira to webm: no ugoira frame data was provided" unless frame_delays.present?

        output_file = Danbooru::Tempfile.new(["danbooru-ugoira-conversion-", "-#{File.basename(file&.path.to_s)}"], binmode: true)
        tmpdir_path = tmpdir.path

        # Duplicate last frame to avoid it being displayed only for a very short amount of time.
        last_file_name = File.basename(frames.last.path)
        last_index, file_ext = last_file_name.split(".")
        new_last_filename = "#{"%06d" % (last_index.to_i + 1)}.#{file_ext}"
        path_from = File.join(tmpdir_path, last_file_name)
        path_to = File.join(tmpdir_path, new_last_filename)
        FileUtils.cp(path_from, path_to)

        delay_sum = 0
        timecodes_path = File.join(tmpdir_path, "timecodes.tc")
        File.open(timecodes_path, "w+") do |f|
          f.write("# timecode format v2\n")
          frame_delays.each do |delay|
            f.write("#{delay_sum}\n")
            delay_sum += delay
          end
          f.write("#{delay_sum}\n")
          f.write("#{delay_sum}\n")
        end

        ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir_path}/%06d.#{file_ext} -codec:v libvpx-vp9 -crf 12 -b:v 0 -an -threads 8 -tile-columns 2 -tile-rows 1 -row-mt 1 -pass 1 -passlogfile #{tmpdir_path}/ffmpeg2pass -f null /dev/null")
        raise Error, "ffmpeg failed: #{ffmpeg_out}" unless status.success?

        ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir_path}/%06d.#{file_ext} -codec:v libvpx-vp9 -crf 12 -b:v 0 -an -threads 8 -tile-columns 2 -tile-rows 1 -row-mt 1 -pass 2 -passlogfile #{tmpdir_path}/ffmpeg2pass #{tmpdir_path}/tmp.webm")
        raise Error, "ffmpeg failed: #{ffmpeg_out}" unless status.success?

        mkvmerge_out, status = Open3.capture2e("mkvmerge -o #{output_file.path} --webm --timecodes 0:#{tmpdir_path}/timecodes.tc #{tmpdir_path}/tmp.webm")
        raise Error, "mkvmerge failed: #{mkvmerge_out}" unless status.success?

        MediaFile.open(output_file)
      end
    end
  end

  private

  def preview_frame
    synchronize do
      @preview_frame ||= FFmpeg.new(convert).smart_video_preview!
    end
  end

  def synchronize(&block)
    lock.with_write_lock(&block)
  end
end
