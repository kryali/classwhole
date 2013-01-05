# Getting started

Get your environment setup
#### You need
* Ruby 1.9.2p290
    
## Setup
    # Make sure all your gems are up to date (installs rails)
    bundle install 
    
    rake db:migrate

    # Scrape course data: This takes a while, I would run this in a screen
    rake data:update       

## Run (Development)
    rails server
    
# Production
    bundle exec rake assets:precompile
    rvmsudo passenger start -p 80 --user=you
    
# Committing

###Working on a new feature

1. Make a new branch
2. Submit a pull request

#### Example
    git checkout -b new_feature
    git push
