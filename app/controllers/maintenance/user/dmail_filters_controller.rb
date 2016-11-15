module Maintenance
  module User
    class DmailFiltersController < ApplicationController
      before_filter :ensure_ownership
      before_filter :member_only
      respond_to :html, :json, :xml

      def edit
        @dmail_filter = CurrentUser.dmail_filter || DmailFilter.new
      end

      def update
        @dmail_filter = CurrentUser.dmail_filter || DmailFilter.new
        @dmail_filter.update(params.require(:dmail_filter).permit(:words), :as => CurrentUser.role)
        flash[:notice] = "Filter updated"
        respond_with(@dmail)
      end

    private

      def ensure_ownership
        @dmail = Dmail.find(params[:dmail_id])

        if @dmail.owner_id != CurrentUser.user.id
          raise User::PrivilegeError.new
        end
      end
    end
  end
end
