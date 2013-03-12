ENV["NRCONFIG"] = "/var/www/danbooru2/shared/newrelic.yml"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Danbooru::Application.initialize!
