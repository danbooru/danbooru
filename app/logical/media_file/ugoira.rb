class MediaFile::Ugoira < MediaFile
  class Error < StandardError; end
  attr_reader :frame_data

  def initialize(file, frame_data: {}, **options)
    super(file, **options)
    @frame_data = frame_data
  end

  def close
    file.close
    zipfile.close
    preview_frame.close
  end

  def dimensions
    preview_frame.dimensions
  end

  def preview(width, height)
    preview_frame.preview(width, height)
  end

  def crop(width, height)
    preview_frame.crop(width, height)
  end

  # XXX should take width and height and resize image
  def convert
    raise NotImplementedError, "can't convert ugoira to webm: ffmpeg or mkvmerge not installed" unless self.class.videos_enabled?

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
        frame_data.each do |img|
          f.write("#{delay_sum}\n")
          delay_sum += (img["delay"] || img["delay_msec"])
        end
        f.write("#{delay_sum}\n")
        f.write("#{delay_sum}\n")
      end

      ext = zipfile.first.name.match(/\.(\w{,4})$/)[1]
      ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir}/images/%06d.#{ext} -codec:v libvpx -crf 4 -b:v 5000k -an #{tmpdir}/tmp.webm")
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
    tempfile = Tempfile.new("ugoira-preview", binmode: true)
    zipfile.entries.first.extract(tempfile.path) { true } #  'true' means overwrite the existing tempfile.
    MediaFile.open(tempfile)
  end

  memoize :zipfile, :preview_frame, :dimensions
end
