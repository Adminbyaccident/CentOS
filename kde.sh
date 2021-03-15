#!/usr/bin/sh

# Instructions on how to use this script
# chmod +x SCRIPTNAME.sh
# sudo ./SCRIPTNAME.sh

# SCRIPT: KDE_on_CentOS_8_Stream_2021
# AUTHOR: ALBERT VALBUENA
# DATE: 15-03-2021
# REV: 0.1.A 
# (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: (CentOS 8 - Stream)
#
# PURPOSE: Install KDE desktop on CentOS 8 Stream
#
# REV LIST:
# DATE: DATE_of_REVISION
# BY: AUTHOR_of_MODIFICATION
# MODIFICATION: Describe what was modified, new features, etc--
#

# Update the system prior to anything else
dnf update -y

# Install EPEL repository
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# Update the system resources and pull information from EPEL
dnf update -y

# Enable the PowerTools
dnf config-manager --set-enabled powertools

# Install the KDE Plasma Desktop
dnf --enablerepo=epel,powertools group -y install "KDE Plasma Workspaces" "base-x"

# Enable the graphical login and preferred method at system start update
systemctl set-default graphical.target

# Enable SDDM as the login manager
systemctl enable sddm -f

# Tell the system where the KDE binary is
echo "exec /usr/bin/startkde" >> /home/albert/.xinitrc

# Finishing message
echo "The KDE Plasma desktop has been installed"

## EOF
