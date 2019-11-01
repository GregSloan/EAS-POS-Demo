////////////////////////////////
// Templates

data "template_file" "permanent_peer_hab_sup_Store1" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

# Template vars are conditionally set via the `event-stream-enabled` variable.
# If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer --event-stream-application=PermanentPeer --event-stream-environment=Gen1_Prod --event-stream-site=Store1 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

# Template vars are conditionally set via the `event-stream-enabled` variable.
# If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
data "template_file" "backoffice_hab_sup_Store1" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store1_permanent_peer.private_ip} --event-stream-application=BackOffice --event-stream-environment=Gen1_Prod --event-stream-site=Store1 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "register_hab_sup_Store1" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store1_permanent_peer.private_ip} --event-stream-application=RegisterPOS --event-stream-environment=Gen1_Prod --event-stream-site=Store1 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "permanent_peer_hab_sup_Store2" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"


  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer --event-stream-application=PermanentPeer --event-stream-environment=Gen1_Prod --event-stream-site=Store2 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "backoffice_hab_sup_Store2" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store2_permanent_peer.private_ip} --event-stream-application=BackOffice --event-stream-environment=Gen1_Prod --event-stream-site=Store2 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "register_hab_sup_Store2" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store2_permanent_peer.private_ip} --event-stream-application=RegisterPOS --event-stream-environment=Gen1_Prod --event-stream-site=Store2 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "permanent_peer_hab_sup_Store3" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"


  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer --event-stream-application=PermanentPeer --event-stream-environment=Gen2_Prod --event-stream-site=Store3 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "backoffice_hab_sup_Store3" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store3_permanent_peer.private_ip} --event-stream-application=BackOffice --event-stream-environment=Gen2_Prod --event-stream-site=Store3 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "register_hab_sup_Store3" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store3_permanent_peer.private_ip} --event-stream-application=RegisterPOS --event-stream-environment=Gen2_Prod --event-stream-site=Store3 --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "register_hab_sup_QA_Gen1" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"
  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store3_permanent_peer.private_ip} --event-stream-application=RegisterPOS --event-stream-environment=Gen1_QA --event-stream-site=QA_Lab --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "register_hab_sup_QA_Gen2" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"
  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --peer ${aws_instance.Store3_permanent_peer.private_ip} --event-stream-application=RegisterPOS --event-stream-environment=Gen2_QA --event-stream-site=QA_Lab --event-stream-url=${aws_instance.chef_automate.private_ip}:4222 --event-stream-token=${var.automate_token}"
  }
}

data "template_file" "install_hab" {
  template = "${file("${path.module}/../templates/install-hab.sh")}"

  vars {
    opts = "${var.hab_install_opts}"
  }
}

data "template_file" "audit_toml_linux" {
  template = "${file("${path.module}/../templates/audit_linux.toml")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}

data "template_file" "config_toml_linux" {
  template = "${file("${path.module}/../templates/config_linux.toml")}"

  vars {
    automate_hostname = "${var.automate_hostname}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}

data "template_file" "store1_register_app_toml" {
  template = "${file("${path.module}/../templates/reg_app.toml")}"
  vars{
    store_num = 1
  }
}

data "template_file" "store2_register_app_toml" {
  template = "${file("${path.module}/../templates/reg_app.toml")}"
  vars{
    store_num = 2
  }
}

data "template_file" "store3_register_app_toml" {
  template = "${file("${path.module}/../templates/reg_app.toml")}"
  vars{
    store_num = 3
  }
}