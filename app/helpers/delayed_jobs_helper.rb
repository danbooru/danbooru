module DelayedJobsHelper
  def print_handler(job)
    case job.name
    when "Class#expire_cache"
      "<strong>expire post count cache</strong>: " + h(job.payload_object.args.flatten.join(" "))

    when "Upload#process!"
      '<strong>upload post</strong>: <a href="/uploads/' + job.payload_object.object.id.to_s + '">record</a>'

    when "Tag#update_related"
      "<strong>update related tags</strong>: " + h(job.payload_object.name)

    when "TagAlias#process!"
      '<strong>alias</strong>: ' + h(job.payload_object.antecedent_name) + " -&gt; " + h(job.payload_object.consequent_name)

    when "TagImplication#process!"
      '<strong>implication</strong>: ' + h(job.payload_object.antecedent_name) + " -&gt; " + h(job.payload_object.consequent_name)

    when "Class#clear_cache_for"
      "<strong>expire tag alias cache</strong>: " + h(job.payload_object.args.flatten.join(" "))

    when "Tag#update_category_cache"
      "<strong>update tag category cache</strong>: " + h(job.payload_object.name)

    when "Tag#update_category_post_counts"
      "<strong>update category post counts</strong>: " + h(job.payload_object.name)

    else
      h(job.handler)
    end
  end
end
