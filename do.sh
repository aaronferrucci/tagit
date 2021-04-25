#!/bin/bash
make clean
perl tagit.pl > Makefile
make
