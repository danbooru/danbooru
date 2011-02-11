class UnapprovalsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @unapproval = Unapproval.new
    respond_with(@unapproval)
  end
  
  def index
    @search = Unapproval.search(params[:search])
    @unapprovals = @search.paginate(:page => params[:page])
  end
  
  def create
    @unapproval = Unapproval.create(params[:unapproval])
    respond_with(@unapproval)
  end
  
  def destroy
    @unapproval = Unapproval.find(params[:id])
    check_privilege(@unapproval)
    @unapproval.destroy
    respond_with(@unapproval)
  end

private
  def check_privilege(unapproval)
    raise User::PrivilegeError unless (unapproval.unapprover_id == CurrentUser.id || CurrentUser.is_moderator?)
  end
end
