namespace :danbooru do
  desc "Run the cronjob scheduler"
  task cron: :environment do
    Clockwork::run
  end

  # Schedules all posts to be reindexed in IQDB. Requires the delayed jobs
  # worker (bin/delayed_job) to be running.
  desc "Reindex all posts in IQDB"
  task reindex_iqdb: :environment do
    Post.find_each do |post|
      puts "post ##{post.id}"
      post.update_iqdb
    end
  end

  namespace :docker do
    # Note that uncommited changes won't be included in the image; commit
    # changes first before building the image.
    desc "Build a Docker image based on latest commit"
    task :build do
      system("git archive HEAD | docker buildx build - --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) -t danbooru -f Dockerfile")
    end
  end
end
