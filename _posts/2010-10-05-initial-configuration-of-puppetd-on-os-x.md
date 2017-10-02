---
title:      Initial Configuration of Puppetd on OS X
created_at: 2010-10-05 12:00:00 +00:00
layout:     default
---

Configuring puppetd on OS X

Create the User and Group accounts;

    sudo dscl . -create /Groups/puppet
    sudo dscl . -create /Groups/puppet PrimaryGroupID 300

    sudo dscl . -create /Users/puppet
    sudo dscl . -create /Users/puppet PrimaryGroupID 300
    sudo dscl . -create /Users/puppet UniqueID 300
    sudo dscl . -create /Users/puppet UserShell /usr/bin/false

Create the folders

    sudo mkdir /etc/puppet
    sudo mkdir -p /var/puppet/log
    sudo chown -R puppet:puppet /var/puppet
    sudo chown -R puppet:puppet /etc/puppet

Create the config file.

    sudo puppetd --genconfig > /etc/puppet/puppet.conf

Modify your /etc/hosts file with an entry for puppet (setting the server in the puppet.conf offers more flexibility should you move servers or change IP's).

If you run into issues with your certificates;

#### Client

    rm -rf /etc/puppet/ssl

#### Server

    puppetca --clean CERT_ID
