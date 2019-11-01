output "chef_automate_public_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}

output "chef_automate_server_public_r53_dns" {
  value = "${var.automate_hostname}"
}

output "a2_admin" {
  value = "${data.external.a2_secrets.result["a2_admin"]}"
}

output "a2_admin_password" {
  value = "${data.external.a2_secrets.result["a2_password"]}"
}

output "a2_token_admin_token" {
  value = "${data.external.a2_secrets.result["a2_token"]}"
}

output "a2_reporting_token" {
  value = "${var.automate_token}"
}

output "a2_url" {
  value = "${data.external.a2_secrets.result["a2_url"]}"
}


output "hostsfile" {
  value = <<HOSTSFILE

${aws_instance.Store1_Register.*.public_ip[0]}  Store1_Register0  
${aws_instance.Store1_Register.*.public_ip[1]}  Store1_Register1   
${aws_instance.Store1_permanent_peer.public_ip}  Store1_PermanentPeer    
${aws_instance.Store1_Backoffice.public_ip}  Store1_BackOffice

${aws_instance.Store2_Register.*.public_ip[0]}   Store2_Register0 
${aws_instance.Store2_Register.*.public_ip[1]}  Store2_Register1 
${aws_instance.Store2_permanent_peer.public_ip}  Store2_PermanentPeer
${aws_instance.Store2_Backoffice.public_ip}  Store2_BackOffice

${aws_instance.Store3_Register.*.public_ip[0]}   Store3_Register0 
${aws_instance.Store3_Register.*.public_ip[0]}  Store3_Register1 
${aws_instance.Store3_permanent_peer.public_ip}  Store3_PermanentPeer
${aws_instance.Store3_Backoffice.public_ip}  Store3_BackOffice

${aws_instance.QA_Gen1_Register.public_ip}  QA_Gen1_Reigster 
${aws_instance.QA_Gen2_Register.public_ip}  QA_Gen2_Register 
     HOSTSFILE
     }