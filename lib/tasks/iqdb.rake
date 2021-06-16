namespace :iqdb do
  task reindex_posts: :environment do
    STDIN.each_line do |post_id|
      puts post_id
      post.update_iqdb
    end
  end
end
