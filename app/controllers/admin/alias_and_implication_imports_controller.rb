module Admin
  class AliasAndImplicationImportsController < ApplicationController
    before_action :admin_only

    def new
    end

    def create
      @importer = AliasAndImplicationImporter.new(params[:batch][:text], params[:batch][:forum_id], params[:batch][:rename_aliased_pages])
      @importer.process!
      flash[:notice] = "Import queued"
      redirect_to new_admin_alias_and_implication_import_path
    rescue => x
      flash[:notice] = x.to_s
      redirect_to new_admin_alias_and_implication_import_path
    end
  end
end
