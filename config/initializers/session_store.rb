# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_danbooru2_session',
  :secret => '2e7aa03574da0a384e847826daad111ef0d32b0f7000868ddb75e5573edf222601c63c4b6082a2e07dd6e71de194eaa5d06dfed686b6e71335f985db9ca5334d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
