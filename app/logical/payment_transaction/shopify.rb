# frozen_string_literal: true

class PaymentTransaction::Shopify < PaymentTransaction
  class InvalidWebhookError < StandardError; end

  def create!(**params)
    nil
  end

  def refund!(reason = nil)
    raise NotImplementedError
  end

  concerning :WebhookMethods do
    class_methods do
      def receive_webhook(request)
        verify_webhook!(request)
      end

      private def verify_webhook!(request)
        payload = request.body.read
        actual_signature = request.headers["X-Shopify-Hmac-Sha256"].to_s
        calculated_signature = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", Danbooru.config.shopify_webhook_secret, payload))
        raise InvalidWebhookError unless ActiveSupport::SecurityUtils::secure_compare(actual_signature, calculated_signature)

        request
      end
    end
  end
end
