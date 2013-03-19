class PostVersionPresenter < Presenter
  attr_reader :post_version

  def initialize(post_version)
    @post_version = post_version
  end

  def changes
    html =  []
    html << post_version.tag_array
    html << "<ins>source:#{h(post_version.source)}</ins>" if post_version.source
    html << "<ins>rating:#{h(post_version.rating)}</ins>" if post_version.rating
    html << "<ins>parent:#{post_version.parent_id}</ins>" if post_version.parent_id
    html.join(" ").html_safe
  end

  def updater_name
    User.id_to_name(post_version.updater_id)
  end
end
