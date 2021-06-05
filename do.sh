#!/bin/bash
make clean
perl -I `pwd` tagit.pl > Makefile
make
