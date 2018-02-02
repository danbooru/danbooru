module Maintenance
  module User
    class DmailFiltersController < ApplicationController
      before_filter :ensure_ownership
      respond_to :html, :json, :xml

      def edit
        @dmail_filter = CurrentUser.dmail_filter || DmailFilter.new
      end

      def update
        @dmail_filter = CurrentUser.dmail_filter || DmailFilter.new
        @dmail_filter.update(dmail_filter_params)
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

      def dmail_filter_params
        params.require(:dmail_filter).permit(:words)
      end
    end
  end
end
