# urls shortener based on sinatra and redis

### requires redis server

```
wget http://download.redis.io/releases/redis-2.8.4.tar.gz 
tar zfx redis-2.8.4.tar.gz  
cd redis-2.8.4  
make  
sudo make install
```

### run it

```
bundle install
ruby shrtn
```

### TODO
- tests
- addparameter options for custom expire and/or click limit
- design
