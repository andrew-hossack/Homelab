module "uptime_kuma_lxc" {
  source          = "../container_template"
  container_name  = var.container_name
  password        = var.password
  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key
  ipv4_cidr       = var.ipv4_cidr
  gateway         = var.gateway
  provisioning_commands = [
    <<-EOF
    apt-get update && apt-get install git npm -y
    git clone https://github.com/louislam/uptime-kuma.git
    cd uptime-kuma
    npm run setup

    # Run in the background using PM2
    # Install PM2 if you don't have it:
    npm install pm2 -g && pm2 install pm2-logrotate

    # Start Server
    pm2 start server/server.js --name uptime-kuma
    # If you want to add it to startup
    pm2 save && pm2 startup
    EOF
  ]

}
