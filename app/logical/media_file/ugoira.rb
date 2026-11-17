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
      @zip_info = nil
      @tmpdir = nil
    end
  end

  # @return [String, nil] Return the error message if the ugoira is invalid, or nil if it is valid.
  memoize def error
    return zip_error if zip_error.present?
    return "number of files is inconsistent with animation.json" if animation_json.present? && files.size != animation_json_frames.size + 1
    return "unrecognized animation.json format" if animation_json_format == "unknown"

    names = zip_info["names"]
    animation_json_frames.each_with_index do |json, i|
      if names.present?
        # skip animation.json if it's the first entry in the zip file
        name = (names.first == "animation.json") ? names[i + 1] : names[i]
        return "'#{json["file"]}' in animation.json doesn't match '#{name}' in zip file" if json["file"] != name
      end

      return "'#{json["file"]}' in animation.json has invalid delay" if !json["delay"].in?(MIN_DELAY..MAX_DELAY)
    end

    return "must have at least two frames" if frames.size < 2
    return "frames must have the same file type" if frames.map(&:file_ext).uniq.size > 1

    # Check the dimensions before decoding the frames, so that a frame can't be larger than the first frame (whose size is
    # checked by `MediaAsset.validate_media_file!`).
    return "frames must have the same dimensions" if frames.map(&:dimensions).uniq.size > 1

    frames.each do |frame|
      return "file '#{File.basename(frame.path)}' is animated" if frame.is_animated?
      return "file '#{File.basename(frame.path)}' is corrupt" if frame.is_corrupt?
    end

    nil
  end

  # Check the structure of the .zip file, and extract it if it's valid. This is done in one call to bin/archive in the
  # sandbox. See `ArchiveCommand.ugoira` in bin/archive for the checks.
  #
  # @return [Hash] The error if the ugoira is invalid, or the names of the files in the .zip, the frame offsets, and the
  #   paths of the extracted files. Empty if the ugoira isn't a .zip file.
  def zip_info
    synchronize do
      @zip_info ||= if file.nil?
        {}
      else
        result = Danbooru::Archive.run!("ugoira", file.path, tmpdir.path, read: [file.path], write: [tmpdir.path])
        verify_zip_info!(result) if result["error"].nil?
        result
      end
    rescue Danbooru::Archive::Error
      @zip_info = { "error" => "invalid zip file" }
    end
  end

  # Check the output of bin/archive, in case it was compromised by a malicious file. The files must be inside the
  # temp directory, and the names and frame offsets must match them.
  #
  # @raise [Danbooru::Archive::Error] If the output is invalid.
  def verify_zip_info!(result)
    files = Danbooru::Archive.verify_extracted_files!(result["files"], tmpdir.path)
    names = result["names"]
    frame_offsets = result["frame_offsets"]

    raise Danbooru::Archive::Error unless names == files.map { File.basename(it) }
    raise Danbooru::Archive::Error unless frame_offsets.is_a?(Array) && frame_offsets.all? { it.is_a?(Integer) && it.between?(0, file.size) } && frame_offsets.size == (names - ["animation.json"]).size
  end

  # @return [String, nil] Return the error message if the .zip file is invalid, or nil if it is valid.
  def zip_error
    zip_info["error"]
  end

  def file_ext
    :zip # XXX Should return :ugoira in the future.
  end

  # @return [Mime::Type] The MIME type of the ugoira.
  def mime_type
    Mime::Type.lookup("video/x-ugoira")
  end

  # @return [Mime::Type, nil] The MIME type of the frames in the ugoira (image/jpeg, image/png, or image/gif).
  memoize def frame_mime_type
    frames.first&.mime_type
  end

  # @return [ExifTool::Metadata] The metadata for the file.
  memoize def metadata
    data = super.reject { |key, _value| key.starts_with?("ZIP:") }

    data.merge(
      "Ugoira:FrameDelays" => frame_delays,
      "Ugoira:FrameOffsets" => frame_offsets,
      "Ugoira:FrameCount" => frame_delays.size,
      "Ugoira:FrameRate" => frame_rate,
      "Ugoira:FrameMimeType" => frame_mime_type.to_s,
      "Ugoira:AnimationJsonFormat" => animation_json_format,
    )
  end

  # @return [Array<Integer>] The list of offsets to each frame in the .zip file. Used by the ugoira player to locate
  #   frames without needing to parse the zip file first.
  def frame_offsets
    zip_info["frame_offsets"]
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
    in { ugokuIllustData: { frames: Array => frames }}
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
    in { ugokuIllustData: { frames: Array }} if animation_json_frames.all? { |frame| frame in { file: String, delay: Integer, **nil } }
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
      raise Error, zip_error if zip_error.present?

      @files ||= zip_info["files"].map { |filename| File.open(filename) }
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
  def self.create(frames, frame_delays:, mtime: Time.utc(1980, 1, 1), data: {})
    new(frames, frame_delays:).create_copy(data:, mtime:)
  end

  # Create a copy of the current ugoira, with a new animation.json file added to it.
  #
  # @param file [File] The output file to write the new ugoira to.
  # @param mtime [Time] The timestamp to set on the files in the zip file.
  # @param data [Hash] Extra data to include in the animation.json file.
  # @return [MediaFile] The new ugoira.
  def create_copy(file: Danbooru::Tempfile.new(%w[danbooru-ugoira- .zip]), mtime: Time.utc(1980, 1, 1), data: {})
    animation_meta = {
      **data,
      width: width,
      height: height,
      mime_type: frames.first&.mime_type.to_s,
      frames: frames.map.with_index do |frame, n|
        { file: "#{"%06d" % n}.#{frame.file_ext}", delay: frame_delays[n], md5: frame.md5 }
      end,
    }

    Danbooru::Tempdir.create(["danbooru-ugoira-"]) do |tmpdir|
      zip_path = "#{tmpdir.path}/ugoira.zip"
      animation_json_path = "#{tmpdir.path}/animation.json"
      File.write(animation_json_path, animation_meta.to_json)

      entries = frames.map.with_index { |frame, n| ["#{"%06d" % n}.#{frame.file_ext}", frame.path] }
      entries << ["animation.json", animation_json_path]

      # The frames are copied into the zip without being parsed, so the output isn't limited to the max upload size.
      Danbooru::Archive.run!("create-ugoira", zip_path, mtime.strftime("%Y-%m-%dT%H:%M:%S"), *entries.flatten, read: entries.map(&:second), write: [tmpdir.path], file_size_limit: nil)
      FileUtils.mv(zip_path, file.path)
    end

    file.reopen(file, "rb")
    MediaFile::Ugoira.new(file)
  end

  # Convert a ugoira to a video. See `FFmpeg.encode_images!` for the encoding options.
  #
  # @param format [Symbol] The video container format (:webm, :mkv, or :mp4). Default: :webm.
  # @param output_file [File] The file to write the video to.
  # @return [MediaFile] The video.
  def convert(format: :webm, output_file: Danbooru::Tempfile.new(["danbooru-ugoira-conversion-#{File.basename(file&.path.to_s)}", ".#{format}"], binmode: true), **options)
    synchronize do
      raise NotImplementedError, "can't convert ugoira to video: ffmpeg or mkvmerge not installed" unless self.class.videos_enabled?
      raise "can't convert ugoira to video: no ugoira frame data was provided" unless frame_delays.present?

      FFmpeg.encode_images!(frames, frame_delays, output_file.path, format:, **options)
      MediaFile.open(output_file)
    end
  rescue StandardError
    output_file.close
    raise
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
