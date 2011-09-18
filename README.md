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

Working on a new feature
- branch from master
- make a clean merge commit and close the relevant issue(s)
