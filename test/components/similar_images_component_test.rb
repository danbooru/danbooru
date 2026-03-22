require "test_helper"

class SimilarImagesComponentTest < ViewComponent::TestCase
  context "The SimilarImagesComponent" do
    context "with no matches" do
      should "not render the posts" do
        render_inline(SimilarImagesComponent.new(matches: [], current_user: User.anonymous))

        assert_css(".similar-images-component")
        assert_text("No similar posts found.")
        assert_no_css("a", text: /low similarity match/)
      end
    end

    context "with only high similarity matches" do
      should "render the posts" do
        post = create(:post)
        render_inline(SimilarImagesComponent.new(matches: [{ post: post, score: 80 }], current_user: User.anonymous))

        assert_css(".post-gallery article", count: 1)
        assert_no_text("No similar posts found.")
        assert_no_css("a", text: /low similarity match/)
      end
    end

    context "with only low similarity matches" do
      should "render the posts" do
        post1 = create(:post)
        post2 = create(:post)
        render_inline(SimilarImagesComponent.new(matches: [{ post: post1, score: 10 }, { post: post2, score: 30 }], current_user: User.anonymous))

        assert_css(".post-gallery article", count: 2)
        assert_text("No similar posts found.")
        assert_css("a", text: "Show 2 low similarity matches")
      end
    end

    context "with both high and low similarity matches" do
      should "render both matches and show the low similarity toggle" do
        high_post = create(:post)
        low_post  = create(:post)
        matches = [{ post: high_post, score: 85 }, { post: low_post, score: 10 }]

        render_inline(SimilarImagesComponent.new(matches: matches, current_user: User.anonymous))

        assert_no_text("No similar posts found.")
        assert_css("a", text: "Show 1 low similarity match")
        assert_css(".post-gallery article", count: 2)
      end
    end

    context "with matches below the low similarity threshold" do
      should "not render those matches" do
        post = create(:post)
        render_inline(SimilarImagesComponent.new(matches: [{ post: post, score: -1 }], current_user: User.anonymous))

        assert_text("No similar posts found.")
        assert_css(".post-gallery article", count: 0)
      end
    end
  end
end
