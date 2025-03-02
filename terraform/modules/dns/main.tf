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
    #!/bin/bash

    # Function to install Pi-hole
    install_pihole() {
        # Update and install required packages
        apt-get update && apt-get install -y curl

        mkdir -p /etc/pihole/
        touch /etc/pihole/setupVars.conf

        cat <<EOT > /etc/pihole/setupVars.conf
    export PIHOLE_INTERFACE=eth0
    export PIHOLE_STATIC_IP=${split("/", var.ipv4_cidr)[0]}
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
        
        echo "Pi-hole installation complete."
    }

    # Check if Pi-hole is already installed
    if command -v pihole > /dev/null || [ -d "/etc/pihole" ]; then
        echo "Pi-hole is already installed. Skipping installation."
    else
        install_pihole
    fi
    EOF
    ,
    <<-EOF
    # Configure custom DNS entries
    # Loop through each DNS entry using separate variables passed from Terraform
    PASSWORD="${var.pihole_password}"
    
    # Process each DNS entry
    ${join("\n\n", [for host in var.custom_dns_hosts : <<HOSTENTRY
    # Process entry for ${host.hostname}
    IP="${host.proxy}"
    HOSTNAME="${host.hostname}"
    
    echo "Adding DNS entry: $IP $HOSTNAME"
    
    # Get authentication token (SID)
    SID=$(curl -s -X POST "http://127.0.0.1/api/auth" \
        -H "Content-Type: application/json" \
        -d "{\"password\":\"$PASSWORD\"}" | jq -r '.session.sid')

    echo $SID
    
    if [ -z "$SID" ]; then
        echo "Authentication failed. Please check your password."
        exit 1
    fi

    # Add custom DNS entry
    # Using SID directly in the URL query parameter
    RESPONSE=$(curl -s -X PUT "http://127.0.0.1/api/config/dns/hosts/$IP%20$HOSTNAME?sid=$SID" \\
        -H "Content-Type: application/json" \
        -H "Cache-Control: no-cache")
    
    echo $RESPONSE
    HOSTENTRY
    ])}

    # Restart Pi-hole
    systemctl restart pihole-FTL.service
    EOF
  ]

}

