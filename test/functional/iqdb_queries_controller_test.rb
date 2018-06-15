require 'test_helper'

class IqdbQueriesControllerTest < ActionDispatch::IntegrationTest
  context "The iqdb controller" do
    setup do
      @user = create(:user)
      as_user do
        @posts = FactoryBot.create_list(:post, 2)
      end
    end

    context "show action" do
      should "render with matches" do
        json = @posts.map {|x| [x.id, 1]}.to_json
        get_auth iqdb_queries_path, @user, params: { matches: json }
        assert_response :success
      end
    end
  end
end
