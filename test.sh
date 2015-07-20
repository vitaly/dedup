#!/bin/bash -ex

T=tmp/test

rm -rf $T

mkdir -p "$T/1"
echo 123 > "$T/1/123"
echo 456 > "$T/1/456"

dedup index "$T/i1" "$T/1"

mkdir -p $T/2

echo aaa > "$T/2/aaa"
echo bbb > "$T/2/bbb"

dedup index "$T/i2" "$T/2"

mkdir -p "$T/3/a A/b ' B/c C"
echo 123 > "$T/3/a A/1 2 3"
echo 123 > "$T/3/a A/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo aaa > "$T/3/a A/b ' B/a 'aa"
echo xxx > "$T/3/a A/b ' B/c C/x xx"

dedup move "$T/3" "$T/4" "$T/i1" "$T/i2"

echo -------------
tree $T/4
