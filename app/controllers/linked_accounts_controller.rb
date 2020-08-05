class LinkedAccountsController < ApplicationController
  respond_to :html, :js, :xml, :json

  def new
    @linked_account = authorize LinkedAccount.new(user: CurrentUser.user, site: params[:site])
    respond_with(@linked_account)
  end

  def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @linked_accounts = authorize LinkedAccount.visible(@user).paginated_search(params, count_pages: true)
    else
      @linked_accounts = authorize LinkedAccount.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    end

    respond_with(@linked_accounts)
  end

  def update
    @linked_account = authorize LinkedAccount.find(params[:id])
    @linked_account.update(permitted_attributes(@linked_account))
    flash.now[:notice] = @linked_account.errors.none? ? "Account updated" : @linked_account.errors.full_messages.join("; ")
    respond_with(@linked_account, location: user_linked_accounts_path(@linked_account.user))
  end

  def destroy
    @linked_account = authorize LinkedAccount.find(params[:id])
    @linked_account.destroy
    respond_with(@linked_account)
  end

  def callback
    if params[:error]
      @linked_account = nil
    else
      @linked_account = LinkedAccount.link_account!(user: CurrentUser.user, code: params[:code], state: params[:state])
    end

    respond_with(@linked_account)
  end
end
