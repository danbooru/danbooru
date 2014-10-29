require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  def assert_duplicate_found(expected_source, test_source)
    get :new, { :url => test_source }, { :user_id => @user.id }

    assert_response :success
    assert_not_nil(assigns(:post))
    assert_equal(expected_source, assigns(:post).source)
  end

  def assert_duplicate_not_found(test_source)
    get :new, { :url => test_source }, { :user_id => @user.id }

    assert_response :success
    assert_nil(assigns(:post))
  end

  context "The uploads controller" do
    setup do
      @user = FactoryGirl.create(:contributor_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "for a post that has already been uploaded" do
        setup do
          @dupe1 = "http://site1.com"
          @dupe2 = "http://site2.com"

          FactoryGirl.create(:post, :source => @dupe1)
          FactoryGirl.create(:post, :source => @dupe2)
        end

        should "find the post" do
          assert_duplicate_found(@dupe1, "http://site1.com")
          assert_duplicate_found(@dupe2, "http://site2.com")
          assert_duplicate_not_found("http://site3.com")
        end
      end

      context "for a Pixiv post that has already been uploaded" do
        setup do
          @dupe1 = "http://i2.pixiv.net/img-original/img/2014/10/18/16/52/44/40456235_p63.jpg"
          @dupe2 = "http://i3.pixiv.net/img-original/img/2014/10/18/16/52/44/40456235_p0.jpg"

          FactoryGirl.create(:post, :source => @dupe1)
          FactoryGirl.create(:post, :source => @dupe2)
        end

        should "find the duplicate post" do
          VCR.use_cassette("upload-pixiv-dupes", :record => :none) do
            assert_duplicate_found(@dupe1, "http://i4.pixiv.net/img-original/img/2014/10/18/16/52/44/40456235_p63.jpg")
            assert_duplicate_found(@dupe2, "http://i1.pixiv.net/img-original/img/2014/10/18/16/52/44/40456235_p0.jpg")
          end
        end
      end

      context "for a FC2 post that has already been uploaded" do
        setup do
          @dupe1 = "http://newrp.blog34.fc2.com/img/fc2blog_20140718045830c1a.jpg/"
          @dupe2 = "http://blog-imgs-58-origin.fc2.com/t/e/n/tenchisouha/ratifa01.jpg"

          FactoryGirl.create(:post, :source => @dupe1)
          FactoryGirl.create(:post, :source => @dupe2)
        end

        should "find the duplicate post" do
          assert_duplicate_found(@dupe1, "http://newrp.blog123.fc2.com/img/fc2blog_20140718045830c1a.jpg/")
          assert_duplicate_found(@dupe1, "http://newrp.blog.fc2.com/img/fc2blog_20140718045830c1a.jpg/")

          assert_duplicate_found(@dupe2, "http://blog-imgs-58.fc2.com/t/e/n/tenchisouha/ratifa01.jpg")
          assert_duplicate_found(@dupe2, "http://blog-imgs-58-origin.fc2.com/t/e/n/tenchisouha/ratifa01.jpg")

          assert_duplicate_not_found("http://blog.fc2.com/m/mueyama/file/20060911-640.jpg")
          assert_duplicate_not_found("http://blog-imgs-63.fc2.com/p/u/c/pucco2/2032gou(2).jpg")
          assert_duplicate_not_found("http://flanvia.blog.fc2.com/img/20140306184507199.png/")
          assert_duplicate_not_found("http://diary1.fc2.com/user/hitorigoto3/img/2011_9/25.jpg")
          assert_duplicate_not_found("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2014&M=10&D=26")
        end
      end
    end

    context "index action" do
      setup do
        @upload = FactoryGirl.create(:source_upload)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get :index, {:search => {:source => @upload.source}}, {:user_id => @user.id}
          assert_response :success
        end
      end
    end

    context "show action" do
      setup do
        @upload = FactoryGirl.create(:jpg_upload)
      end

      should "render" do
        get :show, {:id => @upload.id}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new upload" do
        assert_difference("Upload.count", 1) do
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          file.stubs(:tempfile).returns(file)
          post :create, {:upload => {:file => file, :tag_string => "aaa", :rating => "q", :source => "aaa"}}, {:user_id => @user.id}
        end
      end
    end

    context "update action" do
      setup do
        @upload = FactoryGirl.create(:jpg_upload)
      end

      should "process an unapproval" do
        post :update, {:id => @upload.id}, {:user_id => @user.id}
        @upload.reload
        assert_equal("completed", @upload.status)
      end
    end
  end
end
