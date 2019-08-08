namespace :web do
  desc "Present a maintenance page to visitors."
  task :disable do
    on roles(:app) do
      maintenance_html_path = "#{current_path}/public/maintenance.html.bak"
      if test("[ -e #{maintenance_html_path} ]")
        execute :mv, maintenance_html_path, "#{current_path}/public/maintenance.html"
      end
    end
  end

  desc "Makes the application web-accessible again."
  task :enable do
    on roles(:app) do
      maintenance_html_path = "#{current_path}/public/maintenance.html"
      if test("[ -e #{maintenance_html_path} ]")
        execute :mv, maintenance_html_path, "#{current_path}/public/maintenance.html.bak"
      end
    end
  end
end
