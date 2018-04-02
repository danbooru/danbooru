require 'test_helper'

class PostViewCountServiceTest < ActiveSupport::TestCase
  def setup
    super

    CurrentUser.user = FactoryBot.create(:user)
    CurrentUser.ip_addr = "127.0.0.1"

    PostViewCountService.stubs(:enabled?).returns(true)
    Danbooru.config.stubs(:reportbooru_server).returns("http://localhost:1234")
    @post = FactoryBot.create(:post)
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  subject { PostViewCountService.new }

  context "#popular_posts" do
    setup do
      subject.stubs(:fetch_rank).returns([[@post.id, 1]])
    end
    
    should "return the posts" do
      posts = subject.popular_posts
      assert_equal(@post.id, posts[0].id)
    end
  end

  context "#fetch_rank" do
    context "success" do
      setup do
        @date = "2000-01-01"
        @body = "[[1,1.0],[2,2.0]]"
        stub_request(:get, "localhost:1234/post_views/rank").with(query: {"date" => @date}).to_return(body: @body)
      end

      should "return a list" do
        json = subject.fetch_rank(@date)
        assert(json.is_a?(Array))
        assert_equal(1, json[0][0])
        assert_equal(2, json[1][0])
      end
    end

    context "failure" do
      setup do
        @date = "2000-01-01"
        stub_request(:get, "localhost:1234/post_views/rank").with(query: {"date" => @date}).to_return(body: "", status: 400)
      end

      should "return nil" do
        json = subject.fetch_rank(@date)
        assert_nil(json)
      end
    end
  end

  context "#fetch_count" do
    context "success" do
      setup do
        @body = "[[1,5],[2,20]]"
        stub_request(:get, "localhost:1234/post_views/#{@post.id}").to_return(body: @body)
      end

      should "return a list" do
        json = subject.fetch_count(@post.id)
        assert(json.is_a?(Array))
        assert_equal(1, json[0][0])
        assert_equal(2, json[1][0])
      end
    end

    context "failure" do
      setup do
        stub_request(:get, "localhost:1234/post_views/#{@post.id}").to_return(body: "", status: 400)
      end

      should "return nil" do
        json = subject.fetch_count(@post.id)
        assert_nil(json)
      end
    end
  end
end
