module SavedSearches
  module CheckAvailability
    extend ActiveSupport::Concern

    included do
      before_filter :check_availability
    end

    def check_availability
      if !SavedSearch.enabled?
        respond_to do |format|
          format.html do
            flash[:notice] = "Listbooru service is not configured. Saved searches are not available."
            redirect_to :back
          end
          format.json do
            render json: {success: false, reason: "Listbooru service is not configured"}.to_json, status: 501
          end
        end

        return false
      end
    end
  end
end
