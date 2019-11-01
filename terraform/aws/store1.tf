resource "aws_instance" "Store1_permanent_peer" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habmgmt-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  count                       = "1"
  availability_zone           = "${var.aws_region}a"

  tags {
    Name          = "Store1_permanent_peer_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.permanent_peer_hab_sup_Store1.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "file" {
    content   = "${data.template_file.store1_register_app_toml.rendered}"
    destination = "/home/${var.aws_ami_user}/register_app.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname store1-permanentpeer-${random_id.instance_id.hex}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version} -u ${var.bldr_url}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/${var.config_package}/config /hab/user/${var.audit_package}/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/${var.audit_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.config_package}/config/user.toml",
      "sudo hab svc load -u ${var.bldr_url} ${var.audit_origin}/${var.audit_package} --group ${var.group} --strategy at-once --channel ${var.audit_channel}",
      "sudo hab svc load -u ${var.bldr_url} ${var.config_origin}/${var.config_package} --group ${var.group} --strategy at-once --channel ${var.config_channel}",
      "sudo hab config apply ${var.reg_app_package}.default $(date +%s) /home/${var.aws_ami_user}/register_app.toml",  
      "sudo hab config apply ${var.backoffice_app_package}.default $(date +%s) /home/${var.aws_ami_user}/register_app.toml"
    ]
  }
}

# Register instances
resource "aws_instance" "Store1_Register" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habmgmt-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  count                       = "2"
  availability_zone           = "${var.aws_region}a"

  tags {
    Name          = "Store1_Register${count.index}_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.register_hab_sup_Store1.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname store1-register${count.index}-${random_id.instance_id.hex}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version} -u ${var.bldr_url}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/${var.config_package}/config /hab/user/${var.audit_package}/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/${var.audit_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.config_package}/config/user.toml",
      "sudo hab svc load -u ${var.bldr_url} ${var.audit_origin}/${var.audit_package} --group ${var.group} --strategy at-once --channel ${var.audit_channel}",
      "sudo hab svc load -u ${var.bldr_url} ${var.config_origin}/${var.config_package} --group ${var.group} --strategy at-once --channel ${var.config_channel}", 
      "sudo hab svc load -u ${var.bldr_url} ${var.reg_app_origin}/${var.reg_app_package} --group ${var.group} --strategy at-once --channel ${var.store1_channel}"
      

    ]
  }
}

resource "aws_instance" "Store1_Backoffice" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habmgmt-subnet-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.chef_automate.id}"]
  associate_public_ip_address = true
  count                       = "1"
  availability_zone           = "${var.aws_region}a"

  tags {
    Name          = "Store1_Backoffice_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.backoffice_hab_sup_Store1.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname store1-backoffice-${random_id.instance_id.hex}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version} -u ${var.bldr_url}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/${var.config_package}/config /hab/user/${var.audit_package}/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/${var.audit_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.config_package}/config/user.toml",
      "sudo hab svc load -u ${var.bldr_url} ${var.audit_origin}/${var.audit_package} --group ${var.group} --strategy at-once --channel ${var.audit_channel}",
      "sudo hab svc load -u ${var.bldr_url} ${var.config_origin}/${var.config_package} --group ${var.group} --strategy at-once --channel ${var.config_channel}", 
      "sudo hab svc load -u ${var.bldr_url} ${var.backoffice_app_origin}/${var.backoffice_app_package} --group ${var.group} --strategy at-once --channel ${var.store1_channel}"
      

    ]
  }
}