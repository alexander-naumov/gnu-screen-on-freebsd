#!/bin/sh

set -exu

uname -a
cc -v
git -c http.sslVerify=false clone https://github.com/alexander-naumov/gnu-screen.git
cd gnu-screen/src
./autogen.sh
cc=gcc ./configure
gmake
./screen -v
./screen -ls || echo $?
gmake clean
cc=clang ./configure CFLAGS="-Wall -DDEBUG"
grep @CFLAGS@ Makefile.in
gmake
./screen -v
./screen -ls || echo $?
./screen --help
