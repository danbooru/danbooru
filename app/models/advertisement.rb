class Advertisement < ActiveRecord::Base
  validates_inclusion_of :ad_type, :in => %w(horizontal vertical)
  has_many :hits, :class_name => "AdvertisementHit"
  after_create :copy_to_servers
  after_destroy :delete_from_servers

  def copy_to_servers
    RemoteFileManager.new(image_path).distribute
  end
  
  def delete_from_servers
    RemoteFileManager.new(image_path).delete
  end

  def hit!(ip_addr)
    hits.create(:ip_addr => ip_addr)
  end

  def hit_sum(start_date, end_date)
    hits.where(["created_at BETWEEN ? AND ?", start_date, end_date]).count
  end
  
  def unique_identifier
    @unique_identifier ||= ("%.0f" % (Time.now.to_f * 1_000))
  end
  
  def image_url
    "/images/advertisements/ads-#{date_prefix}/#{file_name}"
  end
  
  def date_prefix
    created_at.strftime("%Y%m%d")
  end

  def image_path
    "#{Danbooru.config.advertisement_path}/ads-#{date-prefix}/#{file_name}"
  end
  
  def file
    nil
  end
  
  def file=(f)
    if f.size > 0
      self.file_name = unique_identifier + File.extname(f.original_filename)

      if f.local_path
        FileUtils.cp(f.local_path, image_path)
      else
        File.open(image_path, 'wb') {|nf| nf.write(f.read)}
      end

      File.chmod(0644, image_path)
      image_size = ImageSize.new(File.open(image_path, "rb"))
      self.width = image_size.get_width
      self.height = image_size.get_height
      
      if width > height
        self.ad_type = "horizontal"
      else
        self.ad_type = "vertical"
      end
    end
  end
  
  def preview_width
    if width > 100 || height > 100
      if width < height
        ratio = 100.0 / height
        return (width * ratio).to_i
      else
        return 100
      end
    end      
  end
  
  def preview_height
    if width > 100 || height > 100
      if height < width
        ratio = 100.0 / width
        return (height * ratio).to_i
      else
        return 100
      end
    end      
  end
end
