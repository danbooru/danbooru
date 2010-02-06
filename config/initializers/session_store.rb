# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_danbooru_session',
  :secret => '3102c705148af8124298f9e89d45da3d26e47cc4d9a67cb1c8d9c42c008ee253786346efda50331bb14811f1f445c1c9ed2d51597ad2017328de0dd263048d1a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
