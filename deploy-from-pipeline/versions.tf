terraform {
  required_version = ">= 1.13"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }

  # State lives in PostgreSQL on the platform; the pipeline sets PG_CONN_STR
  backend "pg" {}
}

# Reads the application credential from the OS_ environment variables
provider "openstack" {}
