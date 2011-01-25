require "test_helper"

class PostsControllerTest < ActionController::TestCase
  context "The posts controller" do
    setup do
      @users = {}
      @users[:anon] = AnonymousUser.new
      @users[:member] = Factory.create(:user)
      CurrentUser.user = @users[:member]
      CurrentUser.ip_addr = "127.0.0.1"
      @users[:banned] = Factory.create(:banned_user)
      @users[:priv] = Factory.create(:privileged_user)
      @users[:contrib] = Factory.create(:contributor_user)
      @users[:janitor] = Factory.create(:janitor_user)
      @users[:mod] = Factory.create(:moderator_user)
      @users[:admin] = Factory.create(:admin_user)
    end
    
    teardown do
      @users = nil
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @users[:member]}
        assert_response :success
      end
    end
    
    context "create action" do
      should "create a post" do
        post :create, {:post => {:source => "", :file => upload_jpeg("#{Rails.root}/test/files/test.jpg"), :tag_string => "hoge", :rating => "s"}}, {:user_id => @users[:member].id}
        p = Post.last
        assert_equal("hoge", p.tag_string)
        assert_equal("jpg", p.file_ext)
        assert_equal("s", p.rating)
        assert_equal("uploader:#{@users[:member].name}", p.uploader_string)
        assert_equal(true, File.exists?(p.file_path))
        assert_equal(true, File.exists?(p.preview_path))
      end
    end

    context "update action" do
      setup do
        @p1 = Factory.create(:post, :tag_string => "hoge")
      end
      
      should "update a post" do
        put :update, {:post => {:tags => "moge", :rating => "Explicit"}, :id => @p1.id}, {:user_id => @users[:member].id}
        @p1.reload
        assert_equal("moge", p1.cached_tags)
        assert_equal("e", p1.rating)

        assert_equal(2, p1.tag_history.size)
        post :update, {:post => {:rating => "Safe"}, :id => p1.id}, {:user_id => 3}
        assert_equal(3, p1.tag_history.size)

        p1.update_attribute(:is_rating_locked, true)
        post :update, {:post => {:rating => "Questionable"}, :id => p1.id}, {:user_id => 3}
        p1.reload
        assert_equal("s", p1.rating)
      end
    end
    
    should "update a post" do
    end
    
    should "list posts" do
      get :index, {}, {:user_id => 3}
      assert_response :success

      get :index, {:tags => "tag1"}, {:user_id => 3}
      assert_response :success

      get :index, {:format => "json"}, {:user_id => 3}
      assert_response :success

      get :index, {:format => "xml"}, {:user_id => 3}
      assert_response :success

      get :index, {:tags => "-tag1"}, {:user_id => 3}
      assert_response :success
    end
    
    should "list posts through an atom feed" do
      get :atom, {}, {:user_id => 3}
      assert_response :success

      get :atom, {:tags => "tag1"}, {:user_id => 3}
      assert_response :success
    end
    
    should "display a post" do
      get :show, {:id => 1}, {:user_id => 3}
      assert_response :success
    end
  end
  
  def test_popular
    get :popular_by_day, {}, {:user_id => 3}
    assert_response :success
  end
end
