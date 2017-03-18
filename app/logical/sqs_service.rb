class SqsService
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def enabled?
    Danbooru.config.aws_sqs_enabled? && credentials.set? && url.present?
  end

  def send_message(string, options = {})
    return unless enabled?

    sqs.send_message(
      options.merge(
        message_body: string,
        queue_url: url
      )
    )
  end

private

  def credentials
    @credentials ||= Aws::Credentials.new(
      Danbooru.config.aws_access_key_id,
      Danbooru.config.aws_secret_access_key
    )
  end

  def sqs
    @sqs ||= Aws::SQS::Client.new(
      credentials: credentials,
      region: Danbooru.config.aws_sqs_region
    )
  end
end
