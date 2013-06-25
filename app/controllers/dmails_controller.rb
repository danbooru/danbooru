class DmailsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only
  rescue_from User::PrivilegeError, :with => :access_denied

  def new
    if params[:respond_to_id]
      @dmail = Dmail.find(params[:respond_to_id]).build_response(:forward => params[:forward])
    else
      @dmail = Dmail.new(params[:dmail])
    end

    respond_with(@dmail)
  end

  def index
    cookies.permanent[:dmail_folder] = params[:folder]
    @search = Dmail.visible.search(params[:search])
    @dmails = @search.order("dmails.created_at desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@dmails) do |format|
      format.xml do
        render :xml => @dmails.to_xml(:root => "dmails")
      end
    end
  end

  def search
  end

  def show
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_read!
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

  def mark_all_as_read
    Dmail.visible.unread.each do |x|
      x.update_column(:is_read, true)
    end
  end

private
  def check_privilege(dmail)
    if !dmail.visible_to?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
