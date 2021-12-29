#!/bin/bash
make clean
perl -I `pwd` tagit.pl
# experimental: overwrite tit2.mk with data taken from rhythmbox's db
./tagit_venv/bin/python ./tag_from_rb.py > tit2.mk
make
