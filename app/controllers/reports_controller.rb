# frozen_string_literal: true

class ReportsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    authorize nil, policy_class: ReportPolicy
  end

  def show
    authorize nil, policy_class: ReportPolicy
    @report = Report.new(params[:id], search_params, CurrentUser.user)

    if CurrentUser.user.is_member? && CurrentUser.user.statement_timeout < 10_000
      statement_timeout = 10_000
    else
      statement_timeout = CurrentUser.user.statement_timeout
    end

    ApplicationRecord.set_timeout(statement_timeout) do
      @report.dataframe
    end

    respond_with(@report.dataframe)
  end
end
