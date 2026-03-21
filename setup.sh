#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2155
declare -r _HERE="$( dirname "$( readlink -f "${BASH_SOURCE[0]:-$0}" )" )"

# init submodules if any
if git -C "${_HERE}" --no-pager config \
       --file "$(git -C "${_HERE}" rev-parse --show-toplevel)"/.gitmodules \
       --get-regexp url; then
  git submodule foreach --recursive git clean -dffx;
  git submodule foreach --recursive git reset --hard;
  git submodule update -f --init --recursive;
fi

# install bash completion
declare COMP_SRC="${_HERE}/etc/gh-ops.sh"
declare COMP_DIR="${BASH_COMPLETION_USER_DIR:-${HOME}/.local/share/bash-completion}"
declare COMP_DST="${COMP_DIR}/gh-ops.sh"
test -d "${COMP_DIR}" || mkdir -p "${COMP_DIR}"
test -L "${COMP_DST}" || {
  ln -s "${COMP_SRC}" "${COMP_DST}"
  echo ">> bash completion installed: ${COMP_DST}"
  echo ">> ensure the following order in ~/.bashrc:"
  echo "   command gh completion -s bash"
  echo "   source ${COMP_DST}"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
