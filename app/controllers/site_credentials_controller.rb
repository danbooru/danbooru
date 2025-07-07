# frozen_string_literal: true

class SiteCredentialsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @site_credentials = authorize SiteCredential.paginated_search(params, count_pages: true)
    respond_with(@site_credentials)
  end

  def show
    @site_credential = authorize SiteCredential.find(params[:id])
    respond_with(@site_credential) do |format|
      format.html { redirect_to site_credentials_path(search: { id: @site_credential.id }) }
    end
  end

  def new
    @site_credential = authorize SiteCredential.new(permitted_attributes(SiteCredential))
    respond_with(@site_credential)
  end

  def create
    @site_credential = authorize SiteCredential.new(creator: CurrentUser.user, **permitted_attributes(SiteCredential))
    @site_credential.save

    respond_with(@site_credential, location: site_credentials_path)
  end

  def update
    @site_credential = authorize SiteCredential.find(params[:id])
    @site_credential.update(updater: CurrentUser.user, **permitted_attributes(@site_credential))

    respond_with(@site_credential, location: site_credentials_path)
  end

  def destroy
    @site_credential = authorize SiteCredential.find(params[:id])
    @site_credential.updater = CurrentUser.user
    @site_credential.destroy

    respond_with(@site_credential, notice: "Credential deleted")
  end
end
