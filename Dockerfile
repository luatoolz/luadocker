# syntax=docker/dockerfile:1
# check=skip=JSONArgsRecommended,StageNameCasing
ARG SOURCE_DATE_EPOCH=0
ARG LUA_VERSION=${LUA_VERSION:-jit}

FROM alpine AS build
ARG SOURCE_DATE_EPOCH
ARG LUA_VERSION

RUN apk update && apk upgrade && apk add \
  ca-certificates curl openssl-dev bash \
  sudo mc net-tools procps iputils-ping \
  build-base gcc git make cmake pkgconf \
  nginx nginx-mod-http-lua \
  libmaxminddb libmaxminddb-dev libmaxminddb-libs \
  mongo-c-driver-static libbson-static \
  libidn2-dev \
  zlib zlib-dev \
  perl-app-cpanminus perl-test-nginx perl-utils \
  lua${LUA_VERSION}-dev lua${LUA_VERSION}

RUN cpanm Test::Nginx::Socket::Lua https://github.com/luatoolz/App-Prove-Plugin-NginxModules.git

FROM build AS base
ARG SOURCE_DATE_EPOCH
ARG LUA_VERSION
COPY --from=build / /

RUN test "$LUA_VERSION" = "jit" \
  && apk add lua5.1 lua5.1-dev luarocks5.1 \
  && ln -s /usr/bin/luarocks-5.1 /usr/bin/luarocks-jit \
  || apk add luarocks${LUA_VERSION}
RUN test -f /usr/bin/luarocks || ln -s /usr/bin/luarocks-${LUA_VERSION} /usr/bin/luarocks
RUN luarocks config --scope system lua_dir /usr

FROM base AS libs
ARG SOURCE_DATE_EPOCH
RUN luarocks install --dev compat53
RUN luarocks install --dev say
RUN luarocks install --dev busted
RUN luarocks install --dev date
RUN luarocks install --dev idn2
RUN luarocks install --dev lua-maxminddb
#RUN luarocks install --dev lua-mongo
RUN luarocks install --dev luaresolver
RUN luarocks install --dev luasocket
RUN luarocks install --dev luassert
RUN luarocks install --dev luautf8
RUN luarocks install --dev net-url
RUN luarocks install --dev paths
RUN luarocks install --dev public_suffix_list
RUN luarocks install --dev rapidjson
RUN luarocks install --dev https://raw.githubusercontent.com/luatoolz/lua-mongo/master/lua-mongo-scm-0.rockspec

FROM scratch
ARG SOURCE_DATE_EPOCH
ARG LUA_VERSION
ENV LUA_VERSION=$LUA_VERSION
COPY --from=libs / /
COPY mc.ini /root/.config/mc/mc.ini
CMD bash
