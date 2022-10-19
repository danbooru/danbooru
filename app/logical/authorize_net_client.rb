# frozen_string_literal: true

# An API client for Authorize.net. Used for processing payments for user upgrades.
#
# https://developer.authorize.net/api.html
# https://developer.authorize.net/api/reference/index.html
class AuthorizeNetClient
  class Error < StandardError; end

  attr_reader :login_id, :transaction_key, :test_mode, :http

  def initialize(login_id: Danbooru.config.authorize_net_login_id, transaction_key: Danbooru.config.authorize_net_transaction_key, test_mode: Danbooru.config.authorize_net_test_mode, http: Danbooru::Http.external)
    @login_id = login_id
    @transaction_key = transaction_key
    @test_mode = test_mode
    @http = http
  end

  concerning :ApiMethods do
    def authenticate_test
      post!(
        authenticateTestRequest: {
          merchantAuthentication: {
            name: login_id,
            transactionKey: transaction_key,
          }
        }
      )
    end

    # https://developer.authorize.net/api/reference/index.html#transaction-reporting-get-transaction-details
    def get_transaction(transaction_id)
      post!(
        getTransactionDetailsRequest: {
          merchantAuthentication: {
            name: login_id,
            transactionKey: transaction_key,
          },
          transId: transaction_id,
        }
      )
    end

    # https://developer.authorize.net/api/reference/index.html#accept-suite-get-an-accept-payment-page
    def get_hosted_payment_page(reference_id:, settings: {}, **transaction_request)
      post!(
        getHostedPaymentPageRequest: {
          merchantAuthentication: {
            name: login_id,
            transactionKey: transaction_key,
          },
          refId: reference_id,
          transactionRequest: transaction_request,
          "hostedPaymentSettings": {
            "setting": hosted_payment_settings(settings),
          },
        }
      )
    end

    def hosted_payment_settings(settings)
      settings.map do |name, hash|
        {
          "settingName": "hostedPayment#{name.to_s.camelize}Options",
          "settingValue": hash.to_json,
        }
      end
    end

    def post!(**request)
      resp = http.post!(api_url, json: request)

      body = resp.body.to_s.delete_prefix("\xEF\xBB\xBF") # delete UTF-8 BOM
      json = JSON.parse(body).with_indifferent_access

      if json.dig(:messages, :resultCode) != "Ok"
        code = json.dig(:messages, :message, 0, :code)
        text = json.dig(:messages, :message, 0, :text)
        raise Error, "Authorize.net call failed (request=#{request.keys.first} code=#{code} text=#{text})"
      else
        json
      end
    end

    # https://developer.authorize.net/api/reference/index.html#gettingstarted-section-section-header
    def api_url
      if test_mode
        "https://apitest.authorize.net/xml/v1/request.api"
      else
        "https://api.authorize.net/xml/v1/request.api"
      end
    end

    # https://developer.authorize.net/api/reference/features/accept_hosted.html#Form_POST_URLs
    def payment_page_url
      if test_mode
        "https://test.authorize.net/payment/payment"
      else
        "https://accept.authorize.net/payment/payment"
      end
    end
  end

  # https://developer.authorize.net/api/reference/features/webhooks.html
  concerning :WebhookApiMethods do
    # https://developer.authorize.net/api/reference/features/webhooks.html#List_My_Webhooks
    def webhooks
      webhook_get!("webhooks")
    end

    # https://developer.authorize.net/api/reference/features/webhooks.html#Get_a_Webhook
    def webhook(webhook_id)
      webhook_get!("webhooks/#{webhook_id}")
    end

    # https://developer.authorize.net/api/reference/features/webhooks.html#Retrieve_Notification_History
    def notifications(status: nil)
      webhook_get!("notifications", params: { deliveryStatus: status }.compact)
    end

    # https://developer.authorize.net/api/reference/features/webhooks.html#Retrieve_a_Specific_Notification's_History
    def notification(notification_id)
      webhook_get!("notifications/#{notification_id}")
    end

    # https://developer.authorize.net/api/reference/features/webhooks.html#Create_A_Webhook
    def create_webhook(name:, url:, eventTypes:, status: "active")
      webhook_post!("webhooks", form: { name: name, url: url, eventTypes: eventTypes, status: status })
    end

    def webhook_get!(path, **options)
      http.basic_auth(user: login_id, pass: transaction_key).get!(webhook_url(path), **options).parse
    end

    def webhook_post!(path, **options)
      http.basic_auth(user: login_id, pass: transaction_key).post!(webhook_url(path), **options).parse
    end

    # https://developer.authorize.net/api/reference/features/webhooks.html#API_Endpoint_Hosts
    def webhook_url(path)
      if test_mode
        "https://apitest.authorize.net/rest/v1/#{path}"
      else
        "https://api.authorize.net/rest/v1/#{path}"
      end
    end
  end
end
