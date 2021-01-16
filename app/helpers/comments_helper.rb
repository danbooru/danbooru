module CommentsHelper
  def render_comment(comment, **options)
    render CommentComponent.new(comment: comment, **options)
  end

  def render_comment_list(comments, **options)
    render CommentComponent.with_collection(comments, current_user: CurrentUser.user, **options)
  end
end
