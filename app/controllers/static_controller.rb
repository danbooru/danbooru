class StaticController < ApplicationController
  def benchmark
    n = 1_000
    
    Benchmark.bm do |x|
      x.report("default") do
        n.times do
          view_context.link_to("test", :controller => "posts", :action => "index", :tags => "abc")
        end
      end
      
      x.report("posts_path") do
        n.times do
          view_context.link_to("test", posts_path(:tags => "abc"))
        end
      end
      
      x.report("fast link to") do
        n.times do
          view_context.fast_link_to("test", :controller => "posts", :action => "index", :tags => "abc")
        end
      end
    end
    
    render :nothing => true
  end
  
  def terms_of_service
    render :layout => "blank"
  end
end
