# Server setup scripts

These are the scripts used to provision the server for the Capybara IOT project. The project is a php Laravel project and as the server is based around the [Homestead](https://github.com/laravel/homestead) virtual box that the community has created. 

# Overview
These scripts will do several things for you. 

### Provision the Server
They will install all required dependencies and configure the server for production. For example php, node, MariaDB, git,... will be installed, and things like firewall and password logins will be set.

### Create a MariaDB/MySQL Table
`create-mysql.sh $name_of_database`

### Install MongoDB
`install-mongo.sh $mongo_user $mongo_password`

### Create nginx Servers
`serve-laravel.sh $server_name root $http_port(default 80) $https_port(default 443) $php_version`

### Create git repo for auto deployment
`create-git-repo.sh $repo_name $site_address $user_that_owns_repo`

# Requirments

* Ubuntu 16.04
* root access


# Usage

## Provision

These scripts were intended to be run as the root user. 

1. Sudo into root

```
sudo su
```

2. Change directory to `/root`

```
cd /root
```

3. Clone the repository into `/root`


```bash
git clone https://jsarry@bitbucket.org/turkubeerdev/laravel-serve.git server
```

> Note: the scripts must be cloned into the folder `/root/server/` the provision script looks for scripts in `/root/server/`. See excerpt below.

```
457: # Setup MariaDB Repositories
458: 
459: bash /root/server/install-maria.sh $mysql_root_username $mysql_username $mysql_password
460: 
461: 
```

Once you have cloned the scripts into `/root/server/` open and configure the required variables.

There are two section you MUST modify. First in the beginning 

### Variables
```
# Decleration of Variables
# Host
host_name="hostname"
# user
sudo_user="root-user"
sudo_password="supersecret" #will be encrypted using mkpasswd

# git config
git_name="user user"
git_email="user@user.com"

# MySQL
mysql_username="root"
mysql_password="supersecret"
mysql_database="datatable"

# Mongo
mongo_user="user"
mongo_password="supersecret"
```

configure these to your taste.

### SSH Keys
Add your ssh keys. If you don't you will have no way of accessing your server.

```
103: # Build Formatted Keys & Copy Keys 
104: 
105: #Remove this line once you have pasted in your public keys!!
106: exit 0
107: cat > /root/.ssh/authorized_keys << EOF
108: # ssh-public authorize keys
109:  {{ !!! ADD YOUR SSH KEYS HERE !!!}}
110: EOF
```

> Note: As a bit of protection. If you don't modify this section of the `provision.sh` script the script will not run. Remove `exit 0` line once you've added your ssh keys.

Once you've set up everything run the provision script

```bash
bash provision.sh
```

This can take a while.

## Setting up server
To create a server block you need to run the `serve-laravel.sh` script.

The script takes several perameters
1. server_name - required (example.com)
2. http_port - required (80)
3. https_port - required (443)
4. php_version - required (5.6, 7.0, 7.1, 7.2)

```
bash serve-laravel.sh $server_name root $http_port(default 80) $https_port(default 443) $php_version
```

You should then create a self-signed ssl certificate by running and passing the server_name you just used above as the parameter.

```
bash create-certificate server_name
```

## Automated Deployment
Finally this is optional but you can create a git repo to help with automated deployments.

The script takes several parameters
1. REPO - required (project_name)
2. WEBSITE - required (example.com)
3. USER - required (user)

> Note: The user should not be root

```
bash create-git-repo.sh REPO WEBSITE USER
```

You can now add the server a remote git url ie:

```
git remote add deploy user@<ip|domain>:/home/{user}/git/REPO
```

now when you

```
git push deploy
```

it will push to the remote server and trigger a build. Your new code should be reflected on your production site.
