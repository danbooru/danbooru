require "test_helper"

class PostsControllerTest < ActionController::TestCase
  context "The posts controller" do
    setup do
      @user = Timecop.travel(1.month.ago) {FactoryGirl.create(:user)}
      @api_key = ApiKey.generate!(@user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = FactoryGirl.create(:post, :uploader_id => @user.id, :tag_string => "aaaa")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "for api calls" do
      context "passing the api limit" do
        setup do
          @post = FactoryGirl.create(:post)
          @bucket = TokenBucket.create(user_id: @user.id, token_count: 5, last_touched_at: Time.now)
          User.any_instance.stubs(:api_burst_limit).returns(5)
          User.any_instance.stubs(:api_regen_multiplier).returns(0)
        end
        
        should "work" do
          @user.api_burst_limit.times do
            post :update, {:format => "json", :id => @post.id, :post => {:rating => "q"}, :login => @user.name, :api_key => @user.api_key.key}
            assert_response :success
          end

          post :update, {:format => "json", :id => @post.id, :post => {:rating => "q"}, :login => @user.name, :api_key => @user.api_key.key}
          assert_response 429
        end
      end
      
      context "using http basic auth" do
        should "succeed for password matches" do
          @basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          @request.env['HTTP_AUTHORIZATION'] = @basic_auth_string
          get :index, {:format => "json"}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          @basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:badpassword")}"
          @request.env['HTTP_AUTHORIZATION'] = @basic_auth_string
          get :index, {:format => "json"}
          assert_response 401
        end
      end
      
      context "using the api_key parameter" do
        should "succeed for password matches" do
          get :index, {:format => "json", :login => @user.name, :api_key => @api_key.key}
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
        
        # should "fail for password mismatches" do
        #   get :index, {:format => "json", :login => @user.name, :password_hash => "bad"}
        #   assert_response 403
        # end
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

      context "with an md5 param" do
        should "render" do
          get :index, { md5: @post.md5 }
          assert_redirected_to(@post)
        end
      end
    end

    context "show_seq action" do
      should "render" do
        posts = FactoryGirl.create_list(:post, 3)

        get :show_seq, { seq: "prev", id: posts[1].id }
        assert_redirected_to(posts[2])

        get :show_seq, { seq: "next", id: posts[1].id }
        assert_redirected_to(posts[0])
      end
    end

    context "random action" do
      should "render" do
        get :random, { tags: "aaaa" }
        assert_redirected_to(post_path(@post, tags: "aaaa"))
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

      should "ignore restricted params" do
        post :update, {:id => @post.id, :post => {:last_noted_at => 1.minute.ago}}, {:user_id => @user.id}
        assert_nil(@post.reload.last_noted_at)
      end
    end

    context "revert action" do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        @post.update_attributes(:tag_string => "zzz")
      end

      should "work" do
        @version = @post.versions.first
        assert_equal("aaaa", @version.tags)
        post :revert, {:id => @post.id, :version_id => @version.id}, {:user_id => @user.id}
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaaa", @post.tag_string)
      end

      should "not allow reverting to a previous version of another post" do
        @post2 = FactoryGirl.create(:post, :uploader_id => @user.id, :tag_string => "herp")

        post :revert, { :id => @post.id, :version_id => @post2.versions.first.id }, {:user_id => @user.id}
        @post.reload

        assert_not_equal(@post.tag_string, @post2.tag_string)
        assert_response :missing
      end
    end
  end
end
