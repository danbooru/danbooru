class DmailsController < ApplicationController
  respond_to :html, :xml, :js, :json
  before_action :member_only, except: [:index, :show, :update, :mark_all_as_read]

  def new
    if params[:respond_to_id]
      parent = Dmail.find(params[:respond_to_id])
      check_show_privilege(parent)
      @dmail = parent.build_response(:forward => params[:forward])
    else
      @dmail = Dmail.new(dmail_params(:create))
    end

    respond_with(@dmail)
  end

  def index
    @dmails = Dmail.visible.paginated_search(params, defaults: { folder: "received" }, count_pages: true).includes(model_includes(params))
    respond_with(@dmails)
  end

  def show
    @dmail = Dmail.find(params[:id])
    check_show_privilege(@dmail)

    if request.format.html? && @dmail.owner == CurrentUser.user
      @dmail.update!(is_read: true)
    end

    respond_with(@dmail)
  end

  def create
    @dmail = Dmail.create_split(dmail_params(:create))
    respond_with(@dmail)
  end

  def update
    @dmail = Dmail.find(params[:id])
    check_update_privilege(@dmail)
    @dmail.update(dmail_params(:update))
    flash[:notice] = "Dmail updated"

    respond_with(@dmail)
  end

  def mark_all_as_read
    @dmails = CurrentUser.user.dmails.mark_all_as_read
    respond_with(@dmails)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:owner, :to, :from]
    end
  end

  def check_show_privilege(dmail)
    raise User::PrivilegeError unless dmail.visible_to?(CurrentUser.user, params[:key])
  end

  def check_update_privilege(dmail)
    raise User::PrivilegeError unless dmail.owner == CurrentUser.user
  end

  def dmail_params(context)
    permitted_params = %i[title body to_name to_id] if context == :create
    permitted_params = %i[is_read is_deleted] if context == :update

    params.fetch(:dmail, {}).permit(permitted_params)
  end
end
