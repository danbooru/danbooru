class DmailsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    if params[:respond_to_id]
      @dmail = Dmail.find(params[:respond_to_id]).build_response(:forward => params[:forward])
    else
      @dmail = Dmail.new(params[:dmail])
    end
    
    respond_with(@dmail)
  end
  
  def index
    @search = Dmail.search(params[:search])
    @dmails = @search.paginate(:page => params[:page])
    @dmails.each {|x| check_privilege(x)}
    respond_with(@dmails)
  end
  
  def show
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    respond_with(@dmail)
  end

  def create
    @dmail = Dmail.create_split(params[:dmail])
    respond_with(@dmail)
  end
  
  def destroy
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.destroy
    redirect_to dmails_path, :notice => "Message destroyed"
  end
  
private
  def check_privilege(dmail)
    if !dmail.visible_to?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
