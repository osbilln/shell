#!/bin/bash

getinfo()
{
  read -p "Enter the ip address for your server: (looks like 10.165.4.195)  " staticip
  read -p "Enter the netmask for your network:   (looks like 255.255.255.0) " netmask
  read -p "Enter the broadcast address for your network:   (looks like 10.165.4.255) " broadcast
  read -p "Enter the IP of your router:          (looks like 10.165.4.1)   " routerip
}

getcompanyinfo()
{
  read -p "Enter Your companyId:(looks like kvwk81nhqub5gd481400547885225)   " companyId
  read -p "Enter Company Admin Email:(looks like admin@yourdomain.com) " CompanyAdminEmail
  
}

writeinterfacefile()
{ 
cat > /data/virtualappliance/interfaces << EOF 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
# The loopback network interface
auto lo
iface lo inet loopback

#Your static network configuration  
auto eth0
iface eth0 inet static
address $staticip
netmask $netmask
gateway $routerip 
broadcast $broadcast
dns-nameservers 8.8.8.8 8.8.4.4
EOF
#don't use any space before of after 'EOF' in the previous line

}

restart ()
{
	shutdown -r 0
}


clear
echo "----------------------------------------------------------------"
Date=$(date +"%d.%m.%Y")
echo "Today is $Date"
echo "Welcome Totvs Virtual Appliance Network Configuration:"
echo "----------------------------------------------------------------"
echo ""
dhcpip=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | cut -d: -f2`
broadcast=`ifconfig eth0 | grep "inet addr" | awk '{print $3}' | cut -d: -f2`
submask=`ifconfig eth0 | grep "inet addr" | awk '{print $4}' | cut -d: -f2`
echo ""
echo "Your current DHCP IP address: $dhcpip"
echo "Your current netmask: $submask"
echo ""
echo "If you are deploying this Virtual Appliance in your datacenter, you must complete step 1,2, and 3"
echo "If you are using DHCP to deploy this Virtual Apppliance, please complete step 2 and 3"
echo ""
echo "----------------------------------------------------------------"
echo ""
sel=0
# making a loop for menu

while [ $sel -ne 3 ]
do
  echo ""
  echo "1 Change to Static IP"
  echo "2 Register your companyId and Company Admin Email"
  echo "3 restart"
  echo ""
  # reading from the console number and assigning it to variable sel
  read -p "Make selection: " sel
  # creating 5 cases for variable sel

  case "$sel" in
      "1")
        echo "Let's set up a static ip address for your site"
        echo ""
        getinfo
        echo ""
        echo "So your settings are:"
        echo "Your decided Server IP is:   $staticip"
        echo "The Mask for the Network is: $netmask"
        echo "The Broadcast for the Network is: $broadcast"
        echo "Address of your Router is:   $routerip"
        echo ""
        writeinterfacefile
        cp -rp /etc/network/interfaces /data/virtualappliance/interfaces.dhcp
        cp -r /data/virtualappliance/interfaces /etc/network/interfaces
      ;;
      "2")
        getcompanyinfo
          echo ""
          echo "So Your companyId is :    $companyId"
          echo "So Your Company Admin Email is:   $CompanyAdminEmail"
          echo ""  

          adminName=`echo $CompanyAdminEmail | cut -d\@ -f1`
          echo $adminName

          companyDomainName=`echo $CompanyAdminEmail | cut -d\@ -f2`
          echo $companyDomainName
          mkdir /data/virtualappliance/$companyId

          echo "Generating companyId JSON"
          sed -i "s@xxxxx@'$companyId'@g" /data/virtualappliance/companyId.json > /data/virtualappliance/companyId.json.1
          cp /data/virtualappliance/companyId.json.1 /data/virtualappliance/companyId.json.2

          echo "Generating adminEmail JSON"
          sed -i "s@xxxxx@'$adminName'\@'$companyDomainName'@g" /data/virtualappliance/adminEmail.json > /data/virtualappliance/adminEmail.json.1
          cp /data/virtualappliance/adminEmail.json.1  /data/virtualappliance/adminEmail.json.2
          chef-hostname.sh  "$companyId"."$companyDomainName" 
          chef-client -j /data/virtualappliance/companyId.json
          chef-client -j /data/virtualappliance/adminEmail.json                
      ;;
      "3")
        restart 
      ;;
  esac
done