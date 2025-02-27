# Script used to set up initial proxmox terraform user
echo "Creating user 'terraform@pve' and role 'terraform-role'. Please note token will be generated below!"
pveum role add terraform-role -privs "SDN.Use Pool.Allocate VM.Migrate Sys.Audit Sys.Modify Sys.Console VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role terraform-role
pveum user token add terraform@pve terraform-token --privsep=0

# to modify roles:
# pveum role modify terraform-role -privs "SDN.Use Pool.Allocate VM.Migrate Sys.Audit Sys.Modify Sys.Console VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
