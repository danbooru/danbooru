require "test_helper"

class PaginatorComponentTest < ViewComponent::TestCase
  def render_paginator(variant, records, page: 1, limit: 3, page_limit: 100)
    with_variant(variant) do
      records = records.paginate(page, limit: limit, page_limit: page_limit)
      params = ActionController::Parameters.new(controller: records.model_name.plural, action: :index)
      return render_inline(PaginatorComponent.new(records: records, params: params))
    end
  end

  def assert_page(expected_page, link)
    href = link.attr("href").value
    uri = Addressable::URI.parse(href)
    page = uri.query_values["page"]

    assert_equal(expected_page, page)
  end

  context "The PaginatorComponent" do
    context "when using sequential pagination" do
      setup do
        @tags = create_list(:tag, 10)
      end

      should "work with an aN page" do
        html = render_paginator(:sequential, Tag.all, page: "a#{@tags[5].id}", limit: 3)

        assert_page("a#{@tags[5+3].id}", html.css("a[rel=prev]"))
        assert_page("b#{@tags[5+1].id}", html.css("a[rel=next]"))
      end

      should "work with a bN page" do
        html = render_paginator(:sequential, Tag.all, page: "b#{@tags[5].id}", limit: 3)

        assert_page("a#{@tags[5-1].id}", html.css("a[rel=prev]"))
        assert_page("b#{@tags[5-3].id}", html.css("a[rel=next]"))
      end
    end

    context "when using numbered pagination" do
      context "for a search with 10 results" do
        setup do
          @tags = create_list(:tag, 10)
        end

        should "work for page 1" do
          html = render_paginator(:numbered, Tag.all, page: 1, limit: 3)

          assert_css("span.paginator-prev")
          assert_page("2", html.css("a.paginator-next"))
        end

        should "work for page 2" do
          html = render_paginator(:numbered, Tag.all, page: 2, limit: 3)

          assert_page("1", html.css("a.paginator-prev"))
          assert_page("3", html.css("a.paginator-next"))
        end

        should "work for page 4" do
          html = render_paginator(:numbered, Tag.all, page: 4, limit: 3)

          assert_page("3", html.css("a.paginator-prev"))
          assert_css("span.paginator-next")
        end
      end

      context "for a search with zero results" do
        should "work for page 1" do
          html = render_paginator(:numbered, Tag.none, page: 1, limit: 3)

          assert_css("span.paginator-current", text: "1")
          assert_css("span.paginator-prev")
          assert_css("span.paginator-next")
          assert_css("span", count: 3)
        end
      end

      context "for a search with an unknown number of pages" do
        should "show the unlimited paginator" do
          @tags = Tag.all
          @tags.stubs(:total_count).returns(Float::INFINITY)
          html = render_paginator(:numbered, @tags, page: 1, limit: 200)

          assert_css("span.paginator-current", text: "1")
          assert_css("span.paginator-prev")
          assert_css("a.paginator-next")
          assert_css(".paginator a.paginator-page", count: 4, visible: :all)
        end
      end
    end
  end
end
