# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_forgery_protection only: [:receive]

  def receive
    skip_authorization

    case params[:source]
    in _
      head 400
    end
  end
end
