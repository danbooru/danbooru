class Post < ActiveRecord::Base
  class Deletion < ActiveRecord::Base
    set_table_name "deleted_posts"
  end
  
  class Pending < ActiveRecord::Base
    set_table_name "pending_posts"
    
    def process!
      update_attribute(:status, "processing")
      move_file
      calculate_hash
      calculate_dimensions
      generate_resizes
      convert_to_post
      update_attribute(:status, "finished")
    end
    
    def move_file
      # Download the file
      # Move the tempfile into the data store
      # Distribute to other servers
    end
    
    def calculate_hash
      # Calculate the MD5 hash of the file
    end
    
    def calculate_dimensions
      # Calculate the dimensions of the image
    end
    
    def generate_resizes
      # Generate width=150
      # Generate width=1000
      # 
    end
    
    def convert_to_post
    end
  
  private
    def download_from_source
      self.source = "" if source.nil?
    
      return if source !~ /^http:\/\// || !file_ext.blank?
    
      begin
        Danbooru.http_get_streaming(source) do |response|
          File.open(tempfile_path, "wb") do |out|
            response.read_body do |block|
              out.write(block)
            end
          end
        end
      
        if source.to_s =~ /\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
          self.source = "Image board"
        end
      
        return true
      rescue SocketError, URI::Error, SystemCallError => x
        delete_tempfile
        errors.add "source", "couldn't be opened: #{x}"
        return false
      end
    end
    
    def move_tempfile
    end
    
    def distribute_file
    end
    
    def generate_resize_for(width)
    end
  end
  
  class Version < ActiveRecord::Base
    set_table_name "post_versions"
  end
  
  module FileMethods    
    def self.included(m)
      m.before_validation_on_create :download_source
      m.before_validation_on_create :validate_tempfile_exists
      m.before_validation_on_create :determine_content_type
      m.before_validation_on_create :validate_content_type
      m.before_validation_on_create :generate_hash
      m.before_validation_on_create :set_image_dimensions
      m.before_validation_on_create :generate_sample
      m.before_validation_on_create :generate_preview
      m.before_validation_on_create :move_file
    end
  
    def validate_tempfile_exists
      unless File.exists?(tempfile_path)
        errors.add :file, "not found, try uploading again"
        return false
      end
    end
  
    def validate_content_type
      unless %w(jpg png gif swf).include?(file_ext.downcase)
        errors.add(:file, "is an invalid content type: " + file_ext.downcase)
        return false
      end
    end
  
    def file_name
      md5 + "." + file_ext
    end

    def delete_tempfile
      FileUtils.rm_f(tempfile_path)
      FileUtils.rm_f(tempfile_preview_path)
      FileUtils.rm_f(tempfile_sample_path)
    end

    def tempfile_path
      "#{RAILS_ROOT}/public/data/#{$PROCESS_ID}.upload"
    end

    def tempfile_preview_path
      "#{RAILS_ROOT}/public/data/#{$PROCESS_ID}-preview.jpg"
    end

    # def file_size
    #   File.size(file_path) rescue 0
    # end

    # Generate an MD5 hash for the file.
    def generate_hash
      unless File.exists?(tempfile_path)
        errors.add(:file, "not found")
        return false
      end

      self.md5 = File.open(tempfile_path, 'rb') {|fp| Digest::MD5.hexdigest(fp.read)}
      self.file_size = File.size(tempfile_path)

      if Post.exists?(["md5 = ?", md5])
        delete_tempfile
        errors.add "md5", "already exists"
        return false
      else
        return true
      end
    end

    def generate_preview
      return true unless image? && width && height

      unless File.exists?(tempfile_path)
        errors.add(:file, "not found")
        return false
      end

      size = Danbooru.reduce_to({:width=>width, :height=>height}, {:width=>150, :height=>150})

      # Generate the preview from the new sample if we have one to save CPU, otherwise from the image.
      if File.exists?(tempfile_sample_path)
        path, ext = tempfile_sample_path, "jpg"
      else
        path, ext = tempfile_path, file_ext
      end

      begin
        Danbooru.resize(ext, path, tempfile_preview_path, size, 95)
      rescue Exception => x
        errors.add "preview", "couldn't be generated (#{x})"
        return false
      end

      return true
    end

    # Automatically download from the source if it's a URL.
    def download_source
      self.source = "" if source.nil?
    
      return if source !~ /^http:\/\// || !file_ext.blank?
    
      begin
        Danbooru.http_get_streaming(source) do |response|
          File.open(tempfile_path, "wb") do |out|
            response.read_body do |block|
              out.write(block)
            end
          end
        end
      
        if source.to_s =~ /\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
          self.source = "Image board"
        end
      
        return true
      rescue SocketError, URI::Error, SystemCallError => x
        delete_tempfile
        errors.add "source", "couldn't be opened: #{x}"
        return false
      end
    end
  
    def determine_content_type
      imgsize = ImageSize.new(File.open(tempfile_path, "rb"))

      unless imgsize.get_width.nil?
        self.file_ext = imgsize.get_type.gsub(/JPEG/, "JPG").downcase
      end
    end

    # Assigns a CGI file to the post. This writes the file to disk and generates a unique file name.
    def file=(f)
      return if f.nil? || f.size == 0

      self.file_ext = content_type_to_file_ext(f.content_type) || find_ext(f.original_filename)

      if f.local_path
        # Large files are stored in the temp directory, so instead of
        # reading/rewriting through Ruby, just rely on system calls to
        # copy the file to danbooru's directory.
        FileUtils.cp(f.local_path, tempfile_path)
      else
        File.open(tempfile_path, 'wb') {|nf| nf.write(f.read)}
      end
    end

    def set_image_dimensions
      if image? or flash?
        imgsize = ImageSize.new(File.open(tempfile_path, "rb"))
        self.width = imgsize.get_width
        self.height = imgsize.get_height
      end
    end

    # Returns true if the post is an image format that GD can handle.
    def image?
      %w(jpg jpeg gif png).include?(file_ext.downcase)
    end

    # Returns true if the post is a Flash movie.
    def flash?
      file_ext == "swf"
    end

    def find_ext(file_path)
      ext = File.extname(file_path)
      if ext.blank?
        return "txt"
      else
        ext = ext[1..-1].downcase
        ext = "jpg" if ext == "jpeg"
        return ext
      end
    end

    def content_type_to_file_ext(content_type)
      case content_type.chomp
      when "image/jpeg"
        return "jpg"

      when "image/gif"
        return "gif"

      when "image/png"
        return "png"

      when "application/x-shockwave-flash"
        return "swf"

      else
        nil
      end
    end
  
    def preview_dimensions
      if image?
        dim = Danbooru.reduce_to({:width => width, :height => height}, {:width => 150, :height => 150})
        return [dim[:width], dim[:height]]
      else
        return [150, 150]
      end
    end
  
    def tempfile_sample_path
      "#{RAILS_ROOT}/public/data/#{$PROCESS_ID}-sample.jpg"
    end

    def regenerate_sample
      return false unless image?

      if generate_sample && File.exists?(tempfile_sample_path)
        FileUtils.mkdir_p(File.dirname(sample_path), :mode => 0775)
        FileUtils.mv(tempfile_sample_path, sample_path)
        FileUtils.chmod(0775, sample_path)
        puts "Fixed sample for #{id}"
        return true
      else
        puts "Error generating sample for #{id}"
        return false
      end
    end

    def generate_sample
      return true unless image?
      return true unless CONFIG["image_samples"]
      return true unless (width && height)
      return true if (file_ext.downcase == "gif")

      size = Danbooru.reduce_to({:width => width, :height => height}, {:width => CONFIG["sample_width"], :height => CONFIG["sample_height"]}, CONFIG["sample_ratio"])

      # We can generate the sample image during upload or offline.  Use tempfile_path
      # if it exists, otherwise use file_path.
      path = tempfile_path
      path = file_path unless File.exists?(path)
      unless File.exists?(path)
        errors.add(:file, "not found")
        return false
      end

      # If we're not reducing the resolution for the sample image, only reencode if the
      # source image is above the reencode threshold.  Anything smaller won't be reduced
      # enough by the reencode to bother, so don't reencode it and save disk space.
      if size[:width] == width && size[:height] == height && File.size?(path) < CONFIG["sample_always_generate_size"]
        return true
      end

      # If we already have a sample image, and the parameters havn't changed,
      # don't regenerate it.
      if size[:width] == sample_width && size[:height] == sample_height
        return true
      end

      size = Danbooru.reduce_to({:width => width, :height => height}, {:width => CONFIG["sample_width"], :height => CONFIG["sample_height"]})
      begin
        Danbooru.resize(file_ext, path, tempfile_sample_path, size, 90)
      rescue Exception => x
        errors.add "sample", "couldn't be created: #{x}"
        return false
      end

      self.sample_width = size[:width]
      self.sample_height = size[:height]
      return true
    end

    # Returns true if the post has a sample image.
    def has_sample?
      sample_width.is_a?(Integer)
    end

    # Returns true if the post has a sample image, and we're going to use it.
    def use_sample?(user = nil)
      if user && !user.show_samples?
        false
      else
        CONFIG["image_samples"] && has_sample?
      end
    end

    def sample_url(user = nil)
      if use_sample?(user)
        store_sample_url
      else
        file_url
      end
    end

    def get_sample_width(user = nil)
      if use_sample?(user)
        sample_width
      else
        width
      end
    end

    def get_sample_height(user = nil)
      if use_sample?(user)
        sample_height
      else
        height
      end
    end
  
    def sample_percentage
      100 * get_sample_width.to_f / width
    end
  end
end
