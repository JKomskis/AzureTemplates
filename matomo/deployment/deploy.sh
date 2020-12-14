#!/bin/bash

# read config file
source common/read_conf.sh
read_conf "matomo/deployment/matomo.conf"

set -v

az account set \
    --subscription ${config[subscription]}

# Create resouce group
az group create \
    --name matomo-rg \
    --location eastus2

# Create virtual network
az network vnet create \
    --name matomo-vnet \
    --subnet-name subnet \
    --resource-group matomo-rg

# Create public IP address
az network public-ip create \
    --name matomo-ip \
    --resource-group matomo-rg

# Create network security group
az network nsg create \
    --name matomo-nsg \
    --resource-group matomo-rg

# Allow HTTP on the NSG
az network nsg rule create \
    --nsg-name matomo-nsg \
    --name http-allow \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 80 \
    --access allow \
    --resource-group matomo-rg

# Allow HTTPS on the NSG
az network nsg rule create \
    --nsg-name matomo-nsg \
    --name https-allow \
    --protocol tcp \
    --priority 1002 \
    --destination-port-range 443 \
    --access allow \
    --resource-group matomo-rg

# Allow SSH on the NSG
az network nsg rule create \
    --nsg-name matomo-nsg \
    --name ssh-allow \
    --protocol tcp \
    --priority 1003 \
    --destination-port-range 22 \
    --access allow \
    --resource-group matomo-rg

# Create network interface card
az network nic create \
    --name matomo-nic \
    --vnet-name matomo-vnet \
    --subnet subnet \
    --public-ip-address matomo-ip \
    --network-security-group matomo-nsg \
    --resource-group matomo-rg

# Create data disk
az disk create \
    --name matomo-data-disk \
    --size-gb 64 \
    --sku StandardSSD_LRS \
    --location eastus2 \
    --resource-group matomo-rg

# Create key vault
# az keyvault create \
az keyvault recover \
    --name jkomskis-matomo-kv \
    --resource-group matomo-rg

# Set secrets
az keyvault secret set \
    --vault-name jkomskis-matomo-kv \
    --name mysql-root-password \
    --value ${config[mysql_root_password]}
az keyvault secret set \
    --vault-name jkomskis-matomo-kv \
    --name mysql-database \
    --value ${config[mysql_database]}
az keyvault secret set \
    --vault-name jkomskis-matomo-kv \
    --name mysql-user \
    --value ${config[mysql_user]}
az keyvault secret set \
    --vault-name jkomskis-matomo-kv \
    --name mysql-password \
    --value ${config[mysql_password]}

# Create vm
az vm create \
    --name matomo-vm \
    --nics matomo-nic \
    --size Standard_B2s \
    --location eastus2 \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --attach-data-disks matomo-data-disk \
    --data-disk-caching ReadWrite \
    --admin-username azureuser \
    --ssh-key-values ${config[ssh_public_keys]} \
    --resource-group matomo-rg \
    --custom-data "matomo/deployment/cloud-init.yml" \

# Create identity
identity_output=$(az vm identity assign \
    --name matomo-vm \
    --resource-group matomo-rg)
system_assigned_identity=$(echo $identity_output | jq --raw-output '.systemAssignedIdentity')
az role assignment create --assignee $system_assigned_identity \
    --role "Reader" \
    --resource-group matomo-rg

echo $system_assigned_identity

# Assign permissions to identity
az keyvault set-policy \
    --name jkomskis-matomo-kv \
    --object-id $system_assigned_identity \
    --secret-permissions get list
