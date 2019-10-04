#!/usr/bin/env bash

sourceBase="$(dirname "${SOURCE}")"/../
cd "${basedir:-$sourceBase}"

basedir="$(pwd -P)"
cd - >/dev/null

# Load configuration
source "${basedir}/scripts/config.sh"

bashColor () {
    if [ "${2}" ]; then
        echo -e "\e[$1;$2m"
    else
        echo -e "\e[$1m"
    fi
}

bashColorReset () {
	echo -e "\e[m"
}

cleanupPatches () {
	cd "${1}"
	for patch in *.patch; do
		gitver="$(tail -n 2 "${patch}" | grep -ve "^$" | tail -n 1)"
		diffs="$(git diff --staged "${patch}" | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index|Date\: )")"

		testver=$(echo "${diffs}" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "${gitver}")
		if [ -n "${testver}" ]; then
			diffs="$(echo "${diffs}" | tail -n +3)"
		fi

		if [ -z "$diffs" ] ; then
			git reset HEAD "${patch}" >/dev/null
			git checkout -- "${patch}" >/dev/null
		fi
	done
}
pushRepo () {
	if [[ "$(git config minecraft.push-"${FORK_NAME}")" == "1" ]]; then
        echo "Pushing - $1 ($3) to $2"
        (
            cd "${1}"
            git remote rm "${FORK_NAME}-push" > /dev/null 2>&1
            git remote add "${FORK_NAME}-push" "${2}" >/dev/null 2>&1
            git push "${FORK_NAME}-push" "${3}" -f
        )
	fi
}
basedir () {
	cd "${basedir}"
}

gethead () {
	(
		cd "$1"
		git log -1 --oneline
	)
}

paperstash () {
	STASHED="$(git stash)"
}

paperunstash () {
	if ! [ "${STASHED}" = "No local changes to save" ] ; then
		git stash pop
	fi
}
