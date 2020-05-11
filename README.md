## Another Minecraft Server in Docker

My daughter tremendously enjoys playing Minecraft Bedrock Edition. In order to make multiplayer play more enjojable on the local LAN we opted to run a local server. There were a few objectives when it came to making this work:

- Ease of use, the available servers or worlds just need to show up in the client
- A space saving design to reuse files across servers or worlds where feasible
- Simple to maintain and change settings if needed

I've looked at many existing docker images. The [karlrees/docker_bedrockserver](https://github.com/karlrees/docker_bedrockserver) looked promising and I ran it for a bit. I found the management of server data not as simple as I wished. So I studied the server software, some of the docker images available and eventually cooked up my own concoction. And so here we are...

### To be continued...