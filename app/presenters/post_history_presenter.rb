class PostHistoryPresenter < Presenter
  attr_reader :revision
  
  def initialize(revision)
    @revision = revision
  end
  
  def changes
    
  end
  
  def updated_at
    revision["updated_at"]
  end
  
  def updater_name
    User.id_to_name(revision["user_id"].to_i)
  end
end
