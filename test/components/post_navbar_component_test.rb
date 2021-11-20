require "test_helper"

class PostNavbarComponentTest < ViewComponent::TestCase
  def render_post_navbar(post, **options)
    render_inline(PostNavbarComponent.new(post: post, **options))
  end

  setup do
    @post = create(:post)
    @user = create(:gold_user)
  end

  context "The PostNavbarComponent" do
    context "for a post with a search" do
      should "render" do
        render_post_navbar(@post, current_user: @user, search: "touhou")

        assert_css(".search-navbar", text: "Search: touhou")
      end
    end

    context "for a post with pools" do
      setup do
        as(@user) do
          @pool1 = create(:pool, category: "series")
          @pool2 = create(:pool, category: "collection")
          @post.update(tag_string: "pool:#{@pool1.id} pool:#{@pool2.id}")
        end
      end

      should "render" do
        render_post_navbar(@post, current_user: @user)

        assert_css(".pool-name", text: "Pool: #{@pool1.pretty_name}")
        assert_css(".pool-name", text: "Pool: #{@pool2.pretty_name}")
      end

      should "highlight the selected pool" do
        render_post_navbar(@post, current_user: @user, search: "pool:#{@pool1.id}")

        assert_css(".pool-navbar[data-selected=true] .pool-name", text: "Pool: #{@pool1.pretty_name}")
        assert_css(".pool-navbar[data-selected=false] .pool-name", text: "Pool: #{@pool2.pretty_name}")
      end
    end

    context "for a post with favgroups" do
      setup do
        as(@user) do
          @favgroup1 = create(:favorite_group, creator: @user, post_ids: [@post.id])
          @favgroup2 = create(:private_favorite_group, creator: @user, post_ids: [@post.id])
        end
      end

      should "render" do
        render_post_navbar(@post, current_user: @user, search: "favgroup:#{@favgroup1.id}")

        assert_css(".favgroup-name", text: "Favgroup: #{@favgroup1.pretty_name}")
        assert_css(".favgroup-name", text: "Favgroup: #{@favgroup2.pretty_name}")
      end

      should "highlight the selected favgroup" do
        render_post_navbar(@post, current_user: @user, search: "favgroup:#{@favgroup1.id}")

        assert_css(".favgroup-navbar[data-selected=true] .favgroup-name", text: "Favgroup: #{@favgroup1.pretty_name}")
        assert_css(".favgroup-navbar[data-selected=false] .favgroup-name", text: "Favgroup: #{@favgroup2.pretty_name}")
      end

      should "show public favgroups that belong to another user when doing a favgroup:<id> search" do
        render_post_navbar(@post, current_user: create(:user), search: "favgroup:#{@favgroup1.id}")

        assert_css(".favgroup-navbar[data-selected=true] .favgroup-name", text: "Favgroup: #{@favgroup1.pretty_name}")
      end

      should "not show private favgroups that belong to another user when doing a favgroup:<id> search" do
        render_post_navbar(@post, current_user: create(:user), search: "favgroup:#{@favgroup2.id}")

        assert_css(".favgroup-navbar .favgroup-name", count: 0)
      end
    end
  end
end
