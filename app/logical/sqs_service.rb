class SqsService
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def enabled?
    Danbooru.config.aws_credentials.set? && url.present?
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

  def sqs
    @sqs ||= Aws::SQS::Client.new(
      credentials: Danbooru.config.aws_credentials,
      region: Danbooru.config.aws_sqs_region
    )
  end
end
