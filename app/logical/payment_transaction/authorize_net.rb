# frozen_string_literal: true

# https://sandbox.authorize.net/
# https://developer.authorize.net/hello_world.html
# https://developer.authorize.net/api/reference/index.html
# https://developer.authorize.net/api/reference/features/accept_hosted.html
# https://developer.authorize.net/hello_world/testing_guide.html
class PaymentTransaction::AuthorizeNet < PaymentTransaction
  extend Memoist

  class InvalidWebhookError < StandardError; end

  def create!(country: "US", allow_promotion_codes: false)
    # https://developer.authorize.net/api/reference/index.html#accept-suite-get-an-accept-payment-page
    response = api_client.get_hosted_payment_page(
      reference_id: user_upgrade.id,
      transactionType: "authCaptureTransaction",
      amount: user_upgrade.price,
      customer: {
        id: user_upgrade.purchaser.id,
        email: user_upgrade.purchaser.email_address&.address,
      },
      settings: {
        button: {
          text: "Pay",
        },
        order: {
          show: false,
          merchantName: Danbooru.config.canonical_app_name,
        },
        payment: {
          cardCodeRequired: true,
          showCreditCard: true,
          showBankAccount: false,
        },
        customer: {
          showEmail: true, requiredEmail: true, addPaymentProfile: false
        },
        billing_address: {
          show: true,
          required: false,
        },
        shipping_address: {
          show: false,
          required: false,
        },
        style: { bgColor: "blue" },
        return: {
          url: Routes.user_upgrade_url(user_upgrade),
          cancelUrl: Routes.new_user_upgrade_url(user_id: recipient.id),
          urlText: "Continue",
          cancelUrlText: "Cancel",
          showReceipt: true,
        },
      }
    )

    [api_client.payment_page_url, response[:token]]
  end

  def refund!(reason = nil)
    raise NotImplementedError
  end

  concerning :WebhookMethods do
    class_methods do
      # https://developer.authorize.net/api/reference/features/webhooks.html#Event_Types_and_Payloads
      def receive_webhook(request)
        verify_webhook!(request)

        case request.params[:eventType]
        when "net.authorize.payment.authcapture.created"
          payment_completed(request)
        end
      end

      # https://developer.authorize.net/api/reference/features/webhooks.html#Verifying_the_Notification
      private def verify_webhook!(request)
        payload = request.body.read
        actual_signature = request.headers["X-Anet-Signature"].to_s
        calculated_signature = "sha512=" + OpenSSL::HMAC.digest("sha512", Danbooru.config.authorize_net_signature_key, payload).unpack1("H*").upcase
        raise InvalidWebhookError unless ActiveSupport::SecurityUtils::secure_compare(actual_signature, calculated_signature)

        request
      end

      private def payment_completed(request)
        # Authorize.net's shitty API sends a real request with fake values when you trigger a test webhook.
        # The only way to detect a test webhook is to check for these hardcoded fake values.
        if request.params.dig(:payload, :authAmount) == 12.5 && request.params.dig(:payload, :id) == "245" && request.params.dig(:payload, :authCode) == "572"
          return
        end

        user_upgrade_id = request.params.dig(:payload, :merchantReferenceId)
        transaction_id = request.params.dig(:payload, :id)
        user_upgrade = UserUpgrade.find(user_upgrade_id)
        user_upgrade.update!(transaction_id: transaction_id)
        user_upgrade.process_upgrade!("paid")
      end

      private def register_webhook
        raise NotImplementedError
      end
    end
  end

  def receipt_url
    # "https://sandbox.authorize.net/ui/themes/sandbox/Transaction/TransactionReceipt.aspx?transid=#{transaction_id}" if transaction_id.present?
  end

  def payment_url
    # "https://sandbox.authorize.net/ui/themes/sandbox/transaction/transactiondetail.aspx?transID=40092238841" if transaction_id.present?
  end

  def transaction
    return nil if user_upgrade.transaction_id.nil?
    api_client.get_transaction(user_upgrade.transaction_id)
  end

  def api_client
    AuthorizeNetClient.new
  end

  memoize :api_client, :transaction
end
