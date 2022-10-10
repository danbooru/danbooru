# frozen_string_literal: true

# A MediaFile for a Pixiv ugoira file.
#
# A Pixiv ugoira is an animation format that consists of a zip file containing
# JPEG or PNG images, one per frame, plus a JSON object containing the
# inter-frame delay timings. Each frame can have a different delay, therefore
# ugoiras can have a variable framerate. The frame data isn't stored inside the
# zip file, so it must be passed around separately.
class MediaFile::Ugoira < MediaFile
  class Error < StandardError; end
  attr_accessor :frame_delays

  def initialize(file, frame_delays: [], **options)
    super(file, **options)
    @frame_delays = frame_delays
  end

  def close
    file.close
    zipfile.close
    preview_frame.close
  end

  def metadata
    super.merge("Ugoira:FrameDelays" => frame_delays)
  end

  def dimensions
    preview_frame.dimensions
  end

  def preview(width, height, **options)
    preview_frame.preview(width, height, **options)
  end

  def duration
    (frame_delays.sum / 1000.0)
  end

  def frame_count
    frame_delays.count
  end

  def frame_rate
    frame_count / duration
  end

  # Convert a ugoira to a webm.
  # XXX should take width and height and resize image
  def convert
    raise NotImplementedError, "can't convert ugoira to webm: ffmpeg or mkvmerge not installed" unless self.class.videos_enabled?
    raise RuntimeError, "can't convert ugoira to webm: no ugoira frame data was provided" unless frame_delays.present?

    Dir.mktmpdir("ugoira-#{md5}") do |tmpdir|
      output_file = Tempfile.new(["ugoira-conversion", ".webm"], binmode: true)

      FileUtils.mkdir_p("#{tmpdir}/images")

      zipfile.each do |entry|
        path = File.join(tmpdir, "images", entry.name)
        entry.extract(path)
      end

      # Duplicate last frame to avoid it being displayed only for a very short amount of time.
      last_file_name = zipfile.entries.last.name
      last_file_name =~ /\A(\d{6})(\.\w{,4})\Z/
      new_last_index = $1.to_i + 1
      file_ext = $2
      new_last_filename = ("%06d" % new_last_index) + file_ext
      path_from = File.join(tmpdir, "images", last_file_name)
      path_to = File.join(tmpdir, "images", new_last_filename)
      FileUtils.cp(path_from, path_to)

      delay_sum = 0
      timecodes_path = File.join(tmpdir, "timecodes.tc")
      File.open(timecodes_path, "w+") do |f|
        f.write("# timecode format v2\n")
        frame_delays.each do |delay|
          f.write("#{delay_sum}\n")
          delay_sum += delay
        end
        f.write("#{delay_sum}\n")
        f.write("#{delay_sum}\n")
      end

      ext = zipfile.first.name.match(/\.(\w{,4})$/)[1]
      ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir}/images/%06d.#{ext} -codec:v libvpx-vp9 -crf 12 -b:v 0 -an -threads 8 -tile-columns 2 -tile-rows 1 -row-mt 1 -pass 1 -passlogfile #{tmpdir}/ffmpeg2pass -f null /dev/null")
      raise Error, "ffmpeg failed: #{ffmpeg_out}" unless status.success?

      ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir}/images/%06d.#{ext} -codec:v libvpx-vp9 -crf 12 -b:v 0 -an -threads 8 -tile-columns 2 -tile-rows 1 -row-mt 1 -pass 2 -passlogfile #{tmpdir}/ffmpeg2pass #{tmpdir}/tmp.webm")
      raise Error, "ffmpeg failed: #{ffmpeg_out}" unless status.success?

      mkvmerge_out, status = Open3.capture2e("mkvmerge -o #{output_file.path} --webm --timecodes 0:#{tmpdir}/timecodes.tc #{tmpdir}/tmp.webm")
      raise Error, "mkvmerge failed: #{mkvmerge_out}" unless status.success?

      MediaFile.open(output_file)
    end
  end

  private

  def zipfile
    Zip::File.new(file.path)
  end

  def preview_frame
    FFmpeg.new(convert).smart_video_preview
  end

  memoize :zipfile, :preview_frame, :dimensions, :convert
end
