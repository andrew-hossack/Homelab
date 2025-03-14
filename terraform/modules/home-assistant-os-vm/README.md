# Home Assistant

## Add-ons

_**Info:** Config file is at `/mnt/data/supervisor/homeassistant/configuration.yml`_

- [Install HACS](https://my.home-assistant.io/redirect/supervisor_addon/?addon=cb646a50_get&repository_url=https%3A%2F%2Fgithub.com%2Fhacs%2Faddons)
- [Install Pihole v6](https://github.com/user-08-151/hole_v6)
- [SmartRent](https://github.com/ZacheryThomas/homeassistant-smartrent)
- [Proxmox VE](https://www.home-assistant.io/integrations/proxmoxve)
  ```yaml
  proxmoxve:
    - host: IP_ADDRESS
  username: USERNAME
  password: PASSWORD
  nodes:
    - node: NODE_NAME
      vms:
        - VM_ID
      containers:
        - CONTAINER_ID
  ```
