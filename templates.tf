locals {
  userdata = templatefile("${path.module}/userdata.sh.tpl", {
    mount_script   = local.mount_script
    cleanup_script = local.cleanup_script
  })

  mount_script = templatefile("${path.module}/utils/mount.sh.tpl", {
    mountpoint  = var.ec2_mountpoint
    label       = var.ec2_volume_label
    username    = var.ssh_username
    device_name = var.device_name
  })

  cleanup_script = templatefile("${path.module}/utils/cleanup.sh.tpl", {})
}
