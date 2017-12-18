#!/bin/bash

USER_1="whitehat1"
USER_2="whitehat2"
GROUP_NAME="whitehat"
TMP_DIR="/root/whitehat"
ETC_DIR="/etc/whitehat"
RUN_DIR="/run/whitehat"
GIT_URL="https://github.com/everping/whitehat-grand-prix-2017.git"


install_dependencies() {
	echo "[++] Installing dependencies..."
	apt-get update
	apt-get install -y git python2.7 python-pip python-dev libmysqlclient-dev nginx python3-pip nginx mysql-server mysql-client libmysqlclient-dev build-essential libssl-dev libffi-dev python3-dev
	sudo -H pip3 install --upgrade pip
	sudo -H pip2 install --upgrade pip
	sudo -H pip3 install virtualenv
	sudo -H pip2 install supervisor
}

update_kernel() {
	echo "[++] Updating Kernel..."
	sudo apt-get update && sudo apt-get -y dist-upgrade
}

clean_up() {
	rm -rf ${TMP_DIR}
	rm -rf /home/${USER_2}/src/requirements.txt
}

create_users() {
        echo "[++] Creating users and groups..."
	groupadd ${GROUP_NAME}
	useradd ${USER_1} -m
	usermod -a -G ${GROUP_NAME} ${USER_1}
	useradd ${USER_2} -m
	usermod -a -G ${GROUP_NAME} ${USER_2}
}

clone_source_code() {
        echo "[++] Cloning source code..."
	git clone ${GIT_URL} ${TMP_DIR}
	mkdir -p /home/${USER_1}/src
	cp -R ${TMP_DIR}/src/challenge_1/* /home/${USER_1}/src
	mkdir -p /home/${USER_1}/src/sessions

	mkdir -p /home/${USER_2}/src
	cp -R ${TMP_DIR}/src/challenge_2/* /home/${USER_2}/src
	
	mkdir -p ${ETC_DIR}
	cp -R ${TMP_DIR}/config/* ${ETC_DIR}
}

config() {
        echo "[++] Configuring..."
	mkdir -p /var/log/gunicorn
	mkdir -p /var/log/supervisor
	mkdir -p  ${RUN_DIR}
	mkdir -p /etc/supervisor
	mkdir -p /etc/supervisor/conf.d
	cp  ${ETC_DIR}/supervisord.conf /etc/supervisor/
	ln -s  ${ETC_DIR}/nginx_whitehat2 /etc/nginx/sites-enabled/
	ln -s  ${ETC_DIR}/supervisord_whitehat2.conf /etc/supervisor/conf.d/
	ln -s  ${ETC_DIR}/nginx_whitehat1 /etc/nginx/sites-enabled/
	ln -s  ${ETC_DIR}/supervisord_whitehat1.conf /etc/supervisor/conf.d/
	rm -rf /etc/nginx/sites-available/default && rm -rf /etc/nginx/sites-enabled/default
}

set_permissions() {
        echo "[++] Setting permissions..."
	chown root:${GROUP_NAME} /var/log/gunicorn
	chmod 770 /var/log/gunicorn
	
	chown -R root ${ETC_DIR}
	chmod -R 700 ${ETC_DIR}
	
	chown -R root /etc/supervisor
	chmod 700 /etc/supervisor
	
	chown ${USER_2}:${USER_2} ${RUN_DIR}

	chown -R ${USER_1}:${USER_1} /home/${USER_1}
	chmod 700 /home/${USER_1}
	chown -R root:root /home/${USER_1}/src
	chmod 1777 /home/${USER_1}/src/sessions
	
	echo '${USER_1} hard nproc 50;' >> /etc/security/limits.conf
	sysctl -w kernel.dmesg_restrict=1
	
	chown -R ${USER_2}:${USER_2} /home/${USER_2}/
	chmod 700 /home/${USER_2}/
	
	# prevent users from seeing each other's processes
	mount -o remount,hidepid=2 /proc
	
	chmod 1733 /tmp /var/tmp /dev/shm
	chown root:${USER_2} /home/${USER_2}/src/ping_api/private/*
	chmod 440 /home/${USER_2}/src/ping_api/private/*
}

init_db() {
        echo "[++] Initializing database..."
	echo "[++] Enter the root password of database"
	mysql -u root -p < ${ETC_DIR}/whitehat1.sql
}


install_libraries() {
        echo "[++] Installing libraries..."
	cpan DBI Try::Tiny URI::QueryParam HTTP::Request HTTP::Response Path::Resolve CGI::Cookie HTTP::Server::Brick JSON DBD::mysql
	sudo -H -u ${USER_2} /home/${USER_2}/env/bin/pip3 install -r /home/${USER_2}/src/requirements.txt
	virtualenv -p python3 /home/${USER_2}/env
}

start_services() {
        echo "[++] Starting services..."
	supervisord
	supervisorctl start all
	service nginx restart
}

update_kernel
install_dependencies
create_users
clone_source_code
config
init_db
install_libraries
set_permissions
start_services
clean_up
