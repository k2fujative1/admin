#!/bin/bash
sudo mkdir /etc/apache2/ssl && cd && sudo openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -out /etc/apache2/ssl/server.crt -keyout /etc/apache2/ssl/server.key && sudo a2enmod ssl && sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf && systemctl restart apache2

