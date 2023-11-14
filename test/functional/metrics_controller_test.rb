require 'test_helper'

class MetricsControllerTest < ActionDispatch::IntegrationTest
  context "The metrics controller" do
    context "#index action" do
      should "work for text format" do
        get metrics_path

        assert_response :success
      end

      should "work for json format" do
        get metrics_path(format: :json)

        assert_response :success
      end

      should "work for xml format" do
        get metrics_path(format: :json)

        assert_response :success
      end
    end

    context "#instance action" do
      should "work for text format" do
        get instance_metrics_path

        assert_response :success
      end
    end
  end
end
