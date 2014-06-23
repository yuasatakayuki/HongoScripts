#!/bin/bash

#20100701 Takayuki Yuasa

if [ _$1 = _ ]; then
name=`basename $0`
cat << EOF
usage:
$name (file1) (file2) ... (fileN)

This script creates an HTML code which lists hyper links
for downloading files specified as arguments. Save the
output as "index.html" for example.
EOF
exit
fi

cat << EOF
<html>
<head><title>files</title></head>
<body>
EOF

for file in $@; do
cat << EOF
<a href="$file">$file</a><br/>
EOF
done

cat << EOF
</body>
</html>
EOF
