#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

rm -fr linux-*.tar.*
rm -fr config-*-x86_64
rm -fr kernel-*.spec

rm -fr /tmp/make_rpm-pkg.log /tmp/build-linux-kernel-done.txt /tmp/kernel

exit
