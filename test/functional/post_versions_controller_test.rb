require 'test_helper'

class PostVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  context "The post versions controller" do
    context "index action" do
      setup do        
        @user.as_current do
          @post = create(:post)
          travel_to(2.hours.from_now) do
            @post.update(:tag_string => "1 2", :source => "xxx")
          end
          travel_to(4.hours.from_now) do
            @post.update(:tag_string => "2 3", :rating => "e")
          end
          @versions = @post.versions
          @post2 = create(:post)
        end
      end

      should "list all versions" do
        get_auth post_versions_path, @user
        assert_response :success
        assert_select "#post-version-#{@versions[0].id}"
        assert_select "#post-version-#{@versions[1].id}"
        assert_select "#post-version-#{@versions[2].id}"
      end

      should "list all versions that match the search criteria" do
        get_auth post_versions_path, @user, params: {:search => {:post_id => @post.id}}
        assert_response :success
        assert_select "#post-version-#{@post2.versions[0].id}", false
      end
    end
  end
end
