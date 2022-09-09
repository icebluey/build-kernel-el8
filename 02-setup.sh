#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/sbin/ldconfig

_datenow="$(date -u +%Y%m%d)"

set -e

ls -la --color "${1}"
ls -la --color linux-*.tar.xz

_linux_kernel_ver=$(ls -1 linux-*.tar.xz | sed -e 's/.*linux-//g' -e 's|\.tar.*||g')

_major="$(echo "${_linux_kernel_ver}" | cut -d '.' -f1)"
_minor="$(echo "${_linux_kernel_ver}" | cut -d '.' -f2)"
_patch="$(echo "${_linux_kernel_ver}" | cut -d '.' -f3)"

sed "/%define LKAver /s|LKAver .*|LKAver ${_linux_kernel_ver}|g" -i "${1}"
sed "/pkg_release /s|1%{?dist}|${_datenow}%{?dist}|g" -i "${1}"
sed 's|^NoSource:|#NoSource:|g' -i "${1}"

sed -e '/^%changelog/,$d' -i "${1}"
echo '%changelog' >> "${1}"
if [[ "${_patch}" > 0 ]]; then
    for (( i = "${_patch}"; i >= 0; i-- )); do
        if [[ ${i} == 0 ]]; then
            _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
            _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"
            echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}" >> "${1}"
            echo "- Updated with the ${_major}.${_minor} source tarball." >> "${1}"
            echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}]" >> "${1}"
        else
            _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
            _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"            
            echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}.${i}" >> "${1}"
            echo "- Updated with the ${_major}.${_minor}.${i} source tarball." >> "${1}"
            echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}.${i}]" >> "${1}"
        fi
    done
elif [[ "${_patch}" == "0" ]]; then
    _changelog_date="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Date:' | sed 's/^Date://g' | sed "s/^[ \t]*//" | awk '{print $1,$2,$3,$5}')"
    _changelog_author="$(wget -qO- "https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}" | head -n 4 | grep -i '^Author:' | sed 's/^Author://g' | sed "s/^[ \t]*//")"
    echo "* ${_changelog_date} ${_changelog_author} - ${_major}.${_minor}" >> "${1}"
    echo "- Updated with the ${_major}.${_minor} source tarball." >> "${1}"
    echo "- [https://www.kernel.org/pub/linux/kernel/v${_major}.x/ChangeLog-${_major}.${_minor}]" >> "${1}"
fi
echo >> "${1}"

echo
grep '%define LKAver' "${1}"
echo
grep -i 'https://www.kernel.org/pub/linux/kernel/' "${1}"

###############################################################################
if [[ -e config-"${_linux_kernel_ver}"-x86_64 ]]; then
    rm -fr config-"${_linux_kernel_ver}"-x86_64
fi
if ls .config >/dev/null 2>&1; then
    cat .config > config-"${_linux_kernel_ver}"-x86_64
    sleep 1
    sed "/Kernel Configuration/s|^# Linux/x86_64 .*Kernel Configuration|# Linux/x86_64 ${_linux_kernel_ver} Kernel Configuration|g" -i config-"${_linux_kernel_ver}"-x86_64
fi

echo
echo ' done'
exit

