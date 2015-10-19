namespace :symlink do
  desc "Link the local config files"
  task :local_files do
    on roles(:app) do
	  execute :chmod, "+x", "#{release_path}/script/delayed_job"
	  execute :chmod, "+x", "#{release_path}/script/rails"
      execute :ln, "-s", "#{deploy_to}/shared/config/danbooru_local_config.rb", "#{release_path}/config/danbooru_local_config.rb"
      execute :ln, "-s", "#{deploy_to}/shared/config/database.yml", "#{release_path}/config/database.yml"
      if test("[ -f #{deploy_to}/shared/config/newrelic.yml ]")
        execute :ln, "-s", "#{deploy_to}/shared/config/newrelic.yml", "#{release_path}/config/newrelic.yml"
      end
    end
  end

  desc "Link the local directories"
  task :directories do
    on roles(:app) do
      execute :rm, "-f", "#{release_path}/public/data"
      execute :ln, "-s", "#{deploy_to}/shared/data", "#{release_path}/public/data"
      execute :mkdir, "-p", "#{release_path}/public/cache"
      execute :mkdir, "-p", "#{deploy_to}/shared/system/cache"
      execute :touch, "#{deploy_to}/shared/system/cache/tags.json"
      execute :ln, "-s", "#{deploy_to}/shared/system/cache/tags.json", "#{release_path}/public/cache/tags.json"
      execute :touch, "#{deploy_to}/shared/system/cache/tags.json.gz"
      execute :ln, "-s", "#{deploy_to}/shared/system/cache/tags.json.gz", "#{release_path}/public/cache/tags.json.gz"
    end
  end
end

after "deploy:symlink:shared", "symlink:local_files"
after "deploy:symlink:shared", "symlink:directories"
