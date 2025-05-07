# frozen_string_literal: true

class SiteCredentialController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @site_credentials = authorize SiteCredential.paginated_search(params)
    respond_with(@site_credentials)
  end

  def show
    @site_credential = authorize SiteCredential.find(params[:id])
    respond_with(@site_credential)
  end

  def new
    @site_credential = authorize SiteCredential.new(permitted_attributes(SiteCredential))
    respond_with(@site_credential)
  end

  def edit
    @site_credential = authorize SiteCredential.find(params[:id])
    respond_with(@site_credential)
  end

  def create
    @site_credential = authorize SiteCredential.new(permitted_attributes(SiteCredential))
    @site_credential.save

    respond_with(@site_credential)
  end

  def update
    @site_credential = authorize SiteCredential.find(params[:id])
    @site_credential.update(permitted_attributes(@site_credential))

    respond_with(@site_credential)
  end

  def destroy
    @site_credential = authorize SiteCredential.find(params[:id])
    @site_credential.destroy

    respond_with(@site_credential)
  end
end
