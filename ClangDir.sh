#!/bin/sh

clang_version=$($CLANGXX --version | grep "clang version" | sed -E 's/clang version (.*)/\1/')
clang_installed_dir=$($CLANGXX --version | grep "InstalledDir" | sed -E 's/InstalledDir: (.*)/\1/')

echo -n "$clang_installed_dir/../lib/clang/$clang_version/"
