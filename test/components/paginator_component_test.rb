require "test_helper"

class PaginatorComponentTest < ViewComponent::TestCase
  def render_paginator(variant, page, limit: 3, page_limit: 100)
    with_variant(variant) do
      tags = Tag.paginate(page, limit: limit, page_limit: page_limit)
      params = ActionController::Parameters.new(controller: :tags, action: :index)
      return render_inline(PaginatorComponent.new(records: tags, params: params))
    end
  end

  def assert_page(expected_page, link)
    href = link.attr("href").value
    uri = Addressable::URI.parse(href)
    page = uri.query_values["page"]

    assert_equal(expected_page, page)
  end

  context "The PaginatorComponent" do
    setup do
      @tags = create_list(:tag, 10)
    end

    context "when using sequential pagination" do
      should "work with an aN page" do
        html = render_paginator(:sequential, "a#{@tags[5].id}", limit: 3)

        assert_page("a#{@tags[5+3].id}", html.css("a[rel=prev]"))
        assert_page("b#{@tags[5+1].id}", html.css("a[rel=next]"))
      end

      should "work with a bN page" do
        html = render_paginator(:sequential, "b#{@tags[5].id}", limit: 3)

        assert_page("a#{@tags[5-1].id}", html.css("a[rel=prev]"))
        assert_page("b#{@tags[5-3].id}", html.css("a[rel=next]"))
      end
    end

    context "when using numbered pagination" do
      should "work for page 1" do
        html = render_paginator(:numbered, 1, limit: 3)

        assert_css("span.paginator-prev")
        assert_page("2", html.css("a.paginator-next"))
      end

      should "work for page 2" do
        html = render_paginator(:numbered, 2, limit: 3)

        assert_page("1", html.css("a.paginator-prev"))
        assert_page("3", html.css("a.paginator-next"))
      end

      should "work for page 4" do
        html = render_paginator(:numbered, 4, limit: 3)

        assert_page("3", html.css("a.paginator-prev"))
        assert_css("span.paginator-next")
      end
    end
  end
end
