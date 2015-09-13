#!/bin/sh

. ./exports.sh
./setup.sh

ZONE="us-east-1d"
KEY_NAME="mykeyname"
SECURITY_GROUP="default"
INSTANCE_SIZE="t1.micro"
LB_NAME="myscaling-lb"
LC_NAME="myscaling-lc"
LC_IMAGE_ID="ami-xxxxxxxx"
SG_NAME="myscaling-sg"

# Set up load balancer
elb-create-lb $LB_NAME --headers --listener "lb-port=80,instance-port=80,protocol=http"
    --availability-zones $ZONE
elb-configure-healthcheck  $LB_NAME  --headers --target "HTTP:80/alive.php"
    --interval 6 --timeout 2 --unhealthy-threshold 2 --healthy-threshold 7

# Setup auto scaling
as-create-launch-config $LC_NAME --image-id $LC_IMAGE_ID --instance-type $INSTANCE_SIZE
    --monitoring-disabled --key $KEY_NAME --group $SECURITY_GROUP
    --user-data-file ./user-data.yml
as-create-auto-scaling-group dmcleaner-sg --availability-zones $ZONE
    --launch-configuration $LC_NAME --min-size 1 --max-size 6
    --load-balancers $LB_NAME

# Set up scaling policies
SCALE_UP_POLICY=`as-put-scaling-policy MyScaleUpPolicy1
    --auto-scaling-group $SG_NAME --adjustment=1 --type ChangeInCapacity
    --cooldown 300`

mon-put-metric-alarm MyHighCPUAlarm1 --comparison-operator GreaterThanThreshold
    --evaluation-periods 1 --metric-name CPUUtilization --namespace "AWS/EC2"
    --period 600 --statistic Average --threshold 60
    --alarm-actions $SCALE_UP_POLICY
    --dimensions "AutoScalingGroupName=$SG_NAME"

SCALE_DOWN_POLICY=`as-put-scaling-policy MyScaleDownPolicy1
    --auto-scaling-group $SG_NAME --adjustment=-1 --type ChangeInCapacity
    --cooldown 300`

mon-put-metric-alarm MyLowCPUAlarm1 --comparison-operator LessThanThreshold
    --evaluation-periods 1 --metric-name CPUUtilization --namespace "AWS/EC2"
    --period 600 --statistic Average --threshold 10
    --alarm-actions $SCALE_DOWN_POLICY
    --dimensions "AutoScalingGroupName=$SG_NAME"
