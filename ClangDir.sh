#!/bin/sh

clang_installed_dir=$($CLANGXX --version | grep "InstalledDir" | sed -E 's/InstalledDir: (.*)/\1/')

echo -n "$clang_installed_dir/../lib/clang"
