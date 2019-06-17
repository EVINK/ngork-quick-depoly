# ngrok-quick-depoly

ENV-Success: Ubuntu 18.04 LTS (Server&Client)

### Server

1. move ngrok_install.sh to your home directory
2. run it with """ $ sudo ./ngrok_install.sh """
4. release go*.tar.gz with "$ tar xvf go*.tar.gz" and rename dir go/ to go1.4/
3. build ngrok-client
4. done

### Client

1. copy from the remote server path:/usr/local/ngrok/bin/ngrok to your local machine
2. run script " $ run_client.sh $APP_PORT "


### Http -> Https

1. certbot
