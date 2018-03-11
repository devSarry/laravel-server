#!/usr/bin/env bash

# MySQL
if [[ "$1" && "$2" && "$3"  ]]
	then
		mysql_root_username=$1
		mysql_username=$2
		mysql_password=$3

		export DEBIAN_FRONTEND=noninteractive
		# Check If Maria Has Been Installed

		if [ -f /home/vagrant/.maria ]
		then
		    echo "MariaDB already installed."
		    exit 0
		fi

		touch /home/vagrant/.maria

		# Disable Apparmor
		# See https://github.com/laravel/homestead/issues/629#issue-247524528

		sudo service apparmor stop
		sudo service apparmor teardown
		sudo update-rc.d -f apparmor remove

		# Remove MySQL

		apt-get remove -y --purge mysql-server mysql-client mysql-common
		apt-get autoremove -y
		apt-get autoclean

		rm -rf /var/lib/mysql
		rm -rf /var/log/mysql
		rm -rf /etc/mysql

		# Add Maria PPA

		sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
		sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.osuosl.org/pub/mariadb/repo/10.2/ubuntu xenial main'
		apt-get update

		# Set The Automated Root Password

		export DEBIAN_FRONTEND=noninteractive

		debconf-set-selections <<< "mariadb-server-10.2 mysql-server/data-dir select ''"
		debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password password $mysql_password"
		debconf-set-selections <<< "mariadb-server-10.2 mysql-server/root_password_again password $mysql_password"

		# Install MariaDB

		apt-get install -y mariadb-server

		# Configure Maria Remote Access

		sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/my.cnf

		mysql --user="$mysql_root_username" --password="$mysql_password" -e "GRANT ALL ON *.* TO $mysql_root_username@'0.0.0.0' IDENTIFIED BY '$mysql_password';"
		mysql --user="$mysql_root_username" --password="$mysql_password" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$mysql_password';"
		service mysql restart

		mysql --user="$mysql_root_username" --password="$mysql_password" -e "CREATE USER '$mysql_username'@'0.0.0.0' IDENTIFIED BY '$mysql_password';"
		mysql --user="$mysql_root_username" --password="$mysql_password" -e "GRANT ALL ON *.* TO '$mysql_username'@'0.0.0.0' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;"
		mysql --user="$mysql_root_username" --password="$mysql_password" -e "GRANT ALL ON *.* TO '$mysql_username'@'%' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;"
		mysql --user="$mysql_root_username" --password="$mysql_password" -e "FLUSH PRIVILEGES;"
		service mysql restart
	else
	    echo "Error: missing one ore more of  the three required parameters."
	    echo "Usage: bash install-maria.sh mysql_root_username mysql_username mysql_password"
	fi