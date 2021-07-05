namespace :symlink do
  desc "Link the local config files"
  task :local_files do
    on roles(:app, :worker) do
      execute :ln, "-s", "#{deploy_to}/shared/config/danbooru_local_config.rb", "#{release_path}/config/danbooru_local_config.rb"
    end
  end

  desc "Link the local directories"
  task :directories do
    on roles(:app, :worker) do
      execute :rm, "-f", "#{release_path}/public/data"
      execute :ln, "-s", "#{deploy_to}/shared/data", "#{release_path}/public/data"
    end
  end
end

after "deploy:symlink:shared", "symlink:local_files"
after "deploy:symlink:shared", "symlink:directories"
