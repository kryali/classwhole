echo "Installing dependencies.."
wget https://github.com/downloads/libevent/libevent/libevent-2.0.15-stable.tar.gz
tar xvf libevent-2.0.15-stable.tar.gz
cd libevent-2.0.15-stable/
./configure
make
sudo make install
cd ..
rm -rf libevent-2.0.15-stable*
echo "Installing memcached.."
wget http://memcached.googlecode.com/files/memcached-1.4.8.tar.gz
tar xvf memcached-1.4.8.tar.gz
cd memcached-1.4.8
./configure
make
sudo make install
