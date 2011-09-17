# INSTALL RAILS - because its too fucking annoying
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim build-essential curl git git-core git-gui git-doc sqlite3 libsqlite3-dev libsqlite3-ruby libncurses-dev libncurses-ruby libreadline-dev nodejs
bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile
source ~/.bash_profile
rvm pkg install zlib
rvm pkg install iconv
rvm pkg install openssl
rvm install 1.9.2 -C --with-openssl-dir=$HOME/.rvm/usr,--with-iconv-dir=$HOME/.rvm/usr,--with-zlib-dir=$rvm_path/usr
rvm use --default 1.9.2
cp /etc/ssl/certs/* ~/.rvm/usr/ssl/certs/
gem install rails
sudo apt-get install cd ~/.rvm/src/ruby-1.9.2-p290/ext/readline
ruby extconf.rb
make
make install
cd $HOME
