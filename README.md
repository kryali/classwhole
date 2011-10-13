# Getting started

Get your environment setup 
    
    sudo ./ubuntu_bootstrap.sh
    sudo ./install_redis.sh
    bundle install
    rvmsudo passenger-install-nginx-module --user=you      # For nginx and nice server stuff
    
## Setup
    bundle install
    rake db:setup       # I would run this in a screen
    rake redis:setup
## Run (Development)
    rails server
    
# Production
    bundle exec rake assets:precompile
    rvmsudo passenger start -p 80 --user=you
    
# Committing

###Working on a new feature

1. Make a new branch
2. Push the branch to the remote repo
3. ???
4. Submit a pull request

#### Example
    git branch -b new_feature
    git push new_feature origin (I think)