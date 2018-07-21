require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  context "The posts controller" do
    setup do
      PopularSearchService.stubs(:enabled?).returns(false)
      
      @user = travel_to(1.month.ago) {create(:user)}
      as_user do
        @post = create(:post, :tag_string => "aaaa")
      end
    end
    
    context "for api calls" do
      setup do
        @api_key = ApiKey.generate!(@user)
      end

      context "passing the api limit" do
        setup do
          as_user do
            @post = create(:post)
          end
          TokenBucket.any_instance.stubs(:throttled?).returns(true)
          @bucket = TokenBucket.create(user_id: @user.id, token_count: 0, last_touched_at: Time.now)
        end
        
        should "work" do
          put post_path(@post), params: {:format => "json", :post => {:rating => "q"}, :login => @user.name, :api_key => @user.api_key.key}
          assert_response 429
        end
      end
      
      context "using http basic auth" do
        should "succeed for password matches" do
          @basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get posts_path, params: {:format => "json"}, headers: {'HTTP_AUTHORIZATION' => @basic_auth_string}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          @basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:badpassword")}"
          get posts_path, params: {:format => "json"}, headers: {'HTTP_AUTHORIZATION' => @basic_auth_string}
          assert_response 401
        end
      end
      
      context "using the api_key parameter" do
        should "succeed for password matches" do
          get posts_path, params: {:format => "json", :login => @user.name, :api_key => @api_key.key}
          assert_response :success
        end
        
        should "fail for password mismatches" do
          get posts_path, params: {:format => "json", :login => @user.name, :api_key => "bad"}
          assert_response 401
        end
      end
      
      context "using the password_hash parameter" do
        should "succeed for password matches" do
          get posts_path, params: {:format => "json", :login => @user.name, :password_hash => User.sha1("password")}
          assert_response :success
        end
        
        # should "fail for password mismatches" do
        #   get posts_path, {:format => "json", :login => @user.name, :password_hash => "bad"}
        #   assert_response 403
        # end
      end
    end

    context "index action" do
      should "render" do
        get posts_path
        assert_response :success
      end

      context "with a search" do
        should "render" do
          get posts_path, params: {:tags => "aaaa"}
          assert_response :success
        end
      end

      context "with an md5 param" do
        should "render" do
          get posts_path, params: { md5: @post.md5 }
          assert_redirected_to(@post)
        end
      end
    end

    context "show_seq action" do
      should "render" do
        posts = FactoryBot.create_list(:post, 3)

        get show_seq_post_path(posts[1].id), params: { seq: "prev" }
        assert_redirected_to(posts[2])

        get show_seq_post_path(posts[1].id), params: { seq: "next" }
        assert_redirected_to(posts[0])
      end
    end

    context "random action" do
      should "render" do
        get random_posts_path, params: { tags: "aaaa" }
        assert_redirected_to(post_path(@post, tags: "aaaa"))
      end
    end

    context "show action" do
      should "render" do
        get post_path(@post), params: {:id => @post.id}
        assert_response :success
      end

      context "when the recommend service is enabled" do
        setup do
          @post2 = create(:post)
          RecommenderService.stubs(:enabled?).returns(true)
          RecommenderService.stubs(:available_for_post?).returns(true)
        end

        should "not error out" do
          get_auth post_path(@post), @user
          assert_response :success
        end
      end
    end

    context "update action" do
      should "work" do
        put_auth post_path(@post), @user, params: {:post => {:tag_string => "bbb"}}
        assert_redirected_to post_path(@post)

        @post.reload
        assert_equal("bbb", @post.tag_string)
      end

      should "ignore restricted params" do
        put_auth post_path(@post), @user, params: {:post => {:last_noted_at => 1.minute.ago}}
        assert_nil(@post.reload.last_noted_at)
      end
    end

    context "revert action" do
      setup do
        PostArchive.sqs_service.stubs(:merge?).returns(false)
        as_user do
          @post.update(tag_string: "zzz")
        end
      end

      should "work" do
        @version = @post.versions.first
        assert_equal("aaaa", @version.tags)
        put_auth revert_post_path(@post), @user, params: {:version_id => @version.id}
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaaa", @post.tag_string)
      end

      should "not allow reverting to a previous version of another post" do
        as_user do
          @post2 = create(:post, :uploader_id => @user.id, :tag_string => "herp")
        end

        put_auth revert_post_path(@post), @user, params: { :version_id => @post2.versions.first.id }
        @post.reload
        assert_not_equal(@post.tag_string, @post2.tag_string)
        assert_response :missing
      end
    end
  end
end
