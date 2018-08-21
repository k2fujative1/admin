![alt text](https://raw.githubusercontent.com/k2fujative1/admin/master/empire.jpg)

**README**

PREREQUISITES:

For this project I used VirtualBox and Ubuntu. I began by creating two VM's. All scripts or configuration names are listed under each step (with the \*)

**host 1**: vbox name: git-server (This is the "local" machine)
```
IP: 10.0.2.16
User: daniel
Hostname: gitserver
Password: empiredidnothingwrong
```
**host 2**: vbox-name: web-server (This is the "remote/Production" machine)
```
IP: 10.0.2.15
User: daniel2
Hostname: webserver
Password: empiredidnothingwrong
```
Primary folders in this repo are:
```
configurations
hooks
scripts
ssl
ssh
```
**Step 1: Set up two hosts with the above parameters, 4gb of memory, and 10gb of hdd space. **

**Step 2: Create a network called EmpireNet:**

![alt text](https://raw.githubusercontent.com/k2fujative1/admin/master/Capture.PNG)

**You will be using this network AFTER YOU'VE FINISHED UPDATING THE MACHINES.**

**Step 3: Install required dependencies for git, ssh, and sanity (Don't enable "NAT networking" until after this, otherwise you won't get all of the required dependencies) run script on both machines:**
```
#!/bin/bash
sudo apt install net-tools apache2 git vim tmux make perl gcc openssh-server openssh-client
exit
cd
```
*\*init-dependency-install.sh*

**Step 4: Set up git repo "admin" and git user "admin" (On both machines):**
```
mkdir admin && cd admin
git init
git config --global user.email "admin@admin.com"
git config --global user.name "admin"
```
*\*make-git-things.sh*

****Step 5: Set up git hooks (On gitserver)****
```
cd .git && cd hooks
sudo vim post-commit
```
***Type/or copy this into the 'post-commit' file:***
```
#!/bin/bash
unset GIT_INDEX_FILE
git --work-tree=/var/www/html --git-dir=/home/daniel/admin/.git
checkout -f
```
*\*post-commit*

**Step 6: Set up SSH between local and remote server (Execute on local machine (IE: gitserver)**
```
#!/bin/bash
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub | ssh daniel2@10.0.2.15 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
*\*ssh-connect-setup.sh*

**Add the following code to the .ssh/config file to ensure git uses port 22**
```
Host localhost 
Port 22
```

**Step 7: Make DocumentRoot owner the current user (ON REMOTE/Production machine)**

`sudo chown -R `whoami`:`id -gn` /var/www/html`

**Step 8: Initialize 'admin' repo on production server (ie: webserver)**
```
cd && mkdir ~/admin && cd ~/admin
git init ---bare
```
`vim hooks/post-receive`

***PUT THE FOLLOWING CODE INTO 'post-receive':***
```
#!/bin/bash
while read oldrev newrev ref
do
    if [[ $ref =~ .*/master$ ]];
    then
          echo "Master ref has been received. Deploying master branch to production server..."
          git --work-tree=/var/www/html --git-dir=/home/daniel2/admin checkout -f
    else
          echo "Ref $ref successfully received. Doing nothing: only the master branch may be deployed on this server."
    fi
done
```
*\*post-receive*

**Then make it executable**

`chmod +x post-receive`

**Step 9: Make web-server execute all scripts in repo upon webpage loading:**
```
cd /etc/apache2/apache2.conf
sudo vim apache2.conf
```
***PUT THE FOLLOWING CODE INTO at the end of 'apache2.conf':***
```
<Directory /var/www/html\>
Options +ExecCGI
AddHandler cgi-script .sh
</Directory>
```
*\*apache2.conf*

***Then enable the cgi module:***

`sudo a2enmod cgi`

***Restart the apache server***

`sudo systemctl restart apache2.service`

***Add .htaccess file to /var/www/html***
```
Options +ExecCGI
AddHandler cgi-script .sh
```
*.htaccess*

***Create the following file 'psAll.sh':***
```
#!/bin/bash
echo -e "Content-type: text/html\n"**
echo "<html><body"
echo "<pre>"
for f in *.sh;
do
      if [ "$f" != "$0" ]
      then
            bash "$f"*
      fi
done
echo "Outside loop"
echo "</pre>"
echo "</body></html>"
```
*\*psAll.sh*

***\*place this file in the DocumentRoot /var/www/html***

**Step 10: Setup SSL on Remote Server for port 443 setup:**
```
sudo mkdir /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -out /etc/apache2/ssl/server.crt -keyout /etc/apache2/ssl/server.key
sudo a2enmod ssl
sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf
systemctl restart apache2.service
```
**\*ssl-config.sh (Shell script to execute above)**
**\*server.crt**
**\*server.key**

**Step 11: Force apache to only serve encrypted traffic:**

***Place the following in '000-default.conf':***
```
<VirtualHost *:80>
        ServerAdmin webmaster\@localhost
        DocumentRoot /var/www/html/psAll.sh
        Redirect permanent / <https://localhost/psAll.sh>
        ErrorLog \${APACHE\_LOG\_DIR}/error.log
        CustomLog \${APACHE\_LOG\_DIR}/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```
*\*000-default.conf*

***Place the following in '000-default-ssl.conf:***
```
<IfModule mod_ssl.c>
          <VirtualHost _default_:443>
                  ServerAdmin webmaster@localhost

                  DocumentRoot /var/www/html

                  ErrorLog ${APACHE_LOG_DIR}/error.log
                  CustomLog ${APACHE_LOG_DIR}/access.log combined

                  SSLEngine on

                  SSLCertificateFile /etc/apache2/ssl/server.crt

                  SSLCertificateKeyFile /etc/apache2/ssl/server.key

                  <FilesMatch "\.(cgi|shtml|phtml|php)\$">
                   SSLOptions +StdEnvVars
                  </FilesMatch>
                  <Directory /usr/lib/cgi-bin>
                                  SSLOptions +StdEnvVars
                  </Directory>
          </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```
*\*000-default-ssl.conf*

`systemctl restart apache2`

**Final Step:**

**Restart ssh for good measure on both machines:**

`systemctl restart sshd`

**Please let me know if you have any questions: daniel.brown3027@gmail.com**

**The 'sources.txt' file lists all of the help/tutorials/guide/code/etc. that I used in this project**
