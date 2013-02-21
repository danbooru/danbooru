module DelayedJobsHelper
  def print_handler(job)
    case job.name
    when "Upload#process!"
      '<strong>upload post</strong>: <a href="/uploads/' + job.payload_object.object.id.to_s + '">record</a>'
      
    when "Tag#update_related"
      "none"
      
    when "TagAlias#process!"
      '<strong>alias</strong>: ' + job.payload_object.antecedent_name + " -&gt; " + job.payload_object.consequent_name
      
    when "TagImplication#process!"
      '<strong>implication</strong>: ' + job.payload_object.antecedent_name + " -&gt; " + job.payload_object.consequent_name
    
    when "TagAlias#clear_cache"
      "none"
      
    else
      job.handler
    end
  end
end
