# Secure linux server

How to Secure A Web Server

## Requirements

1. ufw
2. fail2ban
3. unattented-upgrades (ubuntu)

## Auto updates

Enabling unattended-upgrades is recommended for all systems to ensure that security updates are installed in a timely manner. However, you may want to keep it disabled as it gives you more control over the updates and more importantly, has less chance of breaking your system due to a bad update.

``` bash
#!/bin/bash

apt install unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

## UFW

``` bash
#!/bin/bash

ufw limit 22/tcp  
ufw allow 80/tcp  
ufw allow 443/tcp  
ufw default deny incoming  
ufw default allow outgoing

ufw enable
```

## Secure SSH

Common settings to secure SSH.

Edit the file `/etc/ssh/sshd_config` and make the following changes:

``` text
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
PermitRootLogin no
```

# Edit sysctl.conf

Settings to secure the server.

Create and edit the file `/etc/sysctl.d/secure-server.conf` and add the following settings:

``` text
# Prevent some spoofing attacks
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0

# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martian Packets
net.ipv4.conf.all.log_martians = 1

# Generate gratuitous arp requests when device is brought up or hardware address changes.
net.ipv4.conf.all.arp_notify = 1
```
