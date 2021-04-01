# docker-squidssl
Squid 5 with SSL implementation in Docker.


This image is based on Alpine 3.13.3 and Squid 5 for x86_64 architectures (Raspberry PI support soon :D ) and was build having docker-compose in mind, if you need to install docker-compose you can find a tutorial in here: https://docs.docker.com/compose/install/

First, you need to download the docker-compose.yaml file, then build the container with "docker-compose up", this will allow you to have a fully functional HTTP Squid proxy at the port 3128.

Running Squid with SSL Bump.
**********************************************************************************************************************************************************
WARNING: This will desencrypt the traffic and that can violete your users privacy. before continue, please read the information in the Squid Wiki in here: https://wiki.squid-cache.org/Features/SslBump
**********************************************************************************************************************************************************
In order to use HTTPS with SSL run docker exec -ti squidproxy /usr/sbin/conf_ssl.sh

The script will automatically generate the certificates and configurate Squid to use SSL Bump. 

After the script is done, copy the squid_browser.der certificate into your computer. If you are using the docker-compose.yaml this file will be in ./cfg-squid/ssl_cert/, then give the file your users permission and import to the browser.
