class ImageCropper
  def self.enabled?
    Danbooru.config.aws_sqs_cropper_url.present?
  end

  def self.notify(post)
    if post.is_image?
      sqs = SqsService.new(Danbooru.config.aws_sqs_cropper_url)
      sqs.send_message("#{post.id},https://#{Danbooru.config.hostname}/data/#{post.md5}.#{post.file_ext}")
    end
  end
end
