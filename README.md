**TO BUILD**

```
time docker build -t c7/7dtd .
```

**TO RUN**

```
docker run -dt -v$(pwd)/data:/data \
  -p26900:26900/udp -p26900:26900/tcp -p26902:26902/udp \
  -p80:80 -p8080:8080 -p8081:8081 -p8082:8082 \
  -e STEAMCMD_LOGIN=YOUR_STEAM_USERNAME -e STEAMCMD_PASSWORD='YOUR_STEAM_PASSWORD' \
  -e STEAMCMD_APP_ID=294420 -e INSTALL_DIR="/data/7DTD" \
  --name=c7-7dtd c7/7dtd
```

**TO INSTALL STEAM GAME**

```
docker exec -it c7-7dtd /install_7dtd.sh
```

**TO ENTER**

```
docker exec -it c7-7dtd bash
```
