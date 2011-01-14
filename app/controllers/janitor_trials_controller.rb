class JanitorTrialsController < ApplicationController
  respond_to :html, :xml, :json
  
  def new
    @janitor_trial = JanitorTrial.new
    respond_with(@janitor_trial)
  end
  
  def edit
    @janitor_trial = JanitorTrial.find(params[:id])
    respond_with(@janitor_trial)
  end
  
  def index
    @search = JanitorTrial.search(params[:search])
    @janitor_trials = @search.paginate(:page => params[:page])
    respond_with(@janitor_trials)
  end
  
  def create
    @janitor_trial = JanitorTrial.create(params[:janitor_trial])
    respond_with(@janitor_trial)
  end
  
  def promote
    @janitor_trial = JanitorTrial.find(params[:id])
    @janitor_trial.promote!
    respond_with(@janitor_trial)
  end
  
  def demote
    @janitor_trial = JanitorTrial.find(params[:id])
    @janitor_trial.demote!
    respond_with(@janitor_trial)
  end
end
