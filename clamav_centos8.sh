#!/usr/bin/bash

# This is an install script to install and 
# configure Clamav antivirus on CentOS 8.

# Modify it at your convenience.

# Instructions on how to use this script 

# chmod +x SCRIPTNAME.sh

# sudo ./SCRIPTNAME.sh

# Enable and install the EPEL repository
dnf --enablerepo=extras install epel-release

# Let's update CentOS local repositories on this box.
dnf update -y

# Install Clamav and Clamav-Update
dnf install clamav clamav-update clamd -y

# Allow Clamav to self-update through SELinux
setsebool -P antivirus_can_scan_system 1

# Configure Clamav Daemon
sed -i 's/#LocalSocket \/run/LocalSocket \/run/g' /etc/clamd.d/scan.conf

# Enable the Freshclam service
systemctl enable clamav-freshclam.service

# Start the Freshclam service
systemctl start clamav-freshclam.service

# Update Clamav Signatures using Freshclam
freshclam

# Tune the Systemd entry for Clamd
sed -i 's/scanner (%i) daemon/scanner daemon/g' /usr/lib/systemd/system/clamd@.service
sed -i 's/\/etc\/clamd.d\/%i.conf/\/etc\/clamd.d\/scan.conf/g' /usr/lib/systemd/system/clamd@.service

# Enable the Clamd service
systemctl enable clamd@service

# Start the Clamd service
systemctl start clamd@scan

## Clamav is an on-demand antivirus scanner but it has incorportated a module called
## 'on-access' making it able to scan files on real-time. 
## Comment the next configuration lines if you want it not to be enabled.

# Stop the Clamd service before making configuration changes on the '/etc/clamd.d/scan.conf' file
systemctl stop clamd@scan

# Enable OnAccessPrevention
sed -i 's/#OnAccessPrevention yes/OnAccessPrevention yes/g' /etc/clamd.d/scan.conf

# Enable the Data Path you want to be scanned. 
# This may change in your environment depending on your specific needs.
sed -i 's/#OnAccessIncludePath \/home/OnAccessIncludePath \/home/g' /etc/clamd.d/scan.conf

# Set the correct username to be excluded for the Clamav user
sed -i 's/#OnAccessExcludeUname clamav/OnAccessExcludeUname clamscan/g' /etc/clamd.d/scan.conf

# Create a configuration file for the clamonacc service so it's integrated with Systemd
touch /usr/lib/systemd/system/clamonacc.service

# Edit the clamonacc config file for Systemd
echo "
[Unit]
Description=ClamAV On Access Scanner
Requires=clamd@service
After=clamd.service syslog.target network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/clamonacc -F --log=/var/log/clamonacc --move=/tmp/clamav-quarantine
Restart=on-failure
RestartSec=7s

[Install]
WantedBy=multi-user.target
" >> /usr/lib/systemd/system/clamonacc.service

# Create the clamonacc log file
touch /var/log/clamonacc

# Create the quarantine directory
mkdir /tmp/clamav-quarantine

# Reload the systemd daemon so it reads the new configuration file for the clamonacc.service entry
systemctl daemon-reload

# Enable the clamonacc service
systemctl enable clamonacc.service

# Start the clamonacc service
systemctl start clamonacc.service

# Final install message
echo 'Clamav Clamav-Update and Clam-On-Access have been installed and enabled. Proceed with manual checks.'

# EOF

## References:
## https://www.clamav.net/documents/installing-clamav#rhel
## https://www.clamav.net/documents/installation-on-redhat-and-centos-linux-distributions
## https://www.clamav.net/documents/usage
## https://www.clamav.net/documents/on-access-scanning
