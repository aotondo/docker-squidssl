#!/bin/bash

# Check if the /etc/squid folder is empty, if is, uncompress the tar with the configuration files 
# and create swap directories
if [ -z "$(ls /etc/squid)" ]
    then 
        echo "-- Populating /etc/squid --" >> /dev/stdout
        # Populate /etc/squid 
        tar xvzf /root/squidconfig.tar.gz 
        cp /squid/* /etc/squid/
        rm -fr squid
        mkdir -p /etc/squid/ssl_cert
fi 

# Check if swap directories exist, if the directory is empty creates the structure 
if [ -z "$(ls /var/spool/squid)" ]
    then
    # Set swap permissions to /var/spool/squid
    echo "-- Setting up permissions of swap directories --" >> /dev/stdout
    chown squid:squid /var/spool/squid
    chmod -R 700 /var/spool/squid
    
    # Create swap directories
    echo "-- Creating swap directories --" >> /dev/stdout
    /usr/sbin/squid -z >> /dev/null
    sleep 10 # GIVES TIME TO squid -z TO FINISH. THIS IS AWFUL. FIX. 
fi

# Check if the log files are created in case those are in volumes.
if [ -z "$(ls /var/log/squid )" ]
    then
        echo "-- Creating log files --" >> /dev/stdout 
        mkdir -p /var/log/squid
        touch /var/log/squid/access.log 
        touch /var/log/squid/cache.log 
fi 

# Set permissions
echo "-- Setting up permissions of configuration files --" >> /dev/stdout
chown -R squid:squid /etc/squid
chmod -R 700 /etc/squid 

echo "-- Setting up permissions of log files --" >> /dev/stdout 
chown -R squid:squid /var/log/squid
chmod -R 700 /var/log/squid

# Run Squid and tail over Squid's logs.
echo "-- Running Squid --" >> /dev/stdout
/usr/sbin/squid

# Run tail 
echo "-- Checking logs with tail --" >> /dev/stdout 
tail -n 20 -f /var/log/squid/*.log >> /dev/stdout