namespace :db do
  namespace :test do
    task :reset => [:environment, "db:drop", "db:create", "db:migrate", "db:structure:dump", "db:test:clone_structure"] do
    end
  end
end
