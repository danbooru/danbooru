class PostHistoryRevisionPresenter < Presenter
  attr_reader :revision
  
  def initialize(revision)
    @revision = revision
  end
  
  def changes
    html =  []
    html << revision.diff[:del].map {|x| "<del>#{h(x)}</del>"}
    html << revision.diff[:add].map {|x| "<ins>#{h(x)}</ins>"}
    html << "<ins>source:#{h(revision.diff[:source])}</ins>" if revision.diff[:source].present?
    html << "<ins>rating:#{h(revision.diff[:rating])}</ins>" if revision.diff[:rating].present?
    html << "<ins>parent:#{revision.diff[:parent_id]}</ins>" if revision.diff[:parent_id].present?
    html.join(" ").html_safe
  end
  
  def updated_at
    Time.parse(revision.updated_at)
  end
  
  def updater_name
    User.id_to_name(revision.user_id)
  end
end
