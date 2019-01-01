require 'test_helper'

class TagImplicationsControllerTest < ActionDispatch::IntegrationTest
  context "The tag implications controller" do
    setup do
      @user = create(:admin_user)
    end

    context "edit action" do
      setup do
        as_admin do
          @tag_implication = create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
        end
      end

      should "render" do
        get_auth tag_implication_path(@tag_implication), @user
        assert_response :success
      end
    end

    context "update action" do
      setup do
        as_admin do
          @tag_implication = create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
        end
      end

      context "for a pending implication" do
        setup do
          as_admin do
            @tag_implication.update(status: "pending")
          end
        end

        should "succeed" do
          put_auth tag_implication_path(@tag_implication), @user, params: {:tag_implication => {:antecedent_name => "xxx"}}
          @tag_implication.reload
          assert_equal("xxx", @tag_implication.antecedent_name)
        end

        should "not allow changing the status" do
          put_auth tag_implication_path(@tag_implication), @user, params: {:tag_implication => {:status => "active"}}
          @tag_implication.reload
          assert_equal("pending", @tag_implication.status)
        end
      end

      context "for an approved implication" do
        setup do
          @tag_implication.update_attribute(:status, "approved")
        end

        should "fail" do
          put_auth tag_implication_path(@tag_implication), @user, params: {:tag_implication => {:antecedent_name => "xxx"}}
          @tag_implication.reload
          assert_equal("aaa", @tag_implication.antecedent_name)
        end
      end
    end

    context "index action" do
      setup do
        as_user do
          @tag_implication = create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
        end
      end

      should "list all tag implications" do
        get tag_implications_path
        assert_response :success
      end

      should "list all tag_implications (with search)" do
        get tag_implications_path, params: {:search => {:antecedent_name => "aaa"}}
        assert_response :success
      end
    end

    context "destroy action" do
      setup do
        as_user do
          @tag_implication = create(:tag_implication)
        end
      end

      should "mark the implication as deleted" do
        assert_difference("TagImplication.count", 0) do
          delete_auth tag_implication_path(@tag_implication), @user
          assert_equal("deleted", @tag_implication.reload.status)
        end
      end
    end
  end
end
