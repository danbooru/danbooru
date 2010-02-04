# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_danbooru2_session',
  :secret => '8c46b9a05b0222b74454c6f4bd461be89cc762d9ef3dab4513997670ffed45086bc7a025d45ead5accca656cfb9ab64e70dd44c4379653cf8d4ca45f455ac8ec'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
