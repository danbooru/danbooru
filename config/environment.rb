# Load the Rails application.
require_relative 'application'

Dotenv.load(Rails.root + ".env.local")

# Initialize the Rails application.
Rails.application.initialize!
