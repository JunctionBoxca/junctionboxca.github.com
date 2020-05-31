---
title:    Infrastructure
created_at: 2011-05-29
layout: default
permalink: /resources/infrastructure/
---

[USE Method Checklist for Linux Performance](http://dtrace.org/blogs/brendan/2012/03/07/the-use-method-linux-performance-checklist/)

### Linux and MacBook Goodness

[Fix that trackpad](http://uselessuseofcat.com/?p=74)

### Byobu/TMUX Sharing

    $ byobu -S /tmp/pair
    $ chmod 777 /tmp/pair
    $ tmux -S /tmp/pair attach

### LXC Host NAT

    -A POSTROUTING -t nat -o eth0 -j MASQUERADE
    -A FORWARD -t nat -i eth0   -o lxcbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    -A FORWARD -t nat -i lxcbr0 -o eth0   -j ACCEPT

### LXC Templates

`/usr/lib/lxc/templates`

### High Availability

-   [DR:DB](http://www.drbd.org/)
-   [Load Balancer
    Methods](http://uk.loadbalancer.org/load_balancing_methods.php)

### Cloud Providers

-   [Amazon Web Services](http://aws.amazon.com/)
-   [Rackspace](http://www.rackspace.com/cloud/)

### Configuration Management

-   [Chef](http://www.opscode.com/)
-   [Puppet](http://www.puppetlabs.com/)

### Virtual Machine Software

-   [Vagrant](http://vagrantup.com/)
-   [VirtualBox](http://www.virtualbox.org/)

### OS's

-   [CentOS](http://centos.org/)
-   [FreeBSD](http://www.freebsd.org/)
-   [NetBSD](http://www.netbsd.org/)
-   [OpenBSD](http://www.openbsd.org/)
-   [Slackware](http://www.slackware.com/)
-   [Ubuntu](http://www.ubuntu.com/)

### Alerting

-   [Alertra](http://www.alertra.com/)
-   [Pingdom](http://www.pingdom.com/)
-   Gomez

### Monitoring

-   [Cacti](http://www.cacti.net/)
-   [Net-SNMP](http://net-snmp.sourceforge.net/)
-   [Nagios](http://www.nagios.org/)

### Authorisation and Authentication

-   [LDAP Auth for
    Ubuntu](https://help.ubuntu.com/community/LDAPClientAuthentication)
