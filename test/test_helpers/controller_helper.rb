module ControllerHelper
  # A custom Shoulda matcher that tests that a controller's index endpoint
  # responds to a search correctly. See https://thoughtbot.com/blog/shoulda-matchers.
  #
  # Usage:
  #
  #   # Tests that `/tags.json?search[name]=touhou` returns the `touhou` tag.
  #   subject { TagsController }
  #   setup { @touhou = create(:tag, name: "touhou") }
  #   should respond_to_search(name: "touhou").with { @touhou }
  #
  def respond_to_search(search_params)
    RespondToSearchMatcher.new(search_params)
  end

  class RespondToSearchMatcher < Struct.new(:params)
    def description
      "should respond to a search for #{params}"
    end

    def matches?(subject, &block)
      search_params = { search: params }
      expected_items = @test_case.instance_eval(&@expected)

      @test_case.instance_eval do
        # calls e.g. "wiki_pages_path" if we're in WikiPagesControllerTest.
        index_url = send("#{subject.controller_path}_path")
        get index_url, as: :json, params: search_params

        expected_ids = Array(expected_items).map(&:id)
        responded_ids = response.parsed_body.map { |item| item["id"] }

        assert_response :success
        assert_equal(expected_ids, responded_ids)
      end
    end

    def with(&block)
      @expected = block
      self
    end

    def in_context(test_case)
      @test_case = test_case
    end
  end
end
