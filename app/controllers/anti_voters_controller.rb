class AntiVotersController < ApplicationController
  before_filter :member_only

  def index
    @anti_voters = AntiVoter.all
  end
end

