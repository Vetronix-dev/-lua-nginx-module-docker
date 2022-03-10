FROM debian:9 as build
ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1/
RUN apt update && apt install wget gcc make libpcre3-dev zlib1g-dev -y
RUN wget http://nginx.org/download/nginx-1.19.3.tar.gz && tar -xzvf nginx-1.19.3.tar.gz
RUN wget -O luajit-2.1.tar.gz https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20190507.tar.gz && tar xvfz luajit-2.1.tar.gz
RUN wget -O nginx_devel_kit.tar.gz https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.1.tar.gz && tar xvf nginx_devel_kit.tar.gz
RUN wget -O nginx_lua_module.tar.gz https://github.com/openresty/lua-nginx-module/archive/refs/tags/v0.10.12.tar.gz && tar xvf nginx_lua_module.tar.gz
RUN cd luajit2-2.1-20190507 && make install
RUN cd nginx-1.19.3 && ./configure --prefix=/opt/nginx --with-ld-opt="-Wl,-rpath,/usr/local/lib" --add-module=/ngx_devel_kit-0.3.1 --add-module=/lua-nginx-module-0.10.12 && make && make install
RUN wget https://github.com/openresty/lua-resty-core/archive/refs/tags/v0.1.22.tar.gz && tar xvfz v0.1.22.tar.gz
RUN cd lua-resty-core-0.1.22 && make install PREFIX=/opt/nginx
RUN wget https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v0.11.tar.gz && tar xvfz v0.11.tar.gz
RUN cd lua-resty-lrucache-0.11 && make install PREFIX=/opt/nginx

FROM debian:9
WORKDIR /opt/nginx/
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/include/luajit-2.1/ /usr/local/include/luajit-2.1/
COPY --from=build /opt/nginx/ .
CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
