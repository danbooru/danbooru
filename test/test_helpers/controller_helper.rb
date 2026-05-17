module ControllerHelper
  # A custom Shoulda matcher that tests that a controller's index endpoint returns the expected items for a given search.
  # See https://thoughtbot.com/blog/shoulda-matchers.
  #
  # Usage:
  #
  #   subject { CommentsController }
  #   setup do
  #     @user = create(:user)
  #     @comment = create(:comment, creator: @user, body: "blah")
  #   end
  #
  #   # Static search params.
  #   should respond_to_search(body_matches: "blah").with { [@comment] }
  #
  #   # Dynamic search params from test instance variables.
  #   should respond_to_search(creator_id: -> { @user.id }).with { [@comment] }
  #
  #   # Add non-search query params.
  #   should respond_to_search(body_matches: "blah").params(group_by: "comment").with { [@comment] }
  #
  #   # Set the user making the request.
  #   should respond_to_search(body_matches: "blah").as_user { @user }.with { [@comment] }
  #
  # @param search_params [Hash] The params to use for the search (e.g. `respond_to_search(body: "blah")` -> `search[body]=blah`).
  # @return [RespondToSearchMatcher] A Shoulda matcher that tests that the controller returns the expected items for the given search.
  def respond_to_search(search_params = {})
    RespondToSearchMatcher.new(search_params)
  end

  class RespondToSearchMatcher
    attr_accessor :params, :expected_block, :current_user_block

    # @param search_params [Hash] The params to use for the search (e.g. `respond_to_search(body: "blah")` -> `search[body]=blah`).
    def initialize(search_params)
      @params = { search: search_params }.compact_blank
      @expected_block = nil
      @current_user_block = proc { User.anonymous }
    end

    # @return [String] A description of the test, used as the name of the test case.
    def description
      caller = caller_locations[1] # Shoulda::Context::Context#should -> actual caller
      description = "respond to a search"
      description += " for #{@params.inspect}" if @params.present?
      description += " (#{File.basename(caller.path)}:#{caller.lineno})"
      description
    end

    # Called by Shoulda to perform the test.
    # @param subject [Class] The controller class being tested (e.g. `CommentsController`).
    def matches?(subject)
      params = @params
      expected_block = @expected_block
      current_user_block = @current_user_block

      raise ArgumentError, "respond_to_search(...).with { [...] } must be called to set the expected return value" unless expected_block.present?

      # This code is executed with `self` set to `test_case` so that we have access to the instance variables defined by
      # the `setup` block of the test. Inside this block, `@foo` means the test case's `@foo`, not our `@foo`.
      @test_case.instance_exec do
        current_user = instance_exec(&current_user_block)
        expected_items = Array(instance_exec(&expected_block))
        params = params.deep_transform_values do |value|
          value.is_a?(Proc) ? instance_exec(&value) : value
        end

        # calls e.g. "wiki_pages_path" if we're in WikiPagesControllerTest.
        index_url = send("#{subject.controller_path}_path", **params)
        get_auth index_url, current_user, as: :json

        assert_response :success
        assert_equal(expected_items.map(&:id), response.parsed_body.pluck("id"))
      end
    end

    # @param search_params [Hash<String, String>] Additional params for the search.
    # @return [RespondToSearchMatcher] A new matcher with the given search params.
    def search_params(**search_params)
      dup.tap { it.params = params.deep_merge(search: search_params) }
    end

    # @param extra_params [Hash<String, String>] Additional top-level params for the search.
    # @return [RespondToSearchMatcher] A new matcher with the given extra params.
    def with_params(**extra_params)
      dup.tap { it.params = params.deep_merge(extra_params) }
    end

    # @yieldreturn [ActiveRecord::Base, Array<ActiveRecord::Base>] A block that returns the items that are expected to
    #   be returned by the search (e.g. `respond_to_search(...).with { [@comment] }`).
    # @return [RespondToSearchMatcher] A new matcher with the given expected values.
    def with(&block)
      dup.tap { it.expected_block = block }
    end

    # @yieldreturn [User] A block that returns the user performing the search (e.g. `respond_to_search(...).as_user { @user }`).
    # @return [RespondToSearchMatcher] A new matcher with the given user.
    def as_user(&block)
      dup.tap { it.current_user_block = block }
    end

    # Called by Shoulda just before the test is performed to set the context of the test case.
    def in_context(test_case)
      @test_case = test_case
    end
  end
end
