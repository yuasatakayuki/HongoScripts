#!/bin/bash

#20100604 Takayuki Yuasa
#to convert ADVENTURE source to new C++ standard

if [ _$1 = _ ]; then
echo "give cpp file to be converted...exit"
exit
fi

file=$1

if [ ! -f $file ]; then
echo "file not found...exit"
exit
fi

cp $file ${file}.before_conversion
tmp=`get_hash_random.pl`

for header in iostream iomanip fstream hash map list; do
sed -e "s/${header}.h/$header/g" $file > $tmp
mv $tmp $file
done

for header in istdiostream ostdiostream stdiostream; do
sed -e "s/${header}/iostream/g" $file > $tmp
mv $tmp $file
done

for header in istrstream ostrstream sstream; do
sed -e "s/$header.h/sstream/g" $file > $tmp
mv $tmp $file
done
