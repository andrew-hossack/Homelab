module "pihole_dns" {
  source          = "../container_template"
  container_name  = var.container_name
  password        = var.password
  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key
  ipv4_cidr       = var.ipv4_cidr
  gateway         = var.gateway
  provisioning_commands = [
    <<-EOF
    # Update and install required packages
    apt-get update && apt-get install -y curl

    mkdir -p /etc/pihole/
    touch /etc/pihole/setupVars.conf

    cat <<EOT > /etc/pihole/setupVars.conf
    export PIHOLE_INTERFACE=eth0
    export PIHOLE_STATIC_IP=${split("/",var.ipv4_cidr)[0]}
    export PIHOLE_DNS_1=8.8.8.8
    export PIHOLE_DNS_2=8.8.4.4
    export QUERY_LOGGING=true
    export INSTALL_WEB_INTERFACE=true
    EOT

    # Install Pi-hole
    curl -L https://install.pi-hole.net | bash /dev/stdin --unattended

    # Set Pi-hole web interface password
    pihole setpassword ${var.pihole_password}
    pihole reloadlists

    # Install Unbound for recursive DNS
    # apt-get install -y unbound

    # Configure Unbound
    # cat <<EOT > /etc/unbound/unbound.conf.d/pi-hole.conf
    # server:
    #     verbosity: 0
    #     interface: 127.0.0.1
    #     port: 5335
    #     do-ip4: yes
    #     do-udp: yes
    #     do-tcp: yes
    #     do-ip6: no
    #     prefer-ip6: no
    #     harden-glue: yes
    #     harden-dnssec-stripped: yes
    #     use-caps-for-id: no
    #     edns-buffer-size: 1472
    #     prefetch: yes
    #     num-threads: 1
    #     so-rcvbuf: 1m
    #     private-address: 192.168.0.0/16
    #     private-address: 172.16.0.0/12
    #     private-address: 10.0.0.0/8
    # forward-zone:
    #     name: "."
    #     forward-addr: 1.1.1.1@53#cloudflare-dns.com
    #     forward-addr: 1.0.0.1@53#cloudflare-dns.com
    # EOT

    # Restart Unbound
    # systemctl restart unbound

    # Configure Pi-hole to use Unbound
    # sed -i 's/PIHOLE_DNS_1=.*/PIHOLE_DNS_1=127.0.0.1#5335/' /etc/pihole/setupVars.conf
    # sed -i '/PIHOLE_DNS_2=/d' /etc/pihole/setupVars.conf

    # Restart Pi-hole
    pihole restartdns
  EOF
  ]
}
