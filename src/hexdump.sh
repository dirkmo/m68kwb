#!/bin/bash
# convert bin file to stream of ascii hex numbers
xxd -u -p $1 | tr -d '\n'
