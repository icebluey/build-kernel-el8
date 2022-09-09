#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/sbin/ldconfig

rm -fr /tmp/kernel-ml
rm -fr /tmp/build-linux-kernel-done.txt
rm -fr /tmp/make_rpm-pkg.log
rm -fr ~/rpmbuild
sleep 5

set -e

_start_epoch="$(date -u +%s)"
starttime="$(echo ' Start Time:  '"$(date -ud @"${_start_epoch}")")"

echo " ${starttime}" > /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log


###############################################################################

mkdir -p ~/rpmbuild/SOURCES
cp -pf config-*-x86_64 kernel*.spec linux-*.tar.xz ~/rpmbuild/SOURCES/
cp -pf sources/* ~/rpmbuild/SOURCES/
sleep 10

cd /tmp

rpmbuild -v -ba ~/rpmbuild/SOURCES/kernel*.spec >> /tmp/make_rpm-pkg.log 2>&1
sleep 10
echo >> /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log
rpmbuild -v --target noarch -bb ~/rpmbuild/SOURCES/kernel*.spec >> /tmp/make_rpm-pkg.log 2>&1
sleep 10
echo >> /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log
###############################################################################

_end_epoch="$(date -u +%s)"
finishtime="$(echo ' Finish Time:  '"$(date -ud @"${_end_epoch}")")"
_del_epoch=$((${_end_epoch} - ${_start_epoch}))
_elapsed_days=$((${_del_epoch} / 86400))
_del_mod_days=$((${_del_epoch} % 86400))
elapsedtime="$(echo 'Elapsed Time:  '"${_elapsed_days} days ""$(date -u -d @${_del_mod_days} +"%T")")"

echo " ${starttime}" >> /tmp/make_rpm-pkg.log
echo "${finishtime}" >> /tmp/make_rpm-pkg.log
echo "${elapsedtime}" >> /tmp/make_rpm-pkg.log

echo >> /tmp/make_rpm-pkg.log
echo '  build linux rpm done' >> /tmp/make_rpm-pkg.log
echo >> /tmp/make_rpm-pkg.log

###############################################################################

cd /tmp
echo 'done' > /tmp/build-linux-kernel-done.txt
exit

