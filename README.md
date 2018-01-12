# RHOSP10 Orange E-PoD
For the undercloud deployment refer to the below Git repository:
[https://github.com/moh-elsayed/RHOPS10-ScaleIO](https://github.com/moh-elsayed/RHOPS10-ScaleIO)

## Overcloud Deployment Features:
1. Hyper-converged Infrastructure with CEPH.
2. OVS deployment.
3. CPU Pinning
4. DVR Deployment

## Topology Diagram
![](https://i.imgur.com/JW2IJNT.png)

## Deployment 101
```
## Import the baremetal servers
$ openstack overcloud node import ~/instackenv.json

## In some cases you will need to set the nodes into managed state
$ for node in $(openstack baremetal node list -c UUID -f value) ; do openstack baremetal node manage $node ; done

[stack@undercloud swift-data]$ openstack baremetal node list
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| UUID                                 | Name    | Instance UUID | Power State | Provisioning State | Maintenance |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| 94b7b2f6-7e24-4d2f-908e-cdf6e1483a41 | cont00  | None          | power off   | manageable         | False       |
| f2ca16f0-026f-495a-b387-25288aaa86cf | cont01  | None          | power off   | manageable         | False       |
| c80f6c5b-4087-4c7b-aaaa-549dd195514a | cont02  | None          | power off   | manageable         | False       |
| 45ef251a-af6f-424f-9814-e42c08ecd841 | Hcomp00 | None          | power off   | manageable         | False       |
| c09ed885-6611-4c54-8782-d2e7d0dbd8e9 | Hcomp01 | None          | power off   | manageable         | False       |
| 7f5766b2-0926-4c19-8524-1b93dfaea676 | Hcomp02 | None          | power off   | manageable         | False       |
| 0f1e01e1-cbe2-4ca8-a0c5-e598f3739fe7 | Hcomp03 | None          | power off   | manageable         | False       |
| 5997a631-c935-4939-8e72-cfdc0b1ee065 | Hcomp04 | None          | power off   | manageable         | False       |
| 1e423fd0-973f-49bb-a404-e75f06f9f47c | Hcomp05 | None          | power off   | manageable         | False       |
| 1863b382-c093-4c25-9e74-a4b8507a0787 | Hcomp06 | None          | power off   | manageable         | False       |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
## Introspection 
[stack@undercloud swift-data]$ openstack overcloud node introspect --all-manageable --provide
Started Mistral Workflow. Execution ID: 073e4703-dfa1-435f-910e-d7d2561fb934
Waiting for introspection to finish...
Introspection for UUID 7f5766b2-0926-4c19-8524-1b93dfaea676 finished successfully.
Introspection for UUID 1863b382-c093-4c25-9e74-a4b8507a0787 finished successfully.
Introspection for UUID f2ca16f0-026f-495a-b387-25288aaa86cf finished successfully.
Introspection for UUID 45ef251a-af6f-424f-9814-e42c08ecd841 finished successfully.
Introspection for UUID 0f1e01e1-cbe2-4ca8-a0c5-e598f3739fe7 finished successfully.
Introspection for UUID 94b7b2f6-7e24-4d2f-908e-cdf6e1483a41 finished successfully.
Introspection for UUID c09ed885-6611-4c54-8782-d2e7d0dbd8e9 finished successfully.
Introspection for UUID 1e423fd0-973f-49bb-a404-e75f06f9f47c finished successfully.
Introspection for UUID c80f6c5b-4087-4c7b-aaaa-549dd195514a finished successfully.
Introspection for UUID 5997a631-c935-4939-8e72-cfdc0b1ee065 finished successfully.
Introspection completed.
Started Mistral Workflow. Execution ID: 1c36dc56-c035-447a-91cc-9bea00ead242

[stack@undercloud swift-data]$ openstack baremetal node list
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| UUID                                 | Name    | Instance UUID | Power State | Provisioning State | Maintenance |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| 94b7b2f6-7e24-4d2f-908e-cdf6e1483a41 | cont00  | None          | power off   | available          | False       |
| f2ca16f0-026f-495a-b387-25288aaa86cf | cont01  | None          | power off   | available          | False       |
| c80f6c5b-4087-4c7b-aaaa-549dd195514a | cont02  | None          | power off   | available          | False       |
| 45ef251a-af6f-424f-9814-e42c08ecd841 | Hcomp00 | None          | power off   | available          | False       |
| c09ed885-6611-4c54-8782-d2e7d0dbd8e9 | Hcomp01 | None          | power off   | available          | False       |
| 7f5766b2-0926-4c19-8524-1b93dfaea676 | Hcomp02 | None          | power off   | available          | False       |
| 0f1e01e1-cbe2-4ca8-a0c5-e598f3739fe7 | Hcomp03 | None          | power off   | available          | False       |
| 5997a631-c935-4939-8e72-cfdc0b1ee065 | Hcomp04 | None          | power off   | available          | False       |
| 1e423fd0-973f-49bb-a404-e75f06f9f47c | Hcomp05 | None          | power off   | available          | False       |
| 1863b382-c093-4c25-9e74-a4b8507a0787 | Hcomp06 | None          | power off   | available          | False       |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
```
## Introspection data analysis
```
$ cd swift-data

[stack@undercloud swift-data]$ export SWIFT_PASSWORD=`sudo crudini --get /etc/ironic-inspector/inspector.conf swift password`
[stack@undercloud swift-data]$ for node in $(ironic node-list | grep -v UUID| awk '{print $2}'); do swift -U service:ironic -K $SWIFT_PASSWORD download ironic-inspector inspector_data-$node; done
[stack@undercloud swift-data]$ openstack baremetal node list  -f value -c UUID -c Name | tee /tmp/1
[stack@undercloud swift-data]$ while read i n; do mv inspector_data-$i inspector_data-$n; done < /tmp/1

## Disk
[stack@undercloud swift-data]$ for name in `openstack baremetal node list  -f value -c Name`; do echo "NODE: $name"; echo ============================; cat inspector_data-$name | jq '.inventory.disks' | tee ${name}.disk; echo "---------------------------"; done >all_disk.out

## Interfaces
[stack@undercloud swift-data]$ for name in `openstack baremetal node list  -f value -c Name`; do echo "NODE: $name"; echo ============================; cat inspector_data-$name | jq '.inventory.interfaces' | tee ${name}.int; echo "---------------------------"; done >all_interfaces.out

##CPU
[stack@undercloud swift-data]$ for name in `openstack baremetal node list  -f value -c Name`; do echo "NODE: $name"; echo ============================; cat inspector_data-$name | jq '.inventory.cpu' | tee ${name}.cpu; echo "---------------------------"; done >all_cpu.out

##mem
[stack@undercloud swift-data]$ 



[stack@undercloud swift-data]$ ls  -ltr
total 796
-rw-rw-r--. 1 stack stack 28585 Jan  3 11:10 inspector_data-cont00
-rw-rw-r--. 1 stack stack 28583 Jan  3 11:10 inspector_data-cont01
-rw-rw-r--. 1 stack stack 28583 Jan  3 11:10 inspector_data-cont02
-rw-rw-r--. 1 stack stack 47133 Jan  3 11:10 inspector_data-Hcomp00
-rw-rw-r--. 1 stack stack 47137 Jan  3 11:10 inspector_data-Hcomp01
-rw-rw-r--. 1 stack stack 47137 Jan  3 11:10 inspector_data-Hcomp02
-rw-rw-r--. 1 stack stack 47136 Jan  3 11:10 inspector_data-Hcomp03
-rw-rw-r--. 1 stack stack 51799 Jan  3 11:10 inspector_data-Hcomp04
-rw-rw-r--. 1 stack stack 47136 Jan  3 11:10 inspector_data-Hcomp05
-rw-rw-r--. 1 stack stack 46541 Jan  3 11:10 inspector_data-Hcomp06
-rw-rw-r--. 1 stack stack  1237 Jan  3 11:11 cont00.disk
-rw-rw-r--. 1 stack stack  1237 Jan  3 11:11 cont01.disk
-rw-rw-r--. 1 stack stack  1237 Jan  3 11:11 cont02.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp00.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp01.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp02.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp03.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp04.disk
-rw-rw-r--. 1 stack stack  7915 Jan  3 11:11 Hcomp05.disk
-rw-rw-r--. 1 stack stack  7582 Jan  3 11:11 Hcomp06.disk
-rw-rw-r--. 1 stack stack 59490 Jan  3 11:11 all_disk.out
-rw-rw-r--. 1 stack stack  6201 Jan  3 11:11 cont00.int
-rw-rw-r--. 1 stack stack  6201 Jan  3 11:11 cont01.int
-rw-rw-r--. 1 stack stack  6201 Jan  3 11:11 cont02.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp00.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp01.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp02.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp03.int
-rw-rw-r--. 1 stack stack  6895 Jan  3 11:11 Hcomp04.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp05.int
-rw-rw-r--. 1 stack stack  6387 Jan  3 11:11 Hcomp06.int
-rw-rw-r--. 1 stack stack 64527 Jan  3 11:11 all_interfaces.out
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 cont00.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 cont01.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 cont02.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp00.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp01.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp02.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp03.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp04.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp05.cpu
-rw-rw-r--. 1 stack stack  1567 Jan  3 11:11 Hcomp06.cpu
-rw-rw-r--. 1 stack stack 16377 Jan  3 11:11 all_cpu.out
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 cont00.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 cont01.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 cont02.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp00.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp01.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp02.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp03.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp04.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp05.mem
-rw-rw-r--. 1 stack stack    53 Jan  3 11:21 Hcomp06.mem
-rw-rw-r--. 1 stack stack  1237 Jan  3 11:21 all_mem.out

```

### Disk
```
[stack@undercloud swift-data]$ more  Hcomp0*.disk |  grep -A4  1099511627776
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21df4e05133cf99a",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de2e66e974d46c",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de2d29f60a4417",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x2162bfa4028cc0f7",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de2fd307242b2e",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de31c70f8c15fd",
--
    "size": 1099511627776,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de2f9219a69e4d",

[stack@undercloud swift-data]$ more  cont0*.disk |  grep -A4  289910292480
    "size": 289910292480,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de20bb44b7d57e",
--
    "size": 289910292480,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de28cbbbe0729a",
--
    "size": 289910292480,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sda",
    "wwn_vendor_extension": "0x21de2736bb7edb2e",
```
/dev/sda will be our boot disk 

```
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' cont00
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' cont01
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' cont02
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp00
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp01
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp02
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp03
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp04
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp05
[stack@undercloud swift-data]$ openstack baremetal node set --property root_device='{"name":"/dev/sda"}' Hcomp06
```

Check the SSD allocation:
```
[stack@undercloud swift-data]$ cat Hcomp0*.disk  |  grep 799535005696 -A3
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdw",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdu",
--
    "size": 799535005696,
    "rotational": true,
    "vendor": "DELL",
    "name": "/dev/sdv",

```
Note: that the last server has two SSD with name different than the rest of the 7 compute nodes /dev/sdu and /dev/sdv
> We will Only dedicate three nodes Hcomp00 and Hcomp01 and Hcomp02 to work with hyper-converged mode 
> the rest of the node will be a normal compute and we will rename them to be comp03, comp04, comp05 and comp06

```
[stack@undercloud swift-data]$ openstack baremetal node list
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| UUID                                 | Name    | Instance UUID | Power State | Provisioning State | Maintenance |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+
| 94b7b2f6-7e24-4d2f-908e-cdf6e1483a41 | cont00  | None          | power off   | available          | False       |
| f2ca16f0-026f-495a-b387-25288aaa86cf | cont01  | None          | power off   | available          | False       |
| c80f6c5b-4087-4c7b-aaaa-549dd195514a | cont02  | None          | power off   | available          | False       |
| 45ef251a-af6f-424f-9814-e42c08ecd841 | Hcomp00 | None          | power off   | available          | False       |
| c09ed885-6611-4c54-8782-d2e7d0dbd8e9 | Hcomp01 | None          | power off   | available          | False       |
| 7f5766b2-0926-4c19-8524-1b93dfaea676 | Hcomp02 | None          | power off   | available          | False       |
| 0f1e01e1-cbe2-4ca8-a0c5-e598f3739fe7 | comp03  | None          | power off   | available          | False       |
| 5997a631-c935-4939-8e72-cfdc0b1ee065 | comp04  | None          | power off   | available          | False       |
| 1e423fd0-973f-49bb-a404-e75f06f9f47c | comp05  | None          | power off   | available          | False       |
| 1863b382-c093-4c25-9e74-a4b8507a0787 | comp06  | None          | power off   | available          | False       |
+--------------------------------------+---------+---------------+-------------+--------------------+-------------+

```

### Interfaces 
```
[stack@undercloud swift-data]$ for i in 0 1 2 3 4 5 6
> do
> echo Compute0$i
> echo ============
> more Hcomp0${i}.int | grep name -A2
> done
Compute00
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute01
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute02
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute03
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute04
============
    "name": "enp4s0f1",
    "has_carrier": false,
    "switch_port_descr": null,
--
    "name": "enp4s0f0",
    "has_carrier": false,
    "switch_port_descr": null,
--
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute05
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
Compute06
============
    "name": "eno4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno3",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "eno2",
    "has_carrier": true,
    "switch_port_descr": null,
[stack@undercloud swift-data]$

```
Controllers:
```
[stack@undercloud swift-data]$ for i in 0 1 2 ; do echo Controller0$i; echo ============; more cont0${i}.int | grep name -A2; done
Controller00
============
    "name": "em4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em2",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em3",
    "has_carrier": true,
    "switch_port_descr": null,
Controller01
============
    "name": "em4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em2",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em3",
    "has_carrier": true,
    "switch_port_descr": null,
Controller02
============
    "name": "em4",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em2",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em1",
    "has_carrier": true,
    "switch_port_descr": null,
--
    "name": "em3",
    "has_carrier": true,
    "switch_port_descr": null,
```
### CPU
![](https://i.imgur.com/1Jrx4oc.png)
```
[stack@undercloud swift-data]$ more all_cpu.out  |  grep count
  "count": 32
  "count": 32
  "count": 32
  "count": 56
  "count": 56
  "count": 56
  "count": 56
  "count": 56
  "count": 56
  "count": 56
```
### Memory
```
[stack@undercloud swift-data]$ more  all_mem.out |  grep  physical_mb
  "physical_mb": 131072
  "physical_mb": 131072
  "physical_mb": 131072
  "physical_mb": 524288
  "physical_mb": 524288
  "physical_mb": 524288
  "physical_mb": 524288
  "physical_mb": 524288
  "physical_mb": 524288
  "physical_mb": 524288
```
## Pre-deploy activity

### flavors:
```
[stack@undercloud swift-data]$ openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 --swap 4096 ceph-compute
+----------------------------+--------------------------------------+
| Field                      | Value                                |
+----------------------------+--------------------------------------+
| OS-FLV-DISABLED:disabled   | False                                |
| OS-FLV-EXT-DATA:ephemeral  | 0                                    |
| disk                       | 40                                   |
| id                         | 5cd53049-2445-475e-8134-c4beb709e4e6 |
| name                       | ceph-compute                         |
| os-flavor-access:is_public | True                                 |
| properties                 |                                      |
| ram                        | 4096                                 |
| rxtx_factor                | 1.0                                  |
| swap                       | 4096                                 |
| vcpus                      | 1                                    |
+----------------------------+--------------------------------------+
[stack@undercloud swift-data]$ openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="ceph-compute" ceph-compute

[stack@undercloud swift-data]$ openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="compute" compute

[stack@undercloud swift-data]$ openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="control" control
```
Show all baremetal node tagging 

```
[stack@undercloud swift-data]$ for i in cont00 cont01 cont02 Hcomp00 Hcomp01 Hcomp02 comp03 comp04 comp05 comp06; do echo $i; echo ===================; openstack baremetal node show $i  | grep profile; done

cont00
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'32', u'capabilities': u'profile:control,cpu_vt:true,cpu_hugepages:true,boot_option:local,cpu_txt:true,cpu_aes:true,cpu_hugepages_1g:true', u'memory_mb': u'131072', u'local_gb': u'269'} |
cont01
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'32', u'capabilities': u'profile:control,cpu_hugepages:true,cpu_txt:true,boot_option:local,cpu_aes:true,cpu_vt:true,cpu_hugepages_1g:true', u'memory_mb': u'131072', u'local_gb': u'13'} |
cont02
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'32', u'capabilities': u'profile:control,cpu_hugepages:true,cpu_txt:true,boot_option:local,cpu_aes:true,cpu_vt:true,cpu_hugepages_1g:true', u'memory_mb': u'131072', u'local_gb': u'13'} |
Hcomp00
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:ceph-compute,cpu_hugepages:true,cpu_txt:true,boot_option:local,cpu_aes:true,cpu_vt:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'58'} |
Hcomp01
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:ceph-compute,cpu_hugepages:true,cpu_txt:true,boot_option:local,cpu_aes:true,cpu_vt:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'58'} |
Hcomp02
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:ceph-compute,cpu_hugepages:true,cpu_txt:true,boot_option:local,cpu_aes:true,cpu_vt:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'58'} |
comp03
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:compute,cpu_vt:true,cpu_hugepages:true,boot_option:local,cpu_txt:true,cpu_aes:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'1023'} |
comp04
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:compute,cpu_vt:true,cpu_hugepages:true,boot_option:local,cpu_txt:true,cpu_aes:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'1023'} |
comp05
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:compute,cpu_vt:true,cpu_hugepages:true,boot_option:local,cpu_txt:true,cpu_aes:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'1023'} |
comp06
===================
| properties             | {u'cpu_arch': u'x86_64', u'root_device': {u'name': u'/dev/sda'}, u'cpus': u'56', u'capabilities': u'profile:compute,cpu_vt:true,cpu_hugepages:true,boot_option:local,cpu_txt:true,cpu_aes:true,cpu_hugepages_1g:true', u'memory_mb': u'524288', u'local_gb': u'1023'} |

```
first three nodes tagged as profile:control
second three nodes tagged as profile:ceph-compute
final four nodes are tagged as profile:compute