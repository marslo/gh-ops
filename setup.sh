#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2155
declare -r _HERE="$( dirname "$( readlink -f "${BASH_SOURCE[0]:-$0}" )" )"
function info() { echo -e "\033[30;48;5;151m>> $*\033[0m"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force  ) FORCE=true; shift ;;
    *        ) echo "ERROR: unknown option '$1'"; exit 1;;
  esac
done

# init submodules if any
info "initializing git submodules if any:"
pushd . > /dev/null && cd "${_HERE}"
if git --no-pager config \
       --file "$(git rev-parse --show-toplevel)"/.gitmodules \
       --get-regexp url; then
  git submodule foreach --recursive git clean -dffx;
  git submodule foreach --recursive git reset --hard;
  git submodule update -f --init --recursive;
fi
popd > /dev/null


# install bash completion
declare COMP_SRC="${_HERE}/etc/gh-arsenal-completion.sh"
declare COMP_DIR="${BASH_COMPLETION_USER_DIR:-${HOME}/.local/share/bash-completion}"
declare COMP_DST="${COMP_DIR}/gh-arsenal-completion.sh"
test -d "${COMP_DIR}" || mkdir -p "${COMP_DIR}"
${FORCE:=false} && test -L "${COMP_DST}" && unlink "${COMP_DST}"
test -L "${COMP_DST}" || {
  info "installing bash completion for gh-ops:"
  ln -s "${COMP_SRC}" "${COMP_DST}"
  echo -e ".. bash completion installed: '${COMP_DST}'"
  echo -e ".. ensure the following order in ~/.bashrc:"
  echo -e "\033[0;3;32m\`\`\`bash"
  echo -e "command gh completion -s bash"
  echo -e "source ${COMP_DST}"
  echo -e "\`\`\`\033[0m"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
