#!/bin/bash

set -e

. ./create-ami-common.sh

# http://cloud-images.ubuntu.com/releases/precise/release/ us-east-1 64-bit ebs
create_ami ami-3d4ff254 m1.large amd64 us-east-1 us-east-1a
