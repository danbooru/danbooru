module UploadsHelper
  def render_status(upload)
    case upload.status
    when /duplicate: (\d+)/
      dup_post_id = $1
      link_to(upload.status.gsub(/error: RuntimeError - /, ""), post_path(dup_post_id))

    when /\Aerror: /
      search_params = params[:search].permit!
      link_to(upload.sanitized_status, uploads_path(search: search_params.merge(status: upload.sanitized_status)))

    else
      search_params = params[:search].permit!
      link_to(upload.status, uploads_path(search: search_params.merge(status: upload.status)))
    end
  end
end
