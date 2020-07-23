SimpleCov.start "rails" do
  add_group "Libraries", ["app/logical", "lib"]
  add_group "Presenters", "app/presenters"
  add_group "Policies", "app/policies"
  enable_coverage :branch

  # https://github.com/codecov/codecov-ruby#submit-only-in-ci-example
  if ENV["CODECOV_TOKEN"]
    require "codecov"
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end
