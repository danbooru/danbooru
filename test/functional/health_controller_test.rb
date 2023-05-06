require 'test_helper'

class HealthControllerTest < ActionDispatch::IntegrationTest
  context "The health controller" do
    context "/up action" do
      should "work" do
        get rails_health_check_path

        assert_response 204
      end
    end

    context "/up/postgres action" do
      should "return 204 if Postgres is up" do
        get "/up/postgres"

        assert_response 204
      end

      should "return 503 if Postgres is down" do
        without_database do
          get "/up/postgres"

          assert_response 503
        end
      end
    end

    context "/up/redis action" do
      should "return 204 if Redis is up" do
        Rails.cache.stubs(:redis).returns(MockRedis.new)
        get "/up/redis"

        assert_response 204
      end

      should "return 503 if Redis is down" do
        get "/up/redis"

        assert_response 503
      end
    end
  end
end
