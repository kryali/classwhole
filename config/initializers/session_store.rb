# Be sure to restart your server when you modify this file.

# expire_after is set to one year, because that's the work around that the internet gave me
# in order to havea session cookie NOT expire when the browser is closed
Whiteboard::Application.config.session_store :cookie_store, key: '_whiteboard_session', :expire_after => 6.months

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Whiteboard::Application.config.session_store :active_record_store
