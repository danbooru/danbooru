class Advertisement < ActiveRecord::Base
  validates_inclusion_of :ad_type, :in => %w(horizontal vertical)
  has_many :hits, :class_name => "AdvertisementHit"

  def hit!(ip_addr)
    hits.create(:ip_addr => ip_addr)
  end

  def hit_sum(start_date, end_date)
    hits.where(["created_at BETWEEN ? AND ?", start_date, end_date]).count
  end
  
  def date_path
    created_at.strftime("%Y%m%d")
  end
  
  def image_url
    "/images/ads-#{date_path}/#{file_name}"
  end

  def image_path
    "#{Rails.root}/public/#{image_url}"
  end
  
  def file=(f)
    if f.size > 0
      self.created_at ||= Time.now
      self.file_name = f.original_filename
      FileUtils.mkdir_p(File.dirname(image_path))

      if f.local_path
        FileUtils.cp(f.local_path, image_path)
      else
        File.open(image_path, 'wb') {|nf| nf.write(f.read)}
      end

      File.chmod(0644, image_path)
    
      image_size = ImageSize.new(File.open(image_path, "rb"))
      self.width = image_size.get_width
      self.height = image_size.get_height
    end
  end
  
  def preview_width
    if width > 200 || height > 200
      if width < height
        ratio = 200.0 / height
        return (width * ratio).to_i
      else
        return 200
      end
    end      
  end
  
  def preview_height
    if width > 200 || height > 200
      if height < width
        ratio = 200.0 / width
        return (height * ratio)
      else
        return 200
      end
    end      
  end
end
