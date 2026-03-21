#!/usr/bin/env bash
# shellcheck disable=SC2207
#=============================================================================
#     FileName : gh-ops.sh
#       Author : marslo
#      Created : 2026-02-27 23:04:41
#   LastChange : 2026-03-20 21:30:41
#  Description : bash_completion for $ gh-ops and $ gh ops
#=============================================================================

function _compgen_nocase() {
  local cur="$1"
  local candidates="$2"
  local word

  COMPREPLY=()
  for word in ${candidates}; do
    if [[ "${word,,}" == "${cur,,}"* ]]; then
      COMPREPLY+=( "$word" )
    fi
  done
}

#=============================================================================#
# shared completion logic                                                     #
#=============================================================================#
function __gh_ops_completion() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local opts="-c --checkout
              -C --close
              -o --open
              -A --auto-open
              -s --squash
              -r --rebase
              -l --add-label
              -L --remove-label
              -M --comment
              -a --approve
              --request-changes
              --ready
              --draft
              -S --state
              -B --base
              -R --repo
              -v --verbose
              --setup
              --dryrun
              -h --help"

  case "${prev}" in
    -S|--state ) COMPREPLY=( $(compgen -W "open closed all merged" -- "${cur}") ); return ;;
    -B|--base  ) COMPREPLY=( $(compgen -W "$(git branch --format='%(refname:short)' 2>/dev/null)" -- "${cur}") ); return ;;
    -R|--repo  ) local repos=''
                 repos="$(gh repo list --json nameWithOwner -q '.[].nameWithOwner' 2>/dev/null)"
                 local private_repos_file="${GH_OPS_REPOS_FILE:-${HOME}/.config/gh/repos}"
                 [[ -f "${private_repos_file}" ]] && repos+=$'\n'"$(command cat "${private_repos_file}")"
                 _compgen_nocase "${cur}" "${repos}"; return ;;
    -l|--add-label|-L|--remove-label|-M|--comment|--request-changes|-a|--approve ) COMPREPLY=(); return ;;
  esac

  for (( i=1; i < COMP_CWORD; i++ )); do
    [[ "${COMP_WORDS[i]}" == "--" ]] && return
  done

  if [[ ${cur} == -* ]] || [[ ${COMP_CWORD} -ge 1 ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
  fi
}

#=============================================================================#
# for $ gh-ops <tab>                                                          #
#=============================================================================#
function _gh_ops() { __gh_ops_completion; }
complete -F _gh_ops gh-ops

#=============================================================================#
# for $ gh ops <tab>                                                          #
#=============================================================================#
function __gh_ops_complete() { __gh_ops_completion; }

# wrap the original __start_gh function
__orig_start_gh=$(declare -f __start_gh)
eval "${__orig_start_gh//__start_gh/__start_gh_orig}"

function __start_gh() {
  if [[ "${COMP_WORDS[1]}" == "ops" && ${COMP_CWORD} -ge 2 ]]; then
    __gh_ops_complete
    return
  fi
  __start_gh_orig "$@"
}

# vim:tabstop=2:softtabstop=2:shiftwidth=2:expandtab:filetype=sh:
