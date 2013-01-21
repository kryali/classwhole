#!/bin/sh
export RAILS_ENV=production
git pull origin master;
rake db:migrate;
rake groups:generate_default;
rake assets:clean;
rake assets:precompile;
touch tmp/restart.txt
