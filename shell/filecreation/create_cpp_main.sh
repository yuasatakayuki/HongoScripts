#!/bin/bash

#20090302 Takayuki Yuasa

if [ _$1 = _ ];
then
file=main.cc
else
file=$1
fi

cat << EOF > $file
#include <string>
#include <iostream>
#include <vector>
#include <sstream>
using namespace std;

int main(int argc,char* argv[]){

}
EOF
