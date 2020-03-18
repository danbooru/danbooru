class DmailsController < ApplicationController
  respond_to :html, :xml, :js, :json

  def new
    if params[:respond_to_id]
      parent = authorize Dmail.find(params[:respond_to_id]), :show?
      @dmail = parent.build_response(:forward => params[:forward])
    else
      @dmail = authorize Dmail.new(permitted_attributes(Dmail))
    end

    respond_with(@dmail)
  end

  def index
    @dmails = authorize Dmail.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @dmails = @dmails.includes(:owner, :to, :from) if request.format.html?

    respond_with(@dmails)
  end

  def show
    @dmail = authorize Dmail.find(params[:id])

    if request.format.html? && @dmail.owner == CurrentUser.user
      @dmail.update!(is_read: true)
    end

    respond_with(@dmail)
  end

  def create
    @dmail = authorize(Dmail).create_split(from: CurrentUser.user, creator_ip_addr: CurrentUser.ip_addr, **permitted_attributes(Dmail))
    respond_with(@dmail)
  end

  def update
    @dmail = authorize Dmail.find(params[:id])
    @dmail.update(permitted_attributes(@dmail))
    flash[:notice] = "Dmail updated"

    respond_with(@dmail)
  end

  def mark_all_as_read
    @dmails = authorize(CurrentUser.user.dmails).mark_all_as_read
    respond_with(@dmails)
  end
end
