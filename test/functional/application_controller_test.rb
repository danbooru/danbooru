require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  context "The application controller" do
    should "return 406 Not Acceptable for a bad file extension" do
      get posts_path, params: { format: :jpg }
      assert_response 406

      get posts_path, params: { format: :blah }
      assert_response 406
    end

    context "on a RecordNotFound error" do
      should "return 404 Not Found even with a bad file extension" do
        get post_path("bad.json")
        assert_response 404

        get post_path("bad.jpg")
        assert_response 404

        get post_path("bad.blah")
        assert_response 404
      end
    end

    context "on a PaginationError" do
      should "return 410 Gone even with a bad file extension" do
        get posts_path, params: { page: 999999999 }, as: :json
        assert_response 410

        get posts_path, params: { page: 999999999 }, as: :jpg
        assert_response 410

        get posts_path, params: { page: 999999999 }, as: :blah
        assert_response 410
      end
    end

    should "normalize search params" do
      get tags_path, params: { search: { name: "bkub", post_count: "" } }
      assert_redirected_to tags_path(search: { name: "bkub" })
    end
  end
end
