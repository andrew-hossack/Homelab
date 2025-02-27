# Homelab 

#### Useful Commands

###### IP Addresses

- Private IP: `ipconfig getifaddr en0`
- Public IP: `dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com`
- Both public / private: `ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'`
- Find all (?) IPs on network `arp -a`
- List all open ports locally `nc -zv localhost 1-65535 2>&1 | grep succeeded`

###### UPNP Port Forwarding

- List active port forwards: `upnpc -l`
- Add port forward: `upnpc -a <local IP> <private port> <public port> tcp`
- Delete port forward: `upnpc -d <private port> tcp`
- 

#### iDRAC Setup

To find the IP of the server, run:

`arp -a`

The IP of the server will be the MAC address: `bc:d0:74:48:dd:38`

Next, start the iDRAC server manager, replacing the `IDRAC_HOST` with the host IP found above.

- Username: `root`
- Password: `calvin`

```bash
docker run -d \
  -p 5801:5800 \
  -p 5901:5900 \
  -e DISPLAY_WIDTH=1920 \
  -e DISPLAY_HEIGHT=1080 \
  -e IDRAC_HOST=10.9.6.131 \
  -e IDRAC_USER=root \
  -e IDRAC_PASSWORD=calvin \
  domistyle/idrac6
```

Open http://localhost:5801/ in your browser to access iDRAC server manager. 

Here you can manage BIOS, OS installation, etc.

#### ProxMox

Using iDRAC, choose to boot into Normal system boot. Then, chose `ProxMox VE`. From there, you will login with the following:

ProxMox login:

- Username: `root`
- Password: ``

Note that the email address used to sign up is ``. 

The server is not using a static IP, and instead uses DHCP for IP assignment. TODO - Set up static IP addresses.

 To set the webpage IP for proxmox, change the `/etc/network/interfaces` and `/etc/hosts` file to desired default gateway and statix IP values.

Next, Accessible through the web URL https://10.9.6.133:8006/, or whatever IP you had set.

### Nginx Reverse Proxy (10.9.6.165)

We use nginx as a reverse proxy for custom domain names and (eventually) SSL certs using mkcert. 

To change and add hosts, modify the `/etc/nginx/sites-available/reverse-proxy.conf ` file to include the new server name. You may need to restart the service with `systemctl reload nginx`.

### Pi Hole DNS (10.9.6.171)

Admin page at http://10.9.6.171/admin with password: ``

### Dynamic DNS Client (10.9.6.180)

Manages dynamic changing DNS and provides a static hostname. Using with OpenVPN.

u: ``

p: ``

### Tailscale VPN

Username:  (google login)

### Uptime Kuma Dashboard

u: 

p: 

### Router Setup

TODO - set up port forwarding for OpenVPN host IP

Set up DHCP reserved range 

Move instances to reserved range

TODO - set up more partitions on my sda raid array to accomodate storage, etc for my proxmox storage

---

### Adding custom Service Domains

- Add to nginx configs (see above)
- Add to Local DNS (http://pi.hole/admin/dns_records.php)