#!/bin/bash
openstack overcloud deploy --templates \
-r ./roles_data.yaml \
-e ./node-info.yaml \
-e ./network-isolation.yaml \
-e ./neutron-ovs-dvr.yaml \
-e /home/stack/OVS-HCI/templates/01-network-environment.yaml \
-e /home/stack/OVS-HCI/templates/03-storage-environment.yaml \
-e /home/stack/OVS-HCI/templates/04-timezone-environment.yaml \
-e /home/stack/OVS-HCI/templates/02-firstboot-environment.yaml \
--stack overcloud  $1 | tee ~/openstack-deployment.log
