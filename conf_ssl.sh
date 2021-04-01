#!/bin/bash
cd /etc/squid/ssl_cert

# Create the DH PEM certificate
openssl dhparam -outform PEM -out /etc/squid/ssl_cert/squid_dhparam.pem 2048

# Set the permissions to the certification folder
chown squid:squid /etc/squid/ssl_cert/squid*
chmod 400 /etc/squid/ssl_cert/squid*

# LET'S KILL SQUID!!!!!
/usr/sbin/squid -k shutdown >> /dev/null

# Wait Squid to die (Squid takes his time). THIS IS AN AWFUL SOLUTION. FIX. 
echo "--- Waiting Squid to stop; this can take some time ---"
while :
do
    if [ -z "$(pgrep squid)" ]
    then
        break
    else 
        sleep 1
    fi
done

# Create the Certificates
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/squid/ssl_cert/squid_ca.key -out /etc/squid/ssl_cert/squid_ca.crt
openssl x509 -in /etc/squid/ssl_cert/squid_ca.crt -outform DER -out /etc/squid/ssl_cert/squid_browser.der


# Comment the http_port line in config
sed -i 's/http_port 3128/#http_port 3128/' /etc/squid/squid.conf

# Adds SSL configuration  to the configuration file
echo "

# SSL Bump Configuration
http_port 3128 tcpkeepalive=60,30,3 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=20MB tls-cert=/etc/squid/ssl_cert/squid_ca.crt tls-key=/etc/squid/ssl_cert/squid_ca.key cipher=HIGH:MEDIUM:!LOW:!RC4:!SEED:!IDEA:!3DES:!MD5:!EXP:!PSK:!DSS options=NO_TLSv1,NO_SSLv3,SINGLE_DH_USE,SINGLE_ECDH_USE tls-dh=prime256v1:/etc/squid/ssl_cert/squid_dhparam.pem

acl intermediate_fetching transaction_initiator certificate-fetching
http_access allow intermediate_fetching

sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/squid/ssl_db -M 20MB

sslproxy_cert_error allow all

ssl_bump stare all

" >> /etc/squid/squid.conf

# Create SSL DB and set permissions
chmod -R 777 /var/lib/squid
/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 20MB
chown -R squid:squid /var/lib/squid
chmod -R 700 /var/lib/squid

# Start Squid
/usr/sbin/squid