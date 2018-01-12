#!/bin/bash
openstack overcloud deploy --templates /home/stack/openstack-tripleo-heat-templates \
-r /home/stack/templates/roles_data.yaml \
-e /home/stack/templates/node-info.yaml \
-e /home/stack/templates/network-isolation.yaml \
-e /home/stack/templates/01-network-environment.yaml \
-e /home/stack/templates/03-storage-environment.yaml \
-e /home/stack/templates/04-timezone-environment.yaml \
-e /home/stack/templates/02-firstboot-environment.yaml \
-e /home/stack/templates/neutron-ovs-dvr.yaml \
--stack overcloud  $1 | tee ~/openstack-deployment.log

