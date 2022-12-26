require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  context "The webhooks controller" do
    context "receive action" do
      context "for a request from an unrecognized source" do
        should "fail" do
          post receive_webhooks_path(source: "blah")
          assert_response 400
        end
      end
    end
  end
end
