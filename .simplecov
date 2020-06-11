SimpleCov.start "rails" do
  add_group "Libraries", ["app/logical", "lib"]
  add_group "Presenters", "app/presenters"
  enable_coverage :branch
  coverage_dir "tmp/coverage"
end
