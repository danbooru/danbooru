require "test_helper"

class PostsControllerTest < ActionController::TestCase
  context "The posts controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = FactoryGirl.create(:post, :uploader_id => @user.id, :tag_string => "aaaa")
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "for api calls" do
      context "using http basic auth" do
        should "succeed for password matches" do
          @basic_auth_string = "Basic #{ActiveSupport::Base64.encode64("#{@user.name}:#{@user.bcrypt_cookie_password_hash}")}"
          @request.env['HTTP_AUTHORIZATION'] = @basic_auth_string
          get :index, {:format => "json"}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          @basic_auth_string = "Basic #{ActiveSupport::Base64.encode64("#{@user.name}:badpassword")}"
          @request.env['HTTP_AUTHORIZATION'] = @basic_auth_string
          get :index, {:format => "json"}
          assert_response 401
        end
      end
      
      context "using the api_key parameter" do
        should "succeed for password matches" do
          get :index, {:format => "json", :login => @user.name, :api_key => @user.bcrypt_cookie_password_hash}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          get :index, {:format => "json", :login => @user.name, :api_key => "bad"}
          assert_response 401
        end
      end
      
      context "using the password_hash parameter" do
        should "succeed for password matches" do
          get :index, {:format => "json", :login => @user.name, :password_hash => User.sha1("password")}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          get :index, {:format => "json", :login => @user.name, :password_hash => "bad"}
          assert_response 401
        end
      end
    end

    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end

      context "with a search" do
        should "render" do
          get :index, {:tags => "aaaa"}
          assert_response :success
        end
      end
    end

    context "show action" do
      should "render" do
        get :show, {:id => @post.id}
        assert_response :success
      end
    end

    context "update action" do
      should "work" do
        post :update, {:id => @post.id, :post => {:tag_string => "bbb"}}, {:user_id => @user.id}
        assert_redirected_to post_path(@post)

        @post.reload
        assert_equal("bbb", @post.tag_string)
      end
    end

    context "revert action" do
      setup do
        @post.update_attributes(:tag_string => "zzz")
      end

      should "work" do
        @version = @post.versions(true).first
        assert_equal("aaaa", @version.tags)
        post :revert, {:id => @post.id, :version_id => @version.id}, {:user_id => @user.id}
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaaa", @post.tag_string)
      end
    end
  end
end
