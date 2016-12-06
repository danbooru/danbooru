class DmailsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only
  rescue_from User::PrivilegeError, :with => :access_denied

  def new
    if params[:respond_to_id]
      parent = Dmail.find(params[:respond_to_id])
      check_privilege(parent)
      @dmail = parent.build_response(:forward => params[:forward])
    else
      @dmail = Dmail.new(params[:dmail])
    end

    respond_with(@dmail)
  end

  def index
    if params[:folder] && params[:set_default_folder]
      cookies.permanent[:dmail_folder] = params[:folder]
    end
    @query = Dmail.active.visible.search(params[:search])
    @dmails = @query.order("dmails.created_at desc").paginate(params[:page], :limit => params[:limit])
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
    @dmail = Dmail.create_split(params[:dmail].merge(:creator_ip_addr => request.remote_ip))
    respond_with(@dmail)
  end

  def destroy
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_read!
    @dmail.destroy
    redirect_to dmails_path, :notice => "Message destroyed"
  end

  def mark_all_as_read
    Dmail.visible.unread.each do |x|
      x.update_column(:is_read, true)
    end
    CurrentUser.user.has_mail = false
    CurrentUser.user.save
  end

private

  def check_privilege(dmail)
    if !dmail.visible_to?(CurrentUser.user, params[:key])
      raise User::PrivilegeError
    end
  end
end
