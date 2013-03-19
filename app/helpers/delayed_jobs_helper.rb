module DelayedJobsHelper
  def print_handler(job)
    case job.name
    when "Class#expire_cache"
      "<strong>expire post count cache</strong>: " + job.payload_object.args.flatten.join(" ")

    when "Upload#process!"
      '<strong>upload post</strong>: <a href="/uploads/' + job.payload_object.object.id.to_s + '">record</a>'

    when "Tag#update_related"
      "<strong>update related tags</strong>: " + job.payload_object.name

    when "TagAlias#process!"
      '<strong>alias</strong>: ' + job.payload_object.antecedent_name + " -&gt; " + job.payload_object.consequent_name

    when "TagImplication#process!"
      '<strong>implication</strong>: ' + job.payload_object.antecedent_name + " -&gt; " + job.payload_object.consequent_name

    when "Class#clear_cache_for"
      "<strong>expire tag alias cache</strong>: " + job.payload_object.flatten.join(" ")

    when "Tag#update_category_cache"
      "<strong>update tag category cache</strong>: " + job.payload_object.name

    when "Tag#update_category_post_counts"
      "<strong>update category post counts</strong>: " + job.payload_object.name

    else
      job.handler
    end
  end
end
