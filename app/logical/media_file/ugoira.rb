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

  # @return [ExifTool::Metadata] The metadata for the file.
  memoize def metadata
    super.merge("Ugoira:FrameDelays" => frame_delays)
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

  # @return [Array<Integer>] The list of frame delays in milliseconds. Frame delays are taken from either the delays
  #   passed in to the constructor, or from the animation.json file.
  def frame_delays
    @frame_delays ||=
      case animation_json
      # gallery-dl format: [{ "file": "000001.jpg", "delay": 100 }]
      in Array => frames
        frames.pluck("delay").compact_blank
      # PixivUtil2 format: { "frames": [{ "file": "000001.jpg", "delay": 100 }] }
      in { frames: frames }
        frames.pluck("delay").compact_blank
      # PixivTookit format: { "ugokuIllustData": { "frames": [{ "file": "000001.jpg", "delay": 100 }] } }
      in { ugokuIllustData: { frames: frames } }
        frames.pluck("delay").compact_blank
      else
        []
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
  # @param block [Proc] An optional block that will be called with the animation.json data to allow the caller to add extra data to it.
  # @return [MediaFile] The new ugoira.
  def self.create(frames, frame_delays:, &block)
    new(frames, frame_delays:).create_copy(&block)
  end

  # Create a copy of the current ugoira, with a new animation.json file added to it.
  #
  # @param file [File] The output file to write the new ugoira to.
  # @param block [Proc] An optional block that will be called with the animation.json data to allow the caller to add extra data to it.
  # @return [MediaFile] The new ugoira.
  def create_copy(file: Danbooru::Tempfile.new(["danbooru-ugoira-", ".zip"], binmode: true), &block)
    Danbooru::Tempdir.create do |tmpdir|
      animation_meta = {
        width: width,
        height: height,
        mime_type: frames.first&.mime_type.to_s,
        frames: frames.map.with_index do |frame, n|
          { file: "#{"%06d" % n}.#{frame.file_ext}", delay: frame_delays[n], md5: frame.md5 }
        end,
      }

      yield animation_meta if block_given?

      frames.each_with_index do |frame, n|
        FileUtils.cp(frame.path, "#{tmpdir.path}/#{"%06d" % n}.#{frame.file_ext}")
      end

      File.write("#{tmpdir.path}/animation.json", animation_meta.to_json)

      Danbooru::Archive.create!(tmpdir.path, file)
      MediaFile::Ugoira.new(file)
    end
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
