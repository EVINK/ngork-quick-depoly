#!/bin/bash
echo > ngrok.cfg
echo server_addr: "ngrok.evink.cn:4443"  >> ngrok.cfg
echo trust_host_root_certs: false >> ngrok.cfg
/usr/local/ngrok/bin/ngrok -config=ngrok.cfg -subdomain=api "$1"
