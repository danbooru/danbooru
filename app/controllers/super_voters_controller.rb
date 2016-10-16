class SuperVotersController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json

  def index
    @super_voters = SuperVoter.all
    respond_with(@super_voters)
  end
end

