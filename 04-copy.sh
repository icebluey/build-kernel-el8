#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

set -e

_kver="$(ls -1 /root/rpmbuild/RPMS/x86_64/kernel-[1-9]*.rpm | sed 's|/|\n|g' | grep '\.rpm$' | cut -d- -f2)"

_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"

install -m 0755 -d kernel/kernel-"${_kver}"-repos/packages
install -m 0755 -d kernel/assets
install -m 0755 -d kernel/src
sleep 1
cd kernel/kernel-"${_kver}"-repos/packages/
find ~/rpmbuild/RPMS/ -type f -iname '*.rpm' | xargs --no-run-if-empty -I '{}' /bin/cp -v -a '{}' ./
sleep 2
sha256sum *.rpm > sha256sums.txt
sleep 2
cd ..
echo
createrepo -v .
echo
sleep 2
cd ..
tar -zcvf assets/kernel-"${_kver}"-repos.tar.gz kernel-"${_kver}"-repos
find ~/rpmbuild/BUILD/ -type f -iname 'config-*-x86_64' -exec /bin/cp -v -f '{}' src/ \; 
echo '[rhel-7-server-kernel-rpms]
baseurl = file:///.repos/kernel
name = Red Hat Enterprise Linux 7 Server - Kernel (RPMs)
enabled = 1
gpgcheck = 0
' > src/kernel.repo.example
chmod 0644 src/kernel.repo.example

echo '### Update linux firmware first
```
./00-update_linux-firmware.sh
```
' > src/README.md
chmod 0644 src/README.md

echo
echo ' done'
echo
exit

