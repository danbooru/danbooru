SimpleCov.start "rails" do
  add_group "Libraries", ["app/logical", "lib"]
  add_group "Presenters", "app/presenters"
  enable_coverage :branch
  minimum_coverage line: 85, branch: 75
  minimum_coverage_by_file 50
  coverage_dir "tmp/coverage"
end
