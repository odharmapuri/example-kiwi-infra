#!/bin/bash
sudo su
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz"
yum install java-1.8.0-openjdk -y
yum install git maven wget -y
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
mkdir /usr/local/tomcat8
tar xzvf tomcatbin.tar.gz --strip-components=1 -C /usr/local/tomcat8
useradd --shell /sbin/nologin tomcat
chown -R tomcat.tomcat /usr/local/tomcat8
chmod -R +rwx /usr/local/tomcat8
rm -rf /etc/systemd/system/tomcat.service

cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target
[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat8
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat8
Environment=CATALINE_BASE=/usr/local/tomcat8
ExecStart=/usr/local/tomcat8/bin/catalina.sh run
ExecStop=/usr/local/tomcat8/bin/shutdown.sh
SyslogIdentifier=tomcat-%i
[Install]
WantedBy=multi-user.target
EOT
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat
git clone -b vp-rem https://github.com/odharmapuri2/projectslab.git
cd projectslab
mvn install
systemctl stop tomcat
sleep 120
rm -rf /usr/local/tomcat8/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat8/webapps/ROOT.war
systemctl start tomcat
sleep 300
cp target/classes/application.properties /usr/local/tomcat8/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat
