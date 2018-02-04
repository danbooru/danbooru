class JanitorTrialsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :moderator_only, :only => [:create, :promote, :demote]

  def new
    @janitor_trial = JanitorTrial.new
    respond_with(@janitor_trial)
  end

  def edit
    @janitor_trial = JanitorTrial.find(params[:id])
    respond_with(@janitor_trial)
  end

  def index
    @janitor_trials = JanitorTrial.search(params[:search]).paginate(params[:page], :limit => params[:limit])
    respond_with(@janitor_trials)
  end

  def create
    @janitor_trial = JanitorTrial.create(params[:janitor_trial])
    respond_with(@janitor_trial, :location => janitor_trials_path)
  end

  def promote
    @janitor_trial = JanitorTrial.find(params[:id])
    @janitor_trial.promote!
    respond_with(@janitor_trial) do |format|
      format.js
    end
  end

  def demote
    @janitor_trial = JanitorTrial.find(params[:id])
    @janitor_trial.demote!
    respond_with(@janitor_trial) do |format|
      format.js
    end
  end

  def test
    @tester = JanitorTrialTester.new(params[:janitor_trial][:user_name])
  end
end
