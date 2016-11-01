require 'test_helper'

class PostApprovalTest < ActiveSupport::TestCase
	context "a pending post" do
		setup do
			@user = FactoryGirl.create(:user)
			CurrentUser.user = @user
			CurrentUser.ip_addr = "127.0.0.1"

			@post = FactoryGirl.create(:post, uploader_id: @user.id, is_pending: true)

			@approver = FactoryGirl.create(:user)
			@approver.can_approve_posts = true
			@approver.save
			CurrentUser.user = @approver

			CurrentUser.stubs(:can_approve_posts?).returns(true)
		end

		teardown do
			CurrentUser.user = nil
			CurrentUser.ip_addr = nil
		end

		should "allow approval" do
			assert_equal(false, PostApproval.approved?(@approver.id, @post.id))
		end

		context "That is approved" do
			should "create a postapproval record" do
				assert_difference("PostApproval.count") do
					@post.approve!
				end
			end

			context "that is then flagged" do
				setup do
					@user2 = FactoryGirl.create(:user)
					@user3 = FactoryGirl.create(:user)
					@approver2 = FactoryGirl.create(:user)
					@approver2.can_approve_posts = true
					@approver2.save
				end

				should "prevent the first approver from approving again" do
					@post.approve!
					CurrentUser.user = @user2
					@post.flag!("blah")
					CurrentUser.user = @approver2
					@post.approve!
					assert_not_equal(@approver.id, @post.approver_id)
					CurrentUser.user = @user3
					@post.flag!("blah blah")
					CurrentUser.user = @approver

					assert_raises(Post::ApprovalError) do
						@post.approve!
					end
				end
			end
		end
	end
end
