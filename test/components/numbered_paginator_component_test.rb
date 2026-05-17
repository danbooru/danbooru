require "test_helper"

class NumberedPaginatorComponentTest < ViewComponent::TestCase
  context "The NumberedPaginatorComponent" do
    should "render numbered pagination links" do
      create_list(:tag, 10)
      records = Tag.all.paginate(2, limit: 3, page_limit: 100)
      params = ActionController::Parameters.new(controller: "tags", action: "index")

      render_inline(NumberedPaginatorComponent.new(records: records, params: params))

      assert_css(".numbered-paginator")
      assert_css("a.paginator-prev[rel='prev']")
      assert_css("a.paginator-next[rel='next']")
    end
  end
end
