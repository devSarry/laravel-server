#!/bin/bash

if [[ "$1" && "$2" && "$3"]]
then
	REPO=$1
	WEBSITE=$2
	USER=$3

	# Make a git directory for user
	if [ ! -d ~$USER/git ]
	then
		mkdir -p ~$USER/git
	fi

	# Make git repo
	if [ ! -d ~$USER/git/${REPO}.git ]
	then
		mkdir -p ~$USER/git/${REPO}.git
		cd ~$USER/git/${REPO}.git
		git init --bare
	else
		echo "Error: Repo already exists"
		exit 0
	fi


	# Adding post recieve hook
	cat > ~$USER/git/${REPO}.git/hooks/post-receive <<-EOF
	echo "********************"
	echo "Post receive hook: Updating website"
	echo "********************"

	#set the git repo dir

	GIT_REPO_DIR=~/git/${REPO}.git
	echo "The git repo dir is \$GIT_REPO_DIR"



	WEBROOT=~/sites/${WEBSITE}
	GIT_WORK_TREE=\$WEBROOT git checkout -f
	#change directory to the project dir
	cd \$WEBROOT

	rm -f storage/cache/*
	echo 'cache cleared'
	rm -f storage/views/*
	echo 'views cleared'

	composer install

	php artisan migrate --no-interaction

	#Basset
	#php artisan basset:build

	#Bower
	# only run if bower.json has changed

	echo "** NPM **"

	# switch to webroot
	cd \$GIT_REPO_DIR

	# geting a 'fatal: ambiguous argument' from this ?
	#changedfiles=( \`git diff-tree --no-commit-id --name-only HEAD@{1} HEAD\` )

	changedfiles=( \`git diff-tree --no-commit-id --name-only HEAD^ HEAD\` )

	#switch back
	cd \$WEBROOT

	# check if packages has been updated, if so install
	if [[ "\${changedfiles[*]}" =~ "package.json" ]]; then
	    echo "npm packages have been updated -  installing"
	    npm install
	    echo "compiling assets for production"
	    npm run production
	fi


	# check if composer has been updated, if so install
	# Check if the composer.lock file is present
	if [[ "\${changedfiles[*]}" =~ "composer.lock" ]]; then
	        # Install or update packages specified in the lock file
	        echo "composer.lock has been updated - do install"
	        composer install --no-dev
	fi


	php artisan cache:clear

	EOF
	sudo chmod +x ~$USER/git/${REPO}.git/hooks/post-receive
	chmod capybara ~$USER/git -R
else
    echo "Error: missing required parameters."
    echo "Usage: repo_name site_address user_that_owns_repo"
fi