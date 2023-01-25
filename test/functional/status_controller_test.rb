require 'test_helper'

class StatusControllerTest < ActionDispatch::IntegrationTest
  context "The status controller" do
    should "work for a html response" do
      get status_path
      assert_response :success
    end

    should "work for a json response" do
      get status_path(format: :json)
      assert_response :success
    end

    should "work for an xml response" do
      get status_path(format: :json)
      assert_response :success
    end

    should "work for a header containing UTF-8 characters" do
      get status_path, headers: { "User-Agent": "Portimão".force_encoding("ASCII-8BIT") }
      assert_response :success
    end

    should "work for a header containing invalid UTF-8 characters" do
      get status_path, headers: { "User-Agent": "Portim\xE3o".force_encoding("ASCII-8BIT") }
      assert_response :success
    end
  end
end
