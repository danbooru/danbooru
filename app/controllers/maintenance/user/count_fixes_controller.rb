module Maintenance
  module User
    class CountFixesController < ApplicationController
      before_action :member_only

      def new
      end

      def create
        CurrentUser.user.refresh_counts!
        flash[:notice] = "Counts have been refreshed"
        redirect_to user_path(CurrentUser.id)
      end
    end
  end
end
