module CommentsHelper
  def render_comment(comment, **options)
    render CommentComponent.new(comment: comment, **options)
  end

  def render_comment_list(comments, **options)
    dtext_data = DText.preprocess(comments.map(&:body))
    render CommentComponent.with_collection(comments, dtext_data: dtext_data, **options)
  end
end
