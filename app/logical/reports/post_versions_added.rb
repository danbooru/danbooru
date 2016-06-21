module Reports
  class PostVersionsAdded
    attr_reader :tag, :email

    def initialize(tag, email)
      @tag = tag
      @email = email
    end

    def process!
      if tag
        json = {"type" => "post_versions_added", "tag" => tag, "email" => email}.to_json
        SqsService.new(Danbooru.config.aws_sqs_post_versions_url).send_message(json)
      end
    end
  end
end
