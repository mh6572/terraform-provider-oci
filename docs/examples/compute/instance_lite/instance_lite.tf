/*
 * This example demonstrates how to spin up an Oracle Linux instance and get its public ip.
 */

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "subnet" {}


provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.tenancy_ocid}"
}


/* Instances */

# Gets the OCID of the image. This technique is for example purposes only. The results of oci_core_images may
# change over time for Oracle-provided images, so the only sure way to get the correct OCID is to supply it directly.
data "oci_core_images" "image-list" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Oracle-Linux-7.4-2017.10.25-0"
}

resource "oci_core_instance" "instance1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "be-instance1"
  image = "${lookup(data.oci_core_images.image-list.images[0], "id")}"
  shape = "VM.Standard1.1"
  metadata = {}

  create_vnic_details {
    subnet_id = "${var.subnet}"
    display_name = "vnic1"
    assign_public_ip = true
    hostname_label = "be-instance1"
  },
}


output "InstancePublicIP" {
  value = ["${oci_core_instance.instance1.public_ip}"]
}
