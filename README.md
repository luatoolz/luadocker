# lua/alpine docker standard tester image
```bash
docker pull luatoolz/luadocker

tags: 5.1, 5.2, 5.3, jit
```

## featured:
- luarocks
- nginx
- libmaxminddb
- mongo
- idn2
- resolver
- utf8
- other minor libs/connectors

## test tools:
- cpanm Test::Nginx::Socket::Lua + App-Prove-Plugin-NginxModules
- busted
- bash/mc/net/cli tools
- luarocks modules
