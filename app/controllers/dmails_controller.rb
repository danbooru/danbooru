class DmailsController < ApplicationController
  respond_to :html, :xml, :js, :json
  before_action :member_only, except: [:index, :show, :update, :mark_all_as_read]

  def new
    if params[:respond_to_id]
      parent = Dmail.find(params[:respond_to_id])
      check_privilege(parent)
      @dmail = parent.build_response(:forward => params[:forward])
    else
      @dmail = Dmail.new(dmail_params(:create))
    end

    respond_with(@dmail)
  end

  def index
    if params[:folder] && params[:set_default_folder]
      cookies.permanent[:dmail_folder] = params[:folder]
    end

    @dmails = Dmail.visible.paginated_search(params, defaults: { is_spam: false, is_deleted: false }, count_pages: true)
    respond_with(@dmails)
  end

  def show
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.mark_as_read!
    respond_with(@dmail)
  end

  def create
    @dmail = Dmail.create_split(dmail_params(:create))
    respond_with(@dmail)
  end

  def update
    @dmail = Dmail.find(params[:id])
    check_privilege(@dmail)
    @dmail.update(dmail_params(:update))
    flash[:notice] = "Dmail updated"

    respond_with(@dmail)
  end

  def mark_all_as_read
    Dmail.visible.unread.each do |x|
      x.update_column(:is_read, true)
    end
    CurrentUser.user.update(has_mail: false, unread_dmail_count: 0)
  end

  private

  def check_privilege(dmail)
    if !dmail.visible_to?(CurrentUser.user, params[:key])
      raise User::PrivilegeError
    end
  end

  def dmail_params(context)
    permitted_params = %i[title body to_name to_id] if context == :create
    permitted_params = %i[is_spam is_read is_deleted] if context == :update

    params.fetch(:dmail, {}).permit(permitted_params)
  end
end
