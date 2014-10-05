class PixivUgoiraConverter
  attr_reader :agent, :url, :write_path

  def initialize(agent, url, write_path)
    @agent = agent
    @url = url
    @write_path = write_path
  end

  def process(format)
    folder = unpack(fetch_zipped_body)

    if format == :gif
      write_gif(folder)
    elsif format == :webm
      write_webm(folder)
    elsif format == :apng
      write_apng(folder)
    end
  end

  def write_gif(folder)
    anim = Magick::ImageList.new
    delay_sum = 0
    folder.each_with_index do |file, i|
      image_blob = file.get_input_stream.read
      image = Magick::Image.from_blob(image_blob).first
      image.ticks_per_second = 1000
      delay = @frame_data[i]["delay"]
      rounded_delay = (delay_sum + delay).round(-1) - delay_sum.round(-1)
      image.delay = rounded_delay
      delay_sum += delay
      anim << image
    end
    
    anim = anim.optimize_layers(Magick::OptimizeTransLayer)
    anim.write(write_path)
  end

  def write_webm(folder)
    Dir.mktmpdir do |tmpdir|
      FileUtils.mkdir_p("#{tmpdir}/images")
      folder.each_with_index do |file, i|
        path = File.join(tmpdir, "images", file.name)
        image_blob = file.get_input_stream.read
        File.open(path, "wb") do |f|
          f.write(image_blob)
        end
      end
      
      # Duplicate last frame to avoid it being displayed only for a very short amount of time.
      folder.to_a.last.name =~ /\A(\d{6})(\..+)\Z/
      new_last_index = $1.to_i + 1
      file_ext = $2
      new_last_filename = ("%06d" % new_last_index) + file_ext
      path_from = File.join(tmpdir, "images", folder.to_a.last.name)
      path_to = File.join(tmpdir, "images", new_last_filename)
      FileUtils.cp(path_from, path_to)
      
      delay_sum = 0
      timecodes_path = File.join(tmpdir, "timecodes.tc")
      File.open(timecodes_path, "w+") do |f|
        f.write("# timecode format v2\n")
        @frame_data.each do |img|
          f.write("#{delay_sum}\n")
          delay_sum += img["delay"]
        end
        f.write("#{delay_sum}\n")
        f.write("#{delay_sum}\n")
      end
      
      ext = folder.first.name.match(/\.(.+)$/)[1]
      system("ffmpeg -i #{tmpdir}/images/%06d.#{ext} -codec:v libvpx -crf 4 -b:v 5000k -an #{tmpdir}/tmp.webm")
      system("mkvmerge -o #{write_path} --timecodes 0:#{tmpdir}/timecodes.tc #{tmpdir}/tmp.webm")
    end      
  end

  def write_apng(folder)
      FileUtils.mkdir_p("pixiv_anim_#{pixiv_id}")
      folder.each_with_index do |file, i|
        frame_path = File.join("pixiv_anim_#{pixiv_id}", "frame#{"%03d" % i}.png")
      delay_path = File.join("pixiv_anim_#{pixiv_id}", "frame#{"%03d" % i}.txt")
        image_blob = file.get_input_stream.read
      delay = @frame_data[i]["delay"]
      image = Magick::Image.from_blob(image_blob).first
      image.format="PNG"
      image.write(frame_path)
      File.open(delay_path, "wb") do |f|
          f.write("delay=#{delay}/1000")
        end
      end
      system("apngasm pixiv_anim_#{pixiv_id}.png pixiv_anim_#{pixiv_id}/frame*.png")
      FileUtils.rm_rf("pixiv_anim_#{pixiv_id}")
      
      puts "Animation successfully created as pixiv_anim_#{pixiv_id}.png"
  end

  def unpack(zipped_body)
    folder = Zip::CentralDirectory.new
    folder.read_from_stream(StringIO.new(zipped_body))
    folder
  end

  def fetch_zipped_body
    zip_uri, @frame_data = fetch_frames

    zip_body = Net::HTTP.start(zip_uri.host) do |http|
      http.get(zip_uri.path, {"Referer" => "http://pixiv.net"}).body
    end
  end

  def fetch_frames
    agent.get(url) do |page|
      # Get the zip url and frame delay by parsing javascript contained in a <script> tag on the page.
      # Not a neat solution, but I haven't found any other location that has the frame delays listed.
      scripts = page.search("body script").find_all do |node|
        node.text =~ /_ugoira600x600\.zip/
      end

      if scripts.any?
        javascript = scripts.first.text
        json = javascript.match(/;pixiv\.context\.ugokuIllustData\s+=\s+(\{.+?\});(?:$|pixiv\.context)/)[1]
        data = JSON.parse(json)
        zip_uri = URI(data["src"].sub("_ugoira600x600.zip", "_ugoira1920x1080.zip"))
        frame_data = data["frames"]
        return [zip_uri, frame_data]
      else
        raise "Can't find javascript with frame data"
      end
    end
  end
end
