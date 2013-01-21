#!/bin/sh
export RAILS_ENV=production
git pull origin master;
rake db:migrate;
rake assets:clean;
rake assets:precompile;
touch tmp/restart.txt
