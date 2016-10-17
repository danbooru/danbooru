class SuperVotersController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @super_voters = SuperVoter.all
    respond_with(@super_voters)
  end
end
