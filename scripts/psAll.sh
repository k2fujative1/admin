#!/bin/bash
echo -e "Content-type: text/html\n"
echo "<html><body"
echo "<pre>"
for f in *.sh;
do
	if [ "$f" != "$0" ]
	then
		bash "$f"
	fi
	done
#trap EXIT
#exit
echo "Outside loop"
echo "</pre>"
echo "</body></html>"
