---
title: Deploy a simple IVR using Terraform and CX as Code
author: john.carnell
indextype: blueprint
icon: blueprint
image: images/SimpleIvrFlowDeploy.png
category: 5
summary: |
  This Genesys Cloud Developer Blueprint provides a simple example of how to deploy a touch-tone based IVR using Terraform and CX as Code.  
---

This Genesys Cloud Developer Blueprint provides a simple example of how to deploy a touch-tone based IVR using Terraform and CX as Code.

This blueprint demonstrates how to:

* Create users using CX as Code
* Create queues using CX as Code
* Deploy a simple IVR flow using CX as Code
* Attach a DID phone number to the deployed IVR flow

## Scenario

An organization is interested in deploying a Genesys Cloud Architect flow and its dependent objects (queues, data actions, and so on) immutably across all of their Genesys Cloud organizations without the need for a Genesys Cloud administrator to manually set up and configure these objects in each of their Genesys Cloud environments. The Genesys Cloud administrator wants to understand how to do this using CX as Code with a very simple example.

## Solution

Developers use CX as Code to manage their Architect flow and dependent objects as plain text files. After these objects are defined they can be deployed to Genesys Cloud using Terraform.

![Deploy a simple IVR using Terraform and CX as Code](images/SimpleIvrFlowDeploy.png "Deploy a simple IVR using Terraform and CX as Code")

The following are the deployment phases of Genesys Cloud objects within this flow:

1. Creation of queues and users.
2. Deployment of inbound call flow.
3. Creation of DID pool which includes the DID to be configured in the IVR.

## Contents

* [Solution components](#solution-components "Goes to the Solution components section")
* [Prerequisites](#prerequisites "Goes to the Prerequisites section")
* [Implementation steps](#implementation-steps "Goes to the Implementation steps section")
* [Additional resources](#additional-resources "Goes to the Additional resources section")

## Solution components

* **Genesys Cloud** - A suite of Genesys Cloud services for enterprise-grade communications, collaboration, and contact center management. In this solution, you use an Architect IVR and in-bound call flows.
* **CX as Code** - A Genesys Cloud Terraform provider that provides a command line interface for declaring core Genesys Cloud objects.

## Prerequisites

### Specialized knowledge

* Administrator-level knowledge of Genesys Cloud
* Experience using Terraform

### Genesys Cloud account

* A Genesys Cloud license. For more information, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the Genesys Cloud pricing page") in the Genesys website.
* Master Admin role. For more information, see [Roles and permissions overview](https://help.mypurecloud.com/?p=24360 "Opens the Roles and permissions overview article") in the Genesys Cloud Resource Center.
* CX as Code. For more information, see [CX as Code](https://developer.genesys.cloud/api/rest/CX-as-Code/ "Opens the CX as Code page").

### Development tools running in your local environment

* Terraform (the latest binary). For more information, see [Download Terraform](https://www.terraform.io/downloads.html "Opens the Download Terraform page") in the Terraform website.

## Implementation steps

### Define the environment variables

First define the environment variables that hold the OAuth credential grant that is used by CX as Code to provision the Genesys Cloud objects.

  * `GENESYSCLOUD_OAUTHCLIENT_ID` - This is the Genesys Cloud client credential grant Id that CX as Code executes against.
  * `GENESYSCLOUD_OAUTHCLIENT_SECRET` - This is the Genesys Cloud client credential secret that CX as Code executes against.
  * `GENESYSCLOUD_REGION` - This is the Genesys Cloud region in which your organization is located.

Next, replace the phone numbers in the `genesyscloud_telephony_providers_edges_did_pool` and `genesyscloud_architect_ivr`
Terraform resources, which are located in the blueprint/main.tf file. This phone number should be a phone number you (or your organization) own and you want to associate with the IVR.

```hcl
resource "genesyscloud_telephony_providers_edges_did_pool" "mygcv_number" {
  start_phone_number = "+19205422729"              # This needs to be changed
  end_phone_number   = "+19205422729"              # This needs to be changed
  description        = "GCV Number for inbound calls"
  comments           = "Additional comments"
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVR"
  description        = "A sample IVR configuration"
  dnis               = ["+19205422729", "+19205422729"]  # This needs to be changed
  open_hours_flow_id = data.genesyscloud_flow.mysimpleflow.id
  depends_on         = [
    genesyscloud_flow.mysimpleflow,
    genesyscloud_telephony_providers_edges_did_pool.mygcv_number
  ]
}
```

### Deploy the Genesys Cloud objects

Deploy the Architect flow and Genesys Cloud objects:

`terraform apply --auto-approve`

## Test your flow

Dial the phone number you entered in the blueprint/main.tf file. If everything deployed correctly, you should hear the IVR pick up and answer with
"Hi welcome to SimpleFinancial.  Please listen to our menu carefully."

## Additional resources

* [Terraform](https://terraform.io "Opens the Terraform Cloud sign page") in the Terraform website
* [CX as Code](https://developer.genesys.cloud/api/rest/CX-as-Code/ "Opens the CX as Code page") in the Genesys Cloud Developer Center
* [Terraform Registry Documentation](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs "Opens the Genesys Cloud provider page") in the Terraform documentation
* [simple-ivr-deploy-with-cx-as-code-blueprint repository](https://github.com/GenesysCloudBlueprints/simple-ivr-deploy-with-cx-as-code-blueprint "Goes to the simple-ivr-deploy-with-cx-as-code-blueprint repository") in Github
