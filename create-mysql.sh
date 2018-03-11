#!/usr/bin/env bash	

if [[ "$1" ]]
	then
	    cat > /root/.my.cnf << EOF
	    [client]
	    user = capybara
	    password = JDcGDX86SG^MXuQ
	    host = localhost
	    EOF

	    cp /root/.my.cnf /home/capybara/.my.cnf

	    DB=$1;

	    mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
	else
	    echo "Error: missing required parameter."
	    echo "Usage: "
	    echo "  database name"
	fi
