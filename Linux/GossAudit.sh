#!/usr/bin/env bash

# Copyright (c) 2020 Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script should be used for Rackspace customers to verify if an operating
# system is ready to be enrolled in Guest Operating System Services (GOSS)


# shellcheck disable=SC2034
declare -r _VERSION=1.1.0.0

# Exit codes:
# 1: OS configuration needs correction.
# 77: Insufficent privileges
# 131: OS is unsupported.

function check_bash {
    if [[ $(cut -d . -f 1 <<< "${BASH_VERSION}") -lt "4" ]]; then
       echo "WARNING: Bash must be at least version 4. OS is unsupported."
       exit 131
    fi 
}

# This function verifies that the version of Enterprise Linux is at a supportable version
function check_el {
    # Minimum supported versions are EL 7.5 and 8.2
    # EL 4, 5, 6 are unsupported
    declare -Ar MIN_EL_VERSION=([4]=999 [5]=999 [6]=999 [7]=5 [8]=2)

    el_version=$(grep -oP "\d\.\d\d?" /etc/redhat-release)
    major_version=$(cut -d . -f 1 <<< "${el_version}")
    minor_version=$(cut -d . -f 2 <<< "${el_version}")

    if [[ "${minor_version}" -lt "${MIN_EL_VERSION[${major_version}]}" ]]; then
        echo "WARNING: EL ${el_version} is unsupported."
        exit 131
    fi
}

# This function verifies that the version of Ubuntu is at a supportable version
function check_debian {
    # Debian versions are generally a whole number—8, 9, 10,...—and generally not supported
    # Ubuntu versions look like decimal fractions—14.04,16.04,...
    declare -ar SUPPORTED_UBUNTU_VERSIONS=( 16.04 18.04 )
    # shellcheck disable=SC1091
    source /etc/os-release

    if [[ "${ID}" != "ubuntu" ]]; then
        echo "WARNING: ${ID} is unsupported."
        exit 131
    fi

    if ! grep -q "${VERSION_ID}" <<< "${SUPPORTED_UBUNTU_VERSIONS[*]}"; then
        echo "WARNING: Ubuntu ${VERSION_ID} is unsupported."
        exit 131
    fi

    echo "OS check: OK"
}

function check_os {
    # Assume the operating system is some variant of Enterprise Linux if /etc/redhat-release is present
    if [[ -a /etc/redhat-release ]]; then
        check_el
    # Assume the operating system is some variant of Debian if /etc/debian_version is present
    elif [[ -a /etc/debian_version ]]; then
        check_debian
    else
        echo "WARNING: Unknown OS."
        exit 131
    fi
}

# A server should be able to check for pending updates
function check_yum {
    if command -v yum > /dev/null; then
        # Clear yum/dnf metadata to force yum to check repo data
        # yum clean metadata can be flakey so we just destroy it all
        rm -fr /var/cache/{dnf,yum}

        # yum returns with exit code 1 if it fails to pull down any repo metadata
        yum -q check-update > /dev/null
        if [[ $? -eq 1 ]]; then
            echo "WARNING: Yum is unable to check for updates."
            return 132
        fi
        echo "Yum check: OK"
    fi
}

function check_dns {
    declare -ar RACKSPACE_NAMES=(
        # Rackspace patching internal mirror
        rax.mirror.rackspace.com

        # generic time server address which points to DFW time server
        time.rackspace.com
    )

    for name in "${RACKSPACE_NAMES[@]}"; do
        if ! getent ahosts "${name}" > /dev/null ; then
            echo "WARNING: Failed to resolve ${name}"
            return 130
        fi
    done

    echo "DNS check: OK"
}

function check_users_shell {
    # The login shell is the last field in the passwd file
    # Failures can happen if a user does not have a shell set
    if getent passwd | grep -q ":$"; then
        echo "WARNING: All users should have a login shell configured"
        return 133
    fi

    echo "User shell check: OK"
}

if [[ $(id -u) -ne 0 ]]; then
    echo "Script requires superuser privileges"
    return 77
fi

# These two functions cause the script to exit if they show issues
check_bash
check_os

# All of these functions should run
# If any of them fail, the script returns with exit code 1.

declare -ar CHECK_FUNCTIONS=(
    check_users_shell
    check_dns
    check_yum
)
exit_status=0

for function in "${CHECK_FUNCTIONS[@]}"; do
    if ! $function ; then
        exit_status=1
    fi
done

exit $exit_status
