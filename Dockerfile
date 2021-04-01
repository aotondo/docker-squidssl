FROM alpine:3.13.3
ENV container docker
RUN apk update && \
    apk upgrade && \
    apk add squid bash openssl
ADD https://github.com/aotondo/docker-squidssl/raw/main/squidconfig.tar.gz /root/
ADD https://github.com/aotondo/docker-squidssl/raw/main/start.sh /usr/sbin/start.sh
ADD https://github.com/aotondo/docker-squidssl/raw/main/conf_ssl.sh /usr/sbin/conf_ssl.sh
RUN chmod +x /usr/sbin/start.sh && \
    chmod +x /usr/sbin/conf_ssl.sh && \
    mkdir -p /var/lib/squid
EXPOSE 3128 3128/udp
EXPOSE 3128 3128/tcp
ENTRYPOINT ["/bin/bash", "-c", "/usr/sbin/start.sh"] 
