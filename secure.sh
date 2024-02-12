# Requirements:
# ufw
# fail2ban

# UFW
ufw limit 22/tcp  
ufw allow 80/tcp  
ufw allow 443/tcp 
ufw default deny incoming  
ufw default allow outgoing

ufw enable

# Sysctl
{
    printf "# Prevent some spoofing attacks\n"
    printf "net.ipv4.conf.default.rp_filter=1\n"
    printf "net.ipv4.conf.all.rp_filter=1\n"
    printf "\n"
    printf "# Do not accept ICMP redirects (prevent MITM attacks)\n"
    printf "net.ipv4.conf.all.accept_redirects = 0\n"
    printf "net.ipv6.conf.all.accept_redirects = 0\n"
    printf "\n"
    printf "# Do not send ICMP redirects (we are not a router)\n"
    printf "net.ipv4.conf.all.send_redirects = 0\n"
    printf "\n"
    printf "# Do not accept IP source route packets (we are not a router)\n"
    printf "net.ipv4.conf.all.accept_source_route = 0\n"
    printf "net.ipv6.conf.all.accept_source_route = 0\n"
    printf "\n"
    printf "# Log Martian Packets\n"
    printf "net.ipv4.conf.all.log_martians = 1\n"
    printf "\n"
    printf "# Auto-enabled by xs-tools:install.sh\n"
    printf "net.ipv4.conf.all.arp_notify = 1\n"
} | tee /etc/sysctl.d/secure-linux.conf

# Fail2Ban
{
    printf "[DEFAULT]\n"
    printf "ignoreip = 127.0.0.1/8 ::1\n"
    printf "bantime = 3600\n"
    printf "findtime = 600\n"
    printf "maxretry = 5\n"
    printf "\n"
    printf "[sshd]\n"
    printf "enabled = true\n"
    printf "logpath = /var/log/fail2ban-ssh.log\n"
} | tee /etc/fail2ban/jail.local

touch /var/log/fail2ban-ssh.log
systemctl enable --now fail2ban.service
