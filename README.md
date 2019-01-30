This project seeks to create a better 7DTD Gameserver platform that can be configured and managed from the built-in webserver.

**TO BUILD**

```
time docker build -t c7/7dtd .
```

**TO RUN** First, create a Steam account specifically for your server. Use these credentials below.

```
docker run -dt -v$(pwd)/data:/data \
  -p26900:26900/udp -p26900:26900/tcp -p26902:26902/udp \
  -p80:80 -p8080:8080 -p8081:8081 -p8082:8082 \
  -e STEAMCMD_LOGIN=YOUR_STEAM_USERNAME \
  -e STEAMCMD_PASSWORD='YOUR_STEAM_PASSWORD' \
  -e STEAMCMD_APP_ID=294420 -e INSTALL_DIR="/data/7DTD" \
  -e 7DTD_AUTOREVEAL_MAP=true \
  --name=c7-7dtd c7/7dtd
```

**TO INSTALL STEAM GAME**

This command will initiate a Steam Guard request and require you to type in the code that Steam emails you. When this command completes, your server will begin generating a new world and will start the server. The first player that connects to your server will be granted admin permissions and will be cycled across the entire map to fully reveal the map on the web interface. Depending on the size of map you configure, this process could take several hours to complete initially. You can disable this automatic map revealing on first login, by setting the environmental variable on your run command above: 7DTD_AUTOREVEAL_MAP=false

```
docker exec -it c7-7dtd /install_7dtd.sh
```

**TO ENTER**

```
docker exec -it c7-7dtd bash
```
