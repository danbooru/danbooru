# frozen_string_literal: true

class RobotsController < ApplicationController
  respond_to :text

  after_action :skip_authorization

  def index
    expires_in 1.hour, public: true unless response.cache_control.present?
  end
end
