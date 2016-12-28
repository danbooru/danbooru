require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  def setup
    super
    @record = false
    setup_vcr
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

    context "batch action" do
      context "for twitter galleries" do
        should "render" do
          VCR.use_cassette("upload-controller-test/twitter-batch", :record => @vcr_record_option) do
            get :batch, {:url => "https://twitter.com/lvlln/status/567054278486151168"}, {:user_id => @user.id}
          end
          assert_response :success
        end
      end

      context "for a bcy.net gallery" do
        should "render" do
          VCR.use_cassette("upload-controller-test/bcy.net-batch", :record => @vcr_record_option) do
            get :new, {:url => "http://bcy.net/illust/detail/76491/919312"}, {:user_id => @user.id}
            assert_response :success
          end
        end
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "for a twitter post" do
        setup do
          VCR.use_cassette("upload-controller-test/twitter", :record => @vcr_record_option) do
            get :new, {:url => "https://twitter.com/frappuccino/status/566030116182949888"}, {:user_id => @user.id}
          end
        end

        should "render" do
          assert_response :success
        end
      end

      context "for a bcy.net post" do
        should "render" do
          VCR.use_cassette("upload-controller-test/bcy.net", :record => @vcr_record_option) do
            get :new, {:url => "http://bcy.net/illust/detail/76491/919312"}, {:user_id => @user.id}
            assert_response :success
          end
        end
      end

      context "for a post that has already been uploaded" do
        setup do
          @post = FactoryGirl.create(:post, :source => "aaa")
        end

        should "initialize the post" do
          get :new, {:url => "aaa"}, {:user_id => @user.id}
          assert_response :success
          assert_not_nil(assigns(:post))
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
