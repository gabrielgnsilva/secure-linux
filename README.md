<!-- @format -->

# Secure linux server

This guide provides an introduction to essential Linux server security practices. Although it primarily focuses on Debian and Ubuntu, the principles discussed here are applicable to other Linux distributions as well. I also recommend exploring these topics further and adapting them to your specific needs.

<!-- vim-markdown-toc GFM -->

* [Auto updates](#auto-updates)
    * [Installing unattended-upgrades](#installing-unattended-upgrades)
    * [Configuring unattended-upgrades](#configuring-unattended-upgrades)
    * [How unattended-upgrades Works](#how-unattended-upgrades-works)
* [UFW](#ufw)
    * [Installing UFW](#installing-ufw)
    * [Allowing Essential Services](#allowing-essential-services)
    * [Setting Default Policies](#setting-default-policies)
    * [Enabling UFW](#enabling-ufw)
* [Secure SSH](#secure-ssh)
    * [Editing SSH Configuration](#editing-ssh-configuration)
        * [Disable Challenge-Response Authentication](#disable-challenge-response-authentication)
        * [Enable PAM](#enable-pam)
        * [Disable Password Authentication](#disable-password-authentication)
        * [Disable Root Login](#disable-root-login)
    * [Optional Settings for Additional Protection](#optional-settings-for-additional-protection)
        * [Limit SSH to IPv6](#limit-ssh-to-ipv6)
        * [Change the Default Port](#change-the-default-port)
    * [Restarting SSH](#restarting-ssh)
* [Edit sysctl.conf](#edit-sysctlconf)
    * [Create and Edit the sysctl Configuration File](#create-and-edit-the-sysctl-configuration-file)
        * [Prevent IP Spoofing](#prevent-ip-spoofing)
        * [Disable Accepting ICMP Redirects](#disable-accepting-icmp-redirects)
        * [Disable Sending ICMP Redirects](#disable-sending-icmp-redirects)
        * [Disable IP Source Routing](#disable-ip-source-routing)
        * [Disable Router Advertisements](#disable-router-advertisements)
        * [Enable Martian Packets Log](#enable-martian-packets-log)
        * [Disable echo requests](#disable-echo-requests)
        * [Disable IP Forwarding](#disable-ip-forwarding)
        * [Prevent TCP SYN Flood attack](#prevent-tcp-syn-flood-attack)
* [Use AppArmor or SELinux](#use-apparmor-or-selinux)
    * [SELinux](#selinux)
        * [Installing SELinux](#installing-selinux)
        * [Enabling SELinux](#enabling-selinux)
        * [Validation](#validation)
        * [Change Policy to Targeted](#change-policy-to-targeted)
        * [Rebooting](#rebooting)
    * [AppArmor](#apparmor)
* [Fail2Ban](#fail2ban)
    * [Installation](#installation)
    * [Configuring Fail2Ban](#configuring-fail2ban)
    * [Enable Fail2Ban](#enable-fail2ban)

<!-- vim-markdown-toc -->

## Auto updates

Enabling unattended-upgrades is a good practice on some systems to ensure that security updates are applied automatically. However, you might prefer to keep it disabled as it gives you more control over the updates and more importantly, has less chance of breaking your system occasionally due to a bad or critical update.

### Installing unattended-upgrades

Start by installing the `unattended-upgrades` package using the following command:

```bash
apt install unattended-upgrades

```

This will install the necessary package and its dependencies. Once installed, you can configure it to automatically apply security updates.

### Configuring unattended-upgrades

After installing the package, you'll need to configure it. The `dpkg-reconfigure` command allows you to easily adjust the settings for unattended upgrades, including setting the priority level.

To enable unattended-upgrades and configure its settings, run:

```bash
dpkg-reconfigure unattended-upgrades
```

For more details, you can read the official documentation at [Debian's Wiki on Unattended Upgrades](https://wiki.debian.org/UnattendedUpgrades)

### How unattended-upgrades Works

Once enabled and configured, `unattended-upgrades` will periodically check for and install updates. These updates are automatically downloaded and installed, reducing the need for manual intervention. This helps keep your system secure by ensuring that critical updates are applied quickly,

## UFW

When setting up a Linux server, it's recommended to configure a firewall to control which network traffic is allowed to reach your system. By default, most systems are configured to accept all incoming traffic, which poses some security risks. The best practice is to deny all incoming traffic by default and only allow specific traffic that you explicitly trust and need for your services.

UFW (Uncomplicated Firewall) is an easy-to-use interface for managing iptables firewall rules. It simplifies the process of setting up and configuring firewall rules on a Linux server, making it an excellent choice for beginners and experienced users alike.

### Installing UFW

To get started with UFW, first, you need to install it. You can do so with the following command:

```bash
apt install ufw
```

This command will install UFW and its necessary dependencies on your server.

### Allowing Essential Services

Once UFW is installed, you need to define which types of network traffic are allowed to pass through your firewall. For a basic web server setup, you’ll likely want to allow SSH (for remote access) as well as HTTP and HTTPS (for web traffic).

To allow SSH, HTTP, and HTTPS traffic, run the following commands:

```bash
ufw limit xx/tcp  # This command allows SSH connections but limits the number of login attempts to help prevent brute-force attacks (default port 22).
ufw allow 80/tcp  # This opens the HTTP port (port 80) for web traffic.
ufw allow 443/tcp # This opens the HTTPS port (port 443) for encrypted web traffic.
```

You can adjust the service ports if you're using custom ports or other services. For example, if you're running a web application on a non-standard port, you can use `ufw allow <port_number>/tcp`.

### Setting Default Policies

Once you've allowed the necessary services, it's time to set the default policies for incoming and outgoing connections.

```bash
ufw default deny incoming  # This ensures that any traffic not explicitly allowed will be blocked.
ufw default allow outgoing #
```

These default settings mean that only the services you have explicitly allowed (such as SSH, HTTP, and HTTPS) will be accessible, while everything else is blocked, helping to reduce your attack surface.

### Enabling UFW

Once you have configured your firewall rules, it’s time to enable UFW.

This will activate the firewall with the rules you've set up:

```bash
ufw enable
```

After enabling UFW, the firewall will start filtering traffic based on your rules. The `ufw status` command can be used to check the current status and see a list of active rules:

```bash
ufw status
```

This will display whether UFW is active and show the current set of allowed and denied services.

## Secure SSH

SSH is one of the most common ways to remotely access a Linux server. While SSH provides strong encryption, there are several best practices you can implement to further harden SSH and make unauthorized access more difficult.

### Editing SSH Configuration

To begin securing SSH, you need to make some changes to the SSH server's configuration file: `/etc/ssh/sshd_config`.

#### Disable Challenge-Response Authentication

Challenge-response authentication can sometimes be used for multi-factor authentication setups, but in practice it often asks only for the user's password. It's best to disable it unless specifically needed.

```text
ChallengeResponseAuthentication no
```

#### Enable PAM

PAM enables additional authentication mechanisms beyond simple passwords, such as two-factor authentication (2FA).

```text
UsePAM yes
```

#### Disable Password Authentication

Disabling password authentication entirely is one of the most effective ways to prevent brute-force attacks. Instead of relying on password-based authentication, you can use SSH keys for more secure, password-less logins.

```text
PasswordAuthentication no
```

#### Disable Root Login

Allowing root login via SSH is a major security risk. By disabling root login, users must log in as a regular user and then escalate to root using `sudo`, which provides an additional layer of security. This reduces the potential for attackers to gain root access directly.

```text
PermitRootLogin no
```

### Optional Settings for Additional Protection

While these options may seem useless, they can potentally limit the attack vectors.

#### Limit SSH to IPv6

While IPv4 is more widely used, restricting SSH to IPv6 can limit potential attack vectors, though it's not a strict security measure and may cause issues on networks that don't support IPv6. This is generally optional and situational.

```text
AddressFamily inet6
```

#### Change the Default Port

By default, SSH listens on port 22, which is well-known and often targeted by attackers. Changing the port to something non-standard can reduce the likelihood of automated attacks, though it is not a foolproof security measure. Choose a port number between 1024 and 65535 that isn’t already in use.

```text
Port <your_custom_port>
```

### Restarting SSH

After making the necessary changes, save and exit the file. To apply the changes, restart the SSH service:

```bash
systemctl restart sshd
```

## Edit sysctl.conf

The `sysctl` utility is used to modify kernel parameters at runtime. These parameters control a wide variety of aspects of system performance and behavior. By editing the `sysctl.conf` or adding specific configuration files in `/etc/sysctl.d/`, you can harden the Linux kernel to better defend against various attacks and secure your server.

Below is an example of how you can secure your server using `sysctl` settings. We’ll create and edit a custom configuration file to ensure that the settings persist across reboots.

### Create and Edit the sysctl Configuration File

To begin, create a custom configuration file:

```bash
[EDITOR] /etc/sysctl.d/secure-server.conf
```

Now, add the following settings to the file to secure your system.

#### Prevent IP Spoofing

The `rp_filter` (reverse path filtering) recommended setting is to enable strict mode to prevent IP spoofing from DDos attacks. If using asymmetric routing or other complicated routing, then loose mode is recommended (3).

```text
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv6.conf.all.rp_filter=1
net.ipv6.conf.default.rp_filter=1

```

#### Disable Accepting ICMP Redirects

ICMP redirects are used by routers to inform hosts of a better route to reach a destination. However, this can be exploited by attackers in Man-in-the-Middle (MITM) attacks. By disabling ICMP redirects, we ensure that the server won't participate in these redirects.

This feature of the IPv4 protocol has few legitimate uses. It should be disabled unless absolutely required."

```text
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.secure_redirects = 0
```

#### Disable Sending ICMP Redirects

Just as you shouldn’t accept ICMP redirects, you should also prevent your server from sending them. These messages contain information from the system’s route table possibly revealing portions of the network topology. This further secures the server by ensuring that it does not act as a router in the network.

The ability to send ICMP redirects is only appropriate for systems acting as routers.

```text
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.send_redirects = 0
net.ipv6.conf.default.send_redirects = 0
```

#### Disable IP Source Routing

Source routing allows a sender to specify the route that packets should take through the network. This feature can be exploited by attackers to bypass firewalls or other network defenses. This setting should be disabled unless it is absolutely required, such as when IPv4 forwarding is enabled and the system is legitimately functioning as a router.

```text
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
```

#### Disable Router Advertisements

An illicit router advertisement message could result in a man-in-the-middle attack.

```text
net.ipv6.conf.all.accept_ra = 0
net.ipv4.conf.all.accept_ra = 0
```

#### Enable Martian Packets Log

Martian packets are packets with addresses that are reserved for special use and are not routable on the network. These are often signs of malicious activity or misconfigurations. By logging these packets, you can detect abnormal traffic that might indicate an attack or misconfigured device.

```text
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
```

#### Disable echo requests

Responding to broadcast (ICMP) echoes facilitates network mapping and provides a vector for amplification attacks.

Ignoring ICMP echo requests (pings) sent to broadcast or multicast addresses makes the system slightly more difficult to enumerate on the network.

```text
net.ipv4.icmp_echo_ignore_broadcasts = 1
```

#### Disable IP Forwarding

Routing protocol daemons are typically used on routers to exchange network topology information with other routers. If this capability is used when not required, system network information may be unnecessarily transmitted across the network.

```text
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
```

#### Prevent TCP SYN Flood attack

A TCP SYN flood attack can cause a denial of service by filling a system’s TCP connection table with connections in the SYN_RCVD state. Syncookies can be used to track a connection when a subsequent ACK is received, verifying the initiator is attempting a valid connection and is not a flood source. This feature is activated when a flood condition is detected, and enables the system to continue servicing valid connection requests.

```text
net.ipv4.tcp_syncookies = 1
```

## Use AppArmor or SELinux

Both SELinux (Security-Enhanced Linux) and AppArmor provide mandatory access control (MAC) to limit the actions of processes and users on your system. These tools can help protect against privilege escalation, unauthorized access, and malware.

### SELinux

SELinux is typically used with distributions like CentOS, Fedora, and RHEL, but it can also be used on Ubuntu if needed. You can configure SELinux in enforcing mode, which strictly enforces security policies, or permissive mode for testing.

PS: If you plan on using SELinux on Ubuntu, make sure to uninstall AppArmor, as it comes pre-installed and conflicts with SELinux

#### Installing SELinux

To install the required SELinux packages run the command below:

```bash
apt install policycoreutils selinux-basics selinux-utils
```

#### Enabling SELinux

Activate SELinux by running the command below.

```bash
selinux-activate
```

The activation will ask to reboot the system. Check the status of SELinux before rebooting it! First, review the current state of your new SELinux host on the next section ([Validation](#validation)).

#### Validation

Run the commands `getenforce` and `sestatus`. Both commands will show the state of SELinux. The only difference is that `sestatus` will provide more detailed output.

```bash
$ getenforce
Disabled
```

This means that your SELinux is ready to work. It’s “active” but not yet turned on.

#### Change Policy to Targeted

Setting the SELinux policy to `targeted` or a more specialized policy ensures the system will confine processes that are likely to be targeted for exploitation, such as network or system services.

The SELinux targeted policy is appropriate for general-purpose desktops and servers, as well as systems in many other roles. To configure the system to use this policy, add or correct the following line in `/etc/selinux/config`:

```bash
$ cat /etc/selinux/config
[...]
SELINUXTYPE=targeted
```

Other policies, such as `mls`, provide additional security labeling and greater confinement but are not compatible with many general-purpose use cases.

#### Rebooting

Proceed to reboot the system.

```bash
shutdown -r now
```

### AppArmor

AppArmor is often easier to configure and is commonly used on Ubuntu-based distributions. AppArmor works by confining programs to a limited set of resources. Ubuntu comes with AppArmor pre-installed and enabled by default.

To check the status of AppArmor use:

```bash
apparmor_status
```

## Fail2Ban

Fail2Ban is a tool that scans log files and bans IPs that show malicious activity. It is often used to prevent brute-force attacks on services like SSH.

### Installation

To install Fail2Ban run the following command:

```bash
apt install fail2ban
```

### Configuring Fail2Ban

After installation, you can create or edit the local configuration file to customize your settings. The default configuration is good for most users, but you can fine-tune it based on your needs.

```bash
$ cat /etc/fail2ban/jail.local

[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8 ::1
anaction = ufw

[sshd]
enabled  = true
logpath  = /var/log/fail2ban-ssh.log
```

Make sure to create the log file as it can result in failure while loading Fail2Ban if the file does not exist.

```bash
touch /var/log/fail2ban-ssh.log
```

### Enable Fail2Ban

To enable Fail2Ban run the following command:

```bash
systemctl enable --now fail2ban.service
```

Fail2Ban will now monitor SSH (and other services) for failed login attempts and automatically block IP addresses that exceed a certain number of failures.
