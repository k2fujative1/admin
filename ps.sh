#!/bin/sh
echo -e "Content-type: text/html\n"
echo "<html><body"
echo "<h1>top</h1>"
echo "<pre>"
top -b -n 1
echo "</pre>"
echo "<h1>ps</h1>"
echo "<pre>"
ps aux
echo "</pre>"
echo "</body></html>"
