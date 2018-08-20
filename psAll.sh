#!/bin/bash
echo -e "Content-type: text/html\n"
echo "<html><body"
echo "<h1>top</h1>"
echo "<pre>"
for f in *.sh; do
	bash "$f" -H
done
echo "</pre>"
echo "</body></html>"
