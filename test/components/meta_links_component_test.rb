require "test_helper"

class MetaLinksComponentTest < ViewComponent::TestCase
  context "The MetaLinksComponent" do
    should "expose the adjacent page numbers" do
      create_list(:tag, 10)
      records = Tag.all.paginate(2, limit: 3, page_limit: 100)
      params = ActionController::Parameters.new(controller: "tags", action: "index")
      component = MetaLinksComponent.new(records: records, params: params)

      assert_equal(1, component.prev_page)
      assert_equal(3, component.next_page)
    end
  end
end
