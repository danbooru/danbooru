class SuperVotersController < ApplicationController
  before_filter :member_only

  def index
    @super_voters = SuperVoter.all
  end
end

