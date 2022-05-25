# frozen_string_literal: true

class UpgradeCodesController < ApplicationController
  respond_to :js, :html, :json, :xml

  def index
    @upgrade_codes = authorize UpgradeCode.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@upgrade_codes)
  end

  def redeem
  end

  def upgrade
    @upgrade_code = UpgradeCode.redeem!(code: params.dig(:upgrade_code, :code), redeemer: CurrentUser.user)

    respond_with(@upgrade_code, location: @upgrade_code.user_upgrade)
  end
end
