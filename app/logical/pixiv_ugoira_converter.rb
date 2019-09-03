class PixivUgoiraConverter
  def self.enabled?
    system("ffmpeg -version > /dev/null") && system("mkvmerge --version > /dev/null")
  end

  def self.generate_webm(ugoira_file, frame_data)
    raise NotImplementedError, "can't convert ugoira to webm: ffmpeg or mkvmerge not installed" unless enabled?

    folder = Zip::File.new(ugoira_file.path)
    output_file = Tempfile.new(binmode: true)
    write_path = output_file.path

    Dir.mktmpdir do |tmpdir|
      FileUtils.mkdir_p("#{tmpdir}/images")
      folder.each_with_index do |file, i|
        path = File.join(tmpdir, "images", file.name)
        file.extract(path)
      end
      
      # Duplicate last frame to avoid it being displayed only for a very short amount of time.
      last_file_name = folder.to_a.last.name
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

      ext = folder.first.name.match(/\.(\w{,4})$/)[1]
      ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{tmpdir}/images/%06d.#{ext} -codec:v libvpx -crf 4 -b:v 5000k -an #{tmpdir}/tmp.webm")

      if !status.success?
        Rails.logger.error "[write_webm] ******************************"
        Rails.logger.error "[write_webm] failed write_path=#{write_path}"
        Rails.logger.error "[write_webm] ffmepg output:"
        ffmpeg_out.split(/\n/).each do |line|
          Rails.logger.error "[write_webm][ffmpeg] #{line}"
        end
        Rails.logger.error "[write_webm] ******************************"
        return
      end

      mkvmerge_out, status = Open3.capture2e("mkvmerge -o #{write_path} --webm --timecodes 0:#{tmpdir}/timecodes.tc #{tmpdir}/tmp.webm")

      if !status.success?
        Rails.logger.error "[write_webm] ******************************"
        Rails.logger.error "[write_webm] failed write_path=#{write_path}"
        Rails.logger.error "[write_webm] mkvmerge output:"
        mkvmerge_out.split(/\n/).each do |line|
          Rails.logger.error "[write_webm][mkvmerge] #{line}"
        end
        Rails.logger.error "[write_webm] ******************************"
        return
      end
    end

    output_file
  end

  def self.generate_crop(ugoira_file)
    return nil unless Danbooru.config.enable_image_cropping

    file = Tempfile.new(["ugoira-crop", ".zip"], binmode: true)
    zipfile = Zip::File.new(ugoira_file.path)
    zipfile.entries.first.extract(file.path) { true } #  'true' means overwrite the existing tempfile.

    DanbooruImageResizer.crop(file, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 85)
  ensure
    file&.close!
  end

  def self.generate_preview(ugoira_file)
    file = Tempfile.new(["ugoira-preview", ".zip"], binmode: true)
    zipfile = Zip::File.new(ugoira_file.path)
    zipfile.entries.first.extract(file.path) { true } #  'true' means overwrite the existing tempfile.

    DanbooruImageResizer.resize(file, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 85)
  ensure
    file.close!
  end
end
