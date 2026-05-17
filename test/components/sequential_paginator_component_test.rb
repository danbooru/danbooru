require "test_helper"

class SequentialPaginatorComponentTest < ViewComponent::TestCase
  context "The SequentialPaginatorComponent" do
    should "render previous and next links" do
      create_list(:tag, 10)
      records = Tag.all.paginate(2, limit: 3, page_limit: 100)
      params = ActionController::Parameters.new(controller: "tags", action: "index")

      render_inline(SequentialPaginatorComponent.new(records: records, params: params))

      assert_css(".sequential-paginator")
      assert_css("a.paginator-prev[rel='prev']")
      assert_css("a.paginator-next[rel='next']")
    end
  end
end
