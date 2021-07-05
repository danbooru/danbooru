# A wrapper for the Amazon SQS API. Used by the PostArchive and PoolArchive
# service to record post and pool versions.
#
# @see https://docs.aws.amazon.com/sqs/index.html
# @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/Client.html
class SqsService
  attr_reader :url

  # @param url [String] the URL of the Amazon SQS queue
  def initialize(url)
    @url = url
  end

  # @return [Boolean] true if the SQS service is configured
  def enabled?
    Danbooru.config.aws_credentials.set? && url.present?
  end

  # Sends a message to the Amazon SQS queue.
  # @param string [String] the message to send
  # @param options [Hash] extra options for the SQS call
  # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/Client.html#send_message-instance_method
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

  # @return [Aws::SQS::Client] the SQS API client object
  def sqs
    @sqs ||= Aws::SQS::Client.new(
      credentials: Danbooru.config.aws_credentials,
      region: Danbooru.config.aws_sqs_region
    )
  end
end
