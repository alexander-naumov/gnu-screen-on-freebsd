#!/bin/sh

set -exu

uname -a
cc -v
git -c http.sslVerify=false clone https://github.com/alexander-naumov/gnu-screen.git
cd gnu-screen/src
./autogen.sh
cc=gcc ./configure CFLAGS="-Wall"
gmake
./screen -v
./screen -ls || echo $?
gmake clean
cc=clang ./configure CFLAGS="-Wall -DDEBUG"
gmake
./screen -v
./screen --help
