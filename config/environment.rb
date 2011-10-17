# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Whiteboard::Application.initialize!

# For use with dalli/memcached gem
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Rails.cache.reset if forked
  end
end
