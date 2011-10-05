wget http://redis.googlecode.com/files/redis-2.2.14.tar.gz
tar xzf redis-2.2.14.tar.gz
cd redis-2.2.14
make
sudo cp src/redis-server src/redis-cli /usr/bin/
cd ..
rm -rf redis-2.2.14*
