# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kairosgame_session',
  :secret      => 'af5a95c2d28d5a75c29418b6301b9d60f7d76f5a46f6ebd170a208c7368ee57ca4181a7525452cb1ac2d51a4c8c7ce5d402a09a9ae0d58c6359e33e77b108375',
  :expire_after => 2.years
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
