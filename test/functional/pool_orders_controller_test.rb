require 'test_helper'

class PoolOrdersControllerTest < ActionDispatch::IntegrationTest
  context "The pool orders controller" do
    context "edit action" do
      should "render" do
        user = create(:user)

        as(user) do
          posts = create_list(:post, 3)
          pool = create(:pool)
          posts.each { |p| pool.add!(p) }

          get_auth edit_pool_order_path(pool), user
          assert_response :success
          assert_select "article.post-preview", 3
        end
      end
    end
  end
end
