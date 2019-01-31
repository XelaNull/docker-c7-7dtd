# CentOS7 Minimal
FROM centos:7
# Set the local timezone
ENV TIMEZONE="America/New_York" \
    7DTD_TELNET_PORT="8081" \
    7DTD_TELNET_PASSWORD="sanity"

# Install daemon packages# Install base packages
RUN yum -y install epel-release && yum -y install supervisor syslog-ng cronie \
    python wget net-tools rsync sudo git logrotate which && \
# Configure Syslog-NG for use in a Docker container
    sed -i 's|system();|unix-stream("/dev/log");|g' /etc/syslog-ng/syslog-ng.conf

# Install newest stable MariaDB: 10.3 
RUN printf '[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.3/centos7-amd64\n\
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck=1' > /etc/yum.repos.d/MariaDB-10.3.repo && \
    yum -y install MariaDB-server MariaDB-client
# Create MySQL Start Script
RUN echo $'#!/bin/bash\n\
[[ `pidof /usr/sbin/mysqld` == "" ]] && /usr/bin/mysqld_safe &\n\
sleep 5\nexport SQL_TO_LOAD="/mysql_load_on_first_boot.sql"\n\
while true; do\n\
  if [[ -e "$SQL_TO_LOAD" ]]; then /usr/bin/mysql -u root --password=\'\' < $SQL_TO_LOAD && mv $SQL_TO_LOAD $SQL_TO_LOAD.loaded; fi\n\
  sleep 10\n\
done\n' > /start_mysqld.sh   

# Install Webtatic YUM REPO + Webtatic PHP7, # Install Apache & Webtatic mod_php support 
RUN yum -y localinstall https://mirror.webtatic.com/yum/el7/webtatic-release.rpm && \
    yum -y install php72w-cli httpd mod_php72w php72w-opcache php72w-mysqli php72w-curl && \
    rm -rf /etc/httpd/conf.d/welcome.conf

# Create beginning of supervisord.conf file
RUN printf '[supervisord]\nnodaemon=true\nuser=root\nlogfile=/var/log/supervisord\n' > /etc/supervisord.conf && \
# Create start_httpd.sh script
    printf '#!/bin/bash\nrm -rf /run/httpd/httpd.pid\nwhile true; do\n/usr/sbin/httpd -DFOREGROUND\nsleep 10\ndone' > /start_httpd.sh && \
# Create start_supervisor.sh script
    printf '#!/bin/bash\n/usr/bin/supervisord -c /etc/supervisord.conf' > /start_supervisor.sh && \
# Create syslog-ng start script    
    printf '#!/bin/bash\n/usr/sbin/syslog-ng --no-caps -F -p /var/run/syslogd.pid' > /start_syslog-ng.sh && \
# Create Cron start script    
    printf '#!/bin/bash\n/usr/sbin/crond -n\n' > /start_crond.sh && \
# Create script to add more supervisor boot-time entries
    echo $'#!/bin/bash \necho "[program:$1]";\necho "process_name  = $1";\n\
echo "autostart     = true";\necho "autorestart   = false";\necho "directory     = /";\n\
echo "command       = $2";\necho "startsecs     = 3";\necho "priority      = 1";\n\n' > /gen_sup.sh

# STEAMCMD
RUN yum -y install glibc.i686 libstdc++.i686 telnet expect unzip vim-enhanced && useradd steam && cd /home/steam && \
    wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz && \
    tar zxf steamcmd_linux.tar.gz

RUN echo $'#!/bin/bash\n\
export INSTALL_DIR=/data/7DTD\n\
while true; do\n\
  if [ -f $INSTALL_DIR/7DaysToDieServer.x86_64 ]; then sudo -u steam $INSTALL_DIR/7DaysToDieServer.x86_64 -configfile=$INSTALL_DIR/serverconfig.xml -logfile $INSTALL_DIR/7dtd.log -quit -batchmode -nographics -dedicated; fi\n\
  echo "PLEASE RUN /init_steamcmd_7dtd.sh" && sleep 10\n\
done\n' > /start_7dtd.sh
RUN printf '#!/bin/bash\n/7dtd-sendcmd.sh saveworld;\n/7dtd-sendcmd.sh shutdown;\nsleep 5;\n' > /stop_7dtd.sh && \
    printf "PID=\`ps awwux | grep 7DaysToDieServer.x86_64 | grep -v sudo | grep -v grep | awk '{print \$2}'\`;\n" >> /stop_7dtd.sh && \
    printf '[[ ! -z $PID ]] && kill -9 $PID' >> /stop_7dtd.sh

RUN echo $'#!/usr/bin/expect\n\
set timeout 5\nset command [lindex $argv 0]\n\
spawn telnet 127.0.0.1 8081\nexpect "Please enter password:"\nsend "sanity\r";\n\
sleep 1\nsend "$command\r"\nsend "exit\r";\nexpect eof\n\
send_user "Sent command to 7DTD: $command\n"' > /7dtd-sendcmd.sh
COPY install_7dtd.sh /install_7dtd.sh
COPY 7dtd-APPLY-CONFIG.sh /7dtd-APPLY-CONFIG.sh
COPY replace.sh /replace.sh

# Install 7DTD Auto-Reveal Map
RUN git clone https://github.com/XelaNull/7dtd-auto-reveal-map.git && chmod a+x /7dtd-auto-reveal-map/*.sh

# Reconfigure Apache to run under steam username, to retain ability to modify steam's files
RUN sed -i 's|User apache|User steam|g' /etc/httpd/conf/httpd.conf && \
    sed -i 's|Group apache|Group steam|g' /etc/httpd/conf/httpd.conf && \
    chown steam:steam /var/www/html -R && \
    echo $'<Directory "/data/7DTD">\n\
        Options all\n\
        AllowOverride all\n\
    </Directory>' > /etc/httpd/conf.d/7dtd.conf

# Ensure all packages are up-to-date, then fully clean out all cache
RUN chmod a+x /*.sh && yum -y update && yum clean all && rm -rf /tmp/* && rm -rf /var/tmp/* 

# Create different supervisor entries
RUN /gen_sup.sh syslog-ng "/start_syslog-ng.sh" >> /etc/supervisord.conf && \
    /gen_sup.sh mysqld "/start_mysqld.sh" >> /etc/supervisord.conf && \
    /gen_sup.sh crond "/start_crond.sh" >> /etc/supervisord.conf && \
    /gen_sup.sh httpd "/start_httpd.sh" >> /etc/supervisord.conf && \
    /gen_sup.sh 7dtd "/start_7dtd.sh" >> /etc/supervisord.conf && \
    /gen_sup.sh 7dtd-startloop "/7dtd-auto-reveal-map/7dtd-run-after-initial-start.sh" >> /etc/supervisord.conf

RUN mkdir /data
VOLUME ["/data"]

# Set to start the supervisor daemon on bootup
ENTRYPOINT ["/start_supervisor.sh"]