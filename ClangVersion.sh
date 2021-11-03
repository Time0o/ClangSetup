#!/bin/sh

clang_version=$($CLANGXX --version | grep "clang version" | sed -E 's/clang version (.*)/\1/')

echo -n "$clang_version"
