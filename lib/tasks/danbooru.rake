namespace :danbooru do
  desc "Run the cronjob scheduler"
  task cron: :environment do
    Clockwork::run
  end

  namespace :docker do
    # Note that uncommited changes won't be included in the image; commit
    # changes first before building the image.
    desc "Build a Docker image based on latest commit"
    task :build do
      system("git archive HEAD | docker build - --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) -t danbooru -f Dockerfile")
    end
  end
end
