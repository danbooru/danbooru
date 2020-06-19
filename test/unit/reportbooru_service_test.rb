require 'test_helper'

class ReportbooruServiceTest < ActiveSupport::TestCase
  def setup
    @service = ReportbooruService.new(reportbooru_server: "http://localhost:1234")
    @post = create(:post)
    @date = Date.parse("2000-01-01")
  end

  context "#popular_posts" do
    should "return the list of popular posts on success" do
      mock_post_view_rankings(@date, [[@post.id, 100]])

      posts = @service.popular_posts(@date)
      assert_equal([@post], posts)
    end

    should "return nothing on failure" do
      Danbooru::Http.any_instance.expects(:get).with("http://localhost:1234/post_views/rank?date=#{@date}").returns(HTTP::Response.new(status: 500, body: "", version: "1.1"))
      Danbooru::Http.any_instance.expects(:get).with("http://localhost:1234/post_views/rank?date=#{@date.yesterday}").returns(HTTP::Response.new(status: 500, body: "", version: "1.1"))

      assert_equal([], @service.popular_posts(@date))
    end
  end
end
