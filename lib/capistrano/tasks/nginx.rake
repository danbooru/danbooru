namespace :nginx do
  desc "Shut down Nginx"
  task :stop do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "stop"
      end
    end
  end

  desc "Start Nginx"
  task :start do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "start"
      end
    end
  end

  desc "Reload Nginx"
  task :reload do
    on roles(:web) do
      as :user => "root" do
        execute "/etc/init.d/nginx", "reload"
      end
    end
  end
end
