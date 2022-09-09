#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

# https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.8.7.tar.xz
# 

set -e

if [[ -z ${1} ]]; then
    echo
    echo './dl-linux-X.Y.sh X.Y'
    echo
    exit 1
fi
_major="$(echo "${1}" | cut -d '.' -f1)"
_minor="$(echo "${1}" | cut -d '.' -f2)"
_patch="$(echo "${1}" | cut -d '.' -f3)"

echo
echo ' Download linux kernel: v'"${1}"
echo
_links="$(wget -qO- 'https://www.kernel.org/' | grep -i '<a href="https://cdn.kernel.org/pub/linux/kernel/v[3-9]' | grep -i '\.xz"' | sed 's/"/ /g' | sed 's/ /\n/g' | grep -i '^http' | grep -i '\.tar\.xz$' | sort -V | uniq)"
_download_link="$(echo "${_links}" | grep "${_major}\.${_minor}\.${_patch}" | sort -V | uniq | tail -n 1)"
_filename="$(echo "${_download_link}" | sed 's|/| |g' | awk '{print $NF}')"
# wget -c -t 0 -T 9 "${_download_link}"

_major="$(echo "${_filename}" | sed 's/linux-//g' | sed 's/\.tar.*//g' | cut -d '.' -f1)"
_minor="$(echo "${_filename}" | sed 's/linux-//g' | sed 's/\.tar.*//g' | cut -d '.' -f2)"
#_filename="$(wget -qO- "https://cdn.kernel.org/pub/linux/kernel/v${_major}.x/" | grep -i '<a href="linux-[1-9]' | grep -i '\.xz"' | sed 's/"/ /g' | sed 's/ /\n/g' | grep -i "^linux-${_major}\.${_minor}" | grep -i '\.tar\.xz$' | sort -V | uniq | tail -n1)"

if [[ -n ${_filename} ]]; then
    _major="$(echo "${_filename}" | sed 's/linux-//g' | sed 's/\.tar.*//g' | cut -d '.' -f1)"
    _minor="$(echo "${_filename}" | sed 's/linux-//g' | sed 's/\.tar.*//g' | cut -d '.' -f2)"
    _patch="$(echo "${_filename}" | sed 's/linux-//g' | sed 's/\.tar.*//g' | cut -d '.' -f3)"
    wget -c -t 0 -T 9 "https://cdn.kernel.org/pub/linux/kernel/v${_major}.x/${_filename}"
else
    _filename="$(echo "${_download_link}" | sed 's|/| |g' | awk '{print $NF}')"
    wget -c -t 0 -T 9 "${_download_link}"
fi

sleep 2
if [[ -z "${_patch}" ]]; then
    _patch=0
fi
if [[ -e kernel-"${_major}.${_minor}.${_patch}".spec ]]; then
    rm -fr kernel-"${_major}.${_minor}.${_patch}".spec
fi
if ls .kernel-*.spec >/dev/null 2>&1; then
    cp -f .kernel-*.spec kernel-"${_major}.${_minor}.${_patch}".spec
fi

echo
sha256sum .kernel*.spec kernel*.spec
echo

_sum="$(wget -qO- "https://cdn.kernel.org/pub/linux/kernel/v${_major}.x/sha256sums.asc" | grep -i "${_filename}$" | awk '{print $2,$1}' | sort -V | uniq | tail -n1 | awk '{print $NF}')"
if [[ -n "${_sum}" ]]; then
    echo "${_sum}  ${_filename}" > "${_filename}".sha256
    sha256sum -c "${_filename}".sha256
    echo
    sleep 2
    rm -f "${_filename}".sha256
fi

echo
echo ' done'

exit

