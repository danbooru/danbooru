class Job < ActiveRecord::Base
  CATEGORIES = %w(mass_tag_edit approve_tag_alias approve_tag_implication calculate_tag_subscriptions calculate_related_tags s3_backup upload_processing)
  STATUSES = %w(pending processing finished error)
  
  validates_inclusion_of :category, :in => CATEGORIES
  validates_inclusion_of :status, :in => STATUSES
  
  def data
    JSON.parse(data_as_json)
  end
  
  def data=(text)
    self.data_as_json = text.to_json
  end
  
  def execute!
    if repeat_count > 0
      count = repeat_count - 1
    else
      count = repeat_count
    end
    
    begin
      execute_sql("SET statement_timeout = 0")
      update_attribute(:status, "processing")
      __send__("execute_#{task_type}")
      
      if count == 0
        update_attribute(:status, "finished")
      else
        update_attributes(:status => "pending", :repeat_count => count)
      end
    rescue SystemExit => x
      update_attribute(:status, "pending")
    rescue Exception => x
      update_attributes(:status => "error", :status_message => "#{x.class}: #{x}")
    end
  end
  
  def execute_upload_processing
    Upload.where("status = ?", "pending").each do |upload|
      upload.process!
    end
  end
  
  def execute_mass_tag_edit
    start_tags = data["start_tags"]
    result_tags = data["result_tags"]
    updater_id = data["updater_id"]
    updater_ip_addr = data["updater_ip_addr"]
    Tag.mass_edit(start_tags, result_tags, updater_id, updater_ip_addr)
  end
  
  def execute_approve_tag_alias
    ta = TagAlias.find(data["id"])
    updater_id = data["updater_id"]
    updater_ip_addr = data["updater_ip_addr"]
    ta.approve(updater_id, updater_ip_addr)
  end
  
  def execute_approve_tag_implication
    ti = TagImplication.find(data["id"])
    updater_id = data["updater_id"]
    updater_ip_addr = data["updater_ip_addr"]
    ti.approve(updater_id, updater_ip_addr)
  end
  
  def execute_calculate_tag_subscriptions
    last_run = Time.parse(data["last_run"])
    if last_run.nil? || last_run < 20.minutes.ago
      TagSubscription.process_all
      update_attributes(:data => {:last_run => Time.now.strftime("%Y-%m-%d %H:%M")})
    end
  end
  
  def execute_calculate_related_tags
    tag_id = data["id"].to_i
    tag = Tag.find_by_id(tag_id)
    if tag
      tag.commit_related(Tag.calculate_related(tag.name))      
    end
  end
  
  def execute_s3_backup
    last_id = data["last_id"].to_i
    
    begin
      Post.where("id > ?", last_id).each do |post|
        AWS::S3::Base.establish_connection!(
          :access_key_id => Danbooru.config.amazon_s3_access_key_id, 
          :secret_access_key => Danbooru.config.amazon_s3_secret_access_key
        )
        if File.exists?(post.file_path)
          AWS::S3::S3Object.store(
            post.file_name, 
            open(post.file_path, "rb"), 
            Danbooru.config.amazon_s3_bucket_name, 
            "Content-MD5" => Base64.encode64(post.md5)
          )
        end
        if post.image? && File.exists?(post.preview_path)
          AWS::S3::S3Object.store(
            "preview/#{post.md5}.jpg", 
            open(post.preview_path, "rb"), 
            Danbooru.config.amazon_s3_bucket_name
          )
        end

        update_attributes(:data => {:last_id => post.id})
      end

    rescue Exception => x
      # probably some network error, retry next time
    end
  end
  
  def pretty_data
    begin
      case task_type
      when "mass_tag_edit"
        start = data["start_tags"]
        result = data["result_tags"]
        user = User.find_name(data["updater_id"])      
        "start:#{start} result:#{result} user:#{user}"
    
      when "approve_tag_alias"
        ta = TagAlias.find(data["id"])
        "start:#{ta.name} result:#{ta.alias_name}"
    
      when "approve_tag_implication"
        ti = TagImplication.find(data["id"])
        "start:#{ti.predicate.name} result:#{ti.consequent.name}"
    
      when "calculate_tag_subscriptions"
        last_run = data["last_run"]
        "last run:#{last_run}"

      when "calculate_related_tags"
        tag = Tag.find_by_id(data["id"])
        if tag
          "tag:#{tag.name}"
        else
          "tag:UNKNOWN"
        end
      
      when "bandwidth_throttle"
        ""
      
      when "s3_backup"
        "last_id:" + data["last_id"].to_s
      
      end
    rescue Exception
      "ERROR"
    end
  end
  
  def self.pending_count(task_type)
    where("task_type = ? and status = 'pending'", task_type).count
  end
  
  def self.execute_once
    where("status = ?", "pending").each do |task|
      task.execute!
      sleep 1
    end
  end
end
