require 'test_helper'

class ArtistsControllerTest < ActionController::TestCase
  def assert_artist_found(expected_artist, source_url)
    VCR.use_cassette("artist-controller-test/#{Digest::SHA1.hexdigest(source_url)}", :record => @vcr_record_option) do
      get :finder, { :format => :json, :url => source_url }, { :user_id => @user.id }
    end

    assert_response :success
    assert_equal(1, assigns(:artists).size, "Testing URL: #{source_url}")
    assert_equal(expected_artist, assigns(:artists).first.name)
  end

  def assert_artist_not_found(source_url)
    VCR.use_cassette("artist-controller-test/#{Digest::SHA1.hexdigest(source_url)}", :record => @vcr_record_option) do
      get :finder, { :format => :json, :url => source_url }, { :user_id => @user.id }
    end

    assert_response :success
    assert_equal(0, assigns(:artists).size, "Testing URL: #{source_url}")
  end

  def setup
    super
    @record = false
    setup_vcr
  end

  context "An artists controller" do
    setup do
      CurrentUser.user = FactoryGirl.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      @artist = FactoryGirl.create(:artist)
      @user = FactoryGirl.create(:user)

      FactoryGirl.create(:artist, :name => "masao",   :url_string => "http://i2.pixiv.net/img04/img/syounen_no_uta/")
      FactoryGirl.create(:artist, :name => "artgerm", :url_string => "http://artgerm.deviantart.com/")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "get the new page" do
      get :new, {}, {:user_id => @user.id}
      assert_response :success
    end

    should "get the edit page" do
      get :edit, {:id => @artist.id}, {:user_id => @user.id}
      assert_response :success
    end

    should "get the show page" do
      get :show, {:id => @artist.id}
      assert_response :success
    end

    should "get the show page for a negated tag" do
      @artist.update_attribute(:name, "-aaa")
      get :show, {:id => @artist.id}
      assert_response :success
    end

    should "get the index page" do
      get :index
      assert_response :success
    end

    context "when searching the index page" do
      should "find artists by name" do
        get :index, { :name => "masao" }

        assert_response :success
        assert_equal(1, assigns(:artists).size)
        assert_equal("masao", assigns(:artists).first.name)
      end

      should "find artists by image URL" do
        get :index, { :name => "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_m.jpg" }

        assert_response :success
        assert_equal(1, assigns(:artists).size)
        assert_equal("masao", assigns(:artists).first.name)
      end

      should "find artists by page URL" do
        url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939"
        VCR.use_cassette("artist-controller-test/#{Digest::SHA1.hexdigest(url)}", :record => @vcr_record_option) do
          get :index, { :name => url }
        end

        assert_response :success
        assert_equal(1, assigns(:artists).size)
        assert_equal("masao", assigns(:artists).first.name)
      end
    end

    should "create an artist" do
      assert_difference("Artist.count", 1) do
        attributes = FactoryGirl.attributes_for(:artist)
        attributes.delete(:is_active)
        post :create, {:artist => attributes}, {:user_id => @user.id}
      end
      artist = Artist.last
      assert_redirected_to(artist_path(artist))
    end

    should "update an artist" do
      post :update, {:id => @artist.id, :artist => {:name => "xxx"}}, {:user_id => @user.id}
      @artist.reload
      assert_equal("xxx", @artist.name)
      assert_redirected_to(artist_path(@artist))
    end

    context "when renaming an artist" do
      should "automatically rename the artist's wiki page" do
        artist = FactoryGirl.create(:artist, :name => "aaa", :notes => "testing")
        wiki_page = artist.wiki_page
        assert_difference("WikiPage.count", 0) do
          post :update, {:id => artist.id, :artist => {:name => "bbb", :notes => "more testing"}}, {:user_id => @user.id}
        end
        wiki_page.reload
        assert_equal("bbb", wiki_page.title)
        assert_equal("more testing", wiki_page.body)
      end

      should "merge the new notes with the existing wiki page's contents if a wiki page for the new name already exists" do
        artist = FactoryGirl.create(:artist, :name => "aaa")
        existing_wiki_page = FactoryGirl.create(:wiki_page, :title => "bbb", :body => "xxx")
        post :update, {:id => artist.id, :artist => {:name => "bbb", :notes => "yyy"}}, {:user_id => @user.id}
        existing_wiki_page.reload
        assert_equal("bbb", existing_wiki_page.title)
        assert_equal("xxx\n\nyyy", existing_wiki_page.body)
      end
    end

    context "reverting an artist" do
      should "work" do
        @artist.update_attributes(:name => "xyz")
        @artist.update_attributes(:name => "abc")
        version = @artist.versions.first
        post :revert, {:id => @artist.id, :version_id => version.id}
      end

      should "not allow reverting to a previous version of another artist" do
        @artist2 = FactoryGirl.create(:artist)

        post :revert, { :id => @artist.id, :version_id => @artist2.versions(true).first.id }, {:user_id => @user.id}
        @artist.reload

        assert_not_equal(@artist.name, @artist2.name)
        assert_response :missing
      end
    end

    context "when finding an artist" do
      should "find nothing for unknown URLs" do
        assert_artist_not_found("http://www.example.com")
      end

      should "find deviantart artists" do
        assert_artist_found("artgerm", "http://artgerm.deviantart.com/art/Peachy-Princess-Ver-2-457220550")
      end

      should_eventually "find deviantart artists for image URLs" do
        assert_artist_found("artgerm", "http://fc06.deviantart.net/fs71/f/2014/150/d/c/peachy_princess_by_artgerm-d7k7tmu.jpg")
      end

      should "find pixiv artists" do
        assert_artist_found("masao", "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939.jpg")
        assert_artist_found("masao", "http://i2.pixiv.net/img-original/img/2014/09/25/00/57/24/46170939_p0.jpg")
        assert_artist_found("masao", "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46170939")
      end

      should "not fail for malformed Pixiv URLs" do
        assert_artist_not_found("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=herpderp")
        assert_artist_not_found("http://www.pixiv.net/wharrgarbl")
      end

      should "not fail for Pixiv bad IDs" do
        assert_artist_not_found("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=0")
      end
    end
  end
end
