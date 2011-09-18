# Getting started

Rails 3 on ubuntu 11.04 is a pain, so everything you need has been saved in a bash script.
Read it so you know what's going on. 

This script installs rails3 w/ sqlite3, mysql and sphinx upcoming..

    sudo sh ubuntu_bootstrap.sh
## Setup
    bundle install
    rake db:setup
## Run
    rails server

# Committing

###Working on a new feature

1. Make a new branch
2. Push the branch to the remote repo
3. ???
4. Submit a pull request

#### Example
    git branch -b new_feature
    git push new_feature origin (I think)