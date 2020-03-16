module Maintenance
  module User
    class CountFixesController < ApplicationController
      def new
        @user = authorize CurrentUser.user, :fix_counts?
      end

      def create
        @user = authorize CurrentUser.user, :fix_counts?
        CurrentUser.user.refresh_counts!
        flash[:notice] = "Counts have been refreshed"
        redirect_to profile_path
      end
    end
  end
end
