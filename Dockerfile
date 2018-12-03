FROM debian:stretch-slim
MAINTAINER jxw <jxw608@petrochina.com.cn>

ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng
ENV OPENRESTY_VERSION 1.13.6.2
RUN cd ~

RUN apt-get update && \
    apt-get install -y wget  libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential curl lua5.1 liblua5.1-dev

RUN mkdir /data && cd /data && \
    wget -c https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -O /data/openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar -xzvf /data/openresty-${OPENRESTY_VERSION}.tar.gz -C /data/ 

RUN cd /data/openresty-${OPENRESTY_VERSION}  && \
     ./configure \
	  --with-http_stub_status_module \
      --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/"   \
      --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
      -j8 
#
#If your machine has multiple cores and your make supports the jobserver feature, you can compile things in parallel like this:
#make -j2
RUN cd /data/openresty-1.11.2.3 && \
    make && \
    make install

RUN apt-cache search libjpeg
RUN apt-cache search libpng
RUN apt-get install -y unzip libjpeg62 libpng16-16 graphicsmagick

RUN mkdir /home/cachedata
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD wmts.lua  /usr/local/openresty/nginx/conf/wmts.lua
ADD weedfs.lua /usr/local/openresty/nginx/conf/weedfs.lua

ADD lua-resty-mongol3.zip /data/lua-resty-mongol3.zip
ADD /data/resty.zip

RUN unzip -o /data/resty.zip -d /usr/local/openresty/lualib/resty && \
    unzip -o /data/lua-resty-mongol3.zip -d /data && \
	cd /data/lua-resty-mongol3 && \
    make install 

RUN apt-get clean

RUN rm -rf /var/lib/apt/lists/*  && \
    rm /data/openresty-1.11.2.3.tar.gz && \
    rm /data/lua-resty-mongol3.zip && \
    rm /data/resty.zip

EXPOSE 80 443 8080

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]




    
    
    

