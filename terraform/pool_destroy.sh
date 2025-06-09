#!/bin/bash
virsh pool-start vms_dir
virsh pool-destroy vms_dir
virsh pool-undefine vms_dir
