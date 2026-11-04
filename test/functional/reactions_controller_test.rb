require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  context "The reactions controller" do
    setup do
      @user = create(:user)
      @public_post = create(:forum_post)
      @hidden_post = create(:forum_post, topic: create(:mod_up_forum_topic))

      # Reactions are disabled by default, so skip the reaction_id validation.
      @public_reaction = Reaction.new(creator: @user, model: @public_post, reaction_id: "like").tap { it.save!(validate: false) }
      @hidden_reaction = Reaction.new(creator: @user, model: @hidden_post, reaction_id: "like").tap { it.save!(validate: false) }
    end

    context "index action" do
      should "not show reactions on forum posts the user can't see" do
        get_auth reactions_path(only: "id,model[body]"), @user, as: :json

        assert_response :success
        assert_equal([@public_reaction.id], response.parsed_body.pluck("id"))
      end

      should "show reactions on hidden forum posts to users who can see them" do
        get_auth reactions_path(only: "id,model[body]"), create(:moderator_user), as: :json

        assert_response :success
        assert_equal([@hidden_reaction.id, @public_reaction.id], response.parsed_body.pluck("id"))
        assert_equal(@hidden_post.body, response.parsed_body.first.dig("model", "body"))
      end
    end

    context "show action" do
      should "not show reactions on forum posts the user can't see" do
        get_auth reaction_path(@hidden_reaction, only: "id,model[body]"), @user, as: :json

        assert_response 404
      end

      should "show reactions on forum posts the user can see" do
        get_auth reaction_path(@public_reaction, only: "id,model[body]"), @user, as: :json

        assert_response :success
        assert_equal(@public_post.body, response.parsed_body.dig("model", "body"))
      end
    end
  end
end
