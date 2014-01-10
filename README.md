# urls shortener based on sinatra and redis

### requires redis server

```
wget http://download.redis.io/releases/redis-2.8.3.tar.gz 
tar zfx redis-2.0.4.tar.gz  
cd redis-2.0.4  
make  
sudo make install
```

### run it

```
bundle install
ruby shrtn
```