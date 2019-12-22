namespace :iqdb do
  task reindex_posts: :environment do
    STDIN.each_line do |post_id|
      puts post_id
      post.remove_iqdb_async
      post.update_iqdb_async
    end
  end
end
