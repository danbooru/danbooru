class PixivUgoiraConverter
  def self.convert(source_path, output_path, preview_path, frame_data)
    folder = Zip::File.new(source_path)
    write_webm(folder, output_path, frame_data)
    write_preview(folder, preview_path)
    RemoteFileManager.new(output_path).distribute
    RemoteFileManager.new(preview_path).distribute
  end

  def self.write_webm(folder, write_path, frame_data)
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
  end

  def self.write_preview(folder, path)
    Dir.mktmpdir do |tmpdir|
      file = folder.first
      temp_path = File.join(tmpdir, file.name)
      file.extract(temp_path)
      DanbooruImageResizer.resize(temp_path, path, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 85)
    end
  end
end
