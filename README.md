# ngrok-quick-depoly

ENV-Success: Ubuntu 18.04 LTS (Server&Client)

### Server

```sh
 $ sudo ./ngrok_install.sh
```

### Client

1. copy from the remote server path:/usr/local/ngrok/bin/ngrok to your local machine
2. run script " $ run_client.sh $APP_PORT "


### Http -> Https

1. certbot


### Server Params
custom ngrok tunnel proxy: -tunnelAddr=":14443"

# warning

make sure your SEVER / CLIENT/ CERTIFICATION are in same domain, otherwise the server will throw Error like:

- Failed to read message: remote error: tls: bad certificate
