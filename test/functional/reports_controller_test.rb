require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  context "The reports controller" do
    context "show action" do
      context "posts report" do
        setup do
          @post = create(:post)
        end

        should "work" do
          get report_path("posts")

          assert_response :success
        end

        should "work with the period param" do
          get report_path("posts", search: { period: "month" })

          assert_response :success
        end

        should "work with the group param" do
          get report_path("posts", search: { group: "uploader" })

          assert_response :success
        end

        should "work when filtering by a nested association" do
          get report_path("posts", search: { uploader: { name: @post.uploader.name }})

          assert_response :success
        end
      end
    end
  end
end
