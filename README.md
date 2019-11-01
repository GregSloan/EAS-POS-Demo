# Reference Architecture - Retail POS EAS Demo

The purpose of this repo is to spin up an environment that simulates a retail POS end point management scenario. It's specifically built do highlight the EAS Automate dashboard capabilities, Habitat service configuration coordination, and Habitat application lifecycle features.

>THIS REPO IS CURRENTLY UNDER DEVELOPMENT. Contact [Greg Sloan](https://github.com/gsloan-chef) if you have any questions or want to collaborate.

## What will be deployed

15 instances in total will be deployed.

* An Automate instance (populated with API token you provide)
* 2 QA Instances
* 3 "Stores" - each consisting of 4 instances.
  * 2 Registers
  * 1 Back Office
  * 1 Permanent Peer

## The Story

The deployed infrastructure is meant to represent a retail chain with multiple stores, multiple applications running in the stores, and multiple hardware profiles running in the stores. Their basic topologies are the same (2 registers and 1 back office system), however Store1 and Store2 are running on an older "Gen1" hardware set, while Store3 is running on the latest "Gen2" hardware set.

This information will be reflected in the EAS dashboard as "Environment", "Site", and "Application" parameters, allowing an admin to sort and filter through the data to focus in on the store, instance, set of instances, etc. that they need to work with.

## Requirements

- [Terraform](https://terraform.io) (>=0.11.14, <0.12)

- Cloud Account: [AWS](https://aws.amazon.com/)

- One or two standalone Habitat deployable application to run on the "register" and "backoffice" systems that are deployed. Any application will work if you just need to show the EAS Automate dashboards, or, use the ones that are referenced by default (gsloan-chef/retail-register-app and gsloan-chef/retail-backoffice-app), which are designed to work with the whole demo flow.

## Demo Prep - Deploying an environment to AWS

Clone this repo to a working directory on your development workstation.

`OPTIONAL` - for "Phase 3" of the demo
1. Fork and clone `https://github.com/gsloan-chef/retail-register-app`
1. Modify habitat/plan.sh with your origin
1. Build and upload habitat package to your orogin
1. Promote package to channel(s) per terraform.tfvars settings in the `Set terraform.tfvars value` section

### Login to AWS

Before deploying with `terraform` you must first login to AWS using okta_aws (https://github.com/chef/okta_aws)

### Stage applications in Builder

Ensure that there is a valid release of the application configured in terraform.tfvars (below) in the channels that are specified in terraform.tfvars (you will set a channel for each store, and a qa channel. These can be all the same for simplicity, or different to demonstrate channel selection)

### Set terraform.tfvars value

An A2 Instance will be spun up by this repo. You will be required to provie an "automate_token". This can be any validly-formatted A2 API token, it will be added to the new A2 system and used to as the token for all of the other resources

1. Change directories into the repo
1. Change directories into terraform/
1. Copy tfvars.example to a terraform.tfvars
1. Fill out aws account details
1. Set disable_event_tls = "true" to enable Application dashboard feature
1. Set your values for the "Automate Config" section.
1. If using your own application package, modify "POS Application Config" section
1. run terraform init
1. run terraform apply
1. note resulting automate ip, automate url, automate token, and automate admin password
1. The terraform output will contain a block of IP and host names, ready to be copied into /etc/hosts for easy access to the instances

## Demo Flow

### PHASE 0: Starting State

Once deployed, there should be 14 nodes listed under both Infrastructure and Compliance tabs in Automate. On the Applicaiton tab there will be 22 application groups displayed, some will have multiple instances grouped under them. One of the application groups will be displaying a health-check warning status.

### PHASE 1: EAS Dashboard Demo

1. Log in to Automate, show the EAS "Applications" dashboard. Explain that this retailer is operating 3 stores, with the same application operating on 2 different generations of hardware, with registers and back office systems.
1. Briefly introduce the Compliance and Infrastructure tabs, explaining that the systems are being managed with Chef Infra and Inspec delivered as Habitat packages (visible in the Applicaitons tab)
1. Return to the Applications tab and identify the application instance with the WARNING status. Click on the application group and identify it as "Store2_Register1" running on the older "Gen1" infrastructure
1. Bouns points (resolve the WARNING): 
  * `ssh -i ~/.ssh/my_aws_key centos@Store2_Register1`
  * `journalctl -fu hab-sup` - watch for health-check message: `Register App Log Too Large (/hab/logs/register.log)`
  * `sudo rm /hab/logs/register.log`
  * Return to Applications dashboard to see WARNING status clear
1. Demonstrate the various filtering and sorting options available in the Applications dashboard


### PHASE 2: Habitat Service Management

```This section assumes the default gsloan-chef/retail-register-app (or your own fork) package is being deployed```
Each store is configured in its own service ring with its own permanent peer. We can inject store-specific configuration anywhere on that ring and all of the instances on that ring will pick up the config change.

1. In a browser, load both Register instances from one of the stores (e.g. http://Store1_Register1:8080/retail-register-app/Register and http://Store1_Register1:8080/retail-register-app/Register). Note the message of the day in the header (default = "We are doing pretty well!")
1. Connect to a permanent peer instance (e.g. `ssh -i ~/.ssh/my_aws_key centos@Store1_PermanentPeer`)
1. Create a new file, motd.toml and add a different value for the motd
```motd = "Top Selling Store in the Region"```
1. `sudo hab config apply regail-register-app.default $(date +%s) motd.toml`
1. Refresh the store browsers to show the new message displayed on both.
1. Use this an on opportunity to talk about how any new register will pick up its configuration from the ring, no need to configure each box (e.g. the Store # in the header is also configurable)

### Phase 3: Habitat application lifecycle
```This section requires your own fork of this repo https://github.com/gsloan-chef/retail-register-app```

We will make a change to the HTML code that builds the retaiil app, test that change locally, and promote it through channels.

1. Clone your fork of the retail-register-app repot
1. Make the code change
* Either copy contents of `calc_discounts.html` into `habitat/config/calc.html`
* OR directly edit `habitat/config/calc.html` and add `<td bgcolor=Pink rowspan=3 align=center>Apply Discount<br><img width=40 src=images/percent.png></td> <!-- Adding "Apply discount" funcitonality-->` after line 103
1. `export HAB_DOCKER_OPTS='-p 8080:8080'
1. `hab studio enter`
1. `build`
1. Load the application locally to validate changes
* `source results/last_build.env`
* `hab svc load $pkg_ident
* Open a brower and load `http://localhost:8080/retail-register-app/Register`
* A new "Apply Discount" button should now display
1. Open QA instance in a browser, e.g. `http://QA_Gen1_Register:8080/retail-register-app/Register`
1. Open a prduciton instance in a browser, e.g. 'http://Store2_Register0:8080/retail-register/Register1
1. `hab pkg upload results/$pkg_artifact`
* If you use a channel other than `unstable` for `qa_channel` in `terraform.tfvars`, run `hab pkg promote $pkg_ident {qa_channel}`
1. Refresh QA instance in browser. In about a minute, the new version should display. Show that the produciton instance isn't affected
1. `hab pkg promote $pkg_ident Gen1_Prod` (or substitute the channel that was set in `terraform.tfvars` for the store you loaded in your browser)
1. Refresh the produciton browser to show the update.