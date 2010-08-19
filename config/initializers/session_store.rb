# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_plt_session',
  :secret      => '7a8e346fd01047afa8760e3ac7e9b2084ae5a16f827196100b49c309e52cd07413b6fcae36d83ba9d5e120658eafb142043cbf98a292b53bbe83ee8c0be838c6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
