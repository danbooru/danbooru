require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  context "The webhooks controller" do
    should "return 404 for actions that don't exist" do
      get "/webhooks/1"
      assert_response 404

      get "/webhooks"
      assert_response 404
    end

    context "receive action" do
      context "for a request from an unrecognized source" do
        should "fail" do
          post receive_webhooks_path(source: "blah")
          assert_response 400
        end
      end

      context "for a request from a payment processor" do
        should "fail" do
          post receive_webhooks_path(source: "stripe")
          assert_response 400

          post receive_webhooks_path(source: "shopify")
          assert_response 400
        end
      end
    end
  end
end
