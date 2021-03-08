class RobotsController < ApplicationController
  respond_to :text

  def index
    expires_in 1.hour, public: true unless response.cache_control.present?
  end
end
