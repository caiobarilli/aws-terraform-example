locals {
  mount_script = templatefile("${path.module}/utils/mount.sh.tpl", {
    mountpoint = var.ec2_mountpoint
    label      = var.ec2_volume_label
  })

  cleanup_script = templatefile("${path.module}/utils/cleanup.sh.tpl", {})

  userdata = templatefile("${path.module}/userdata.sh.tpl", {
    mount_script   = local.mount_script
    cleanup_script = local.cleanup_script
    mountpoint     = var.ec2_mountpoint
    label          = var.ec2_volume_label
  })
}
