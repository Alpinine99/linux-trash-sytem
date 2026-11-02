#! /usr/bin/bash

BOLD=$'\e[1m'
RED=$'\e[31;1m'
GRN=$'\e[32;1m'
YEL=$'\e[33;1m'
UL=$'\e[4;1m'
RST=$'\e[0m'

usage() {
	local bin_name=$(basename "$0")
  cat <<EOF
${BOLD}Details:${RST}
  This is a trash/restore tool
${BOLD}Usage:${RST}${YEL}
  get logs: $bin_name -l
  trash file: $bin_name <file> <file> ...
  restore file: $bin_name -r <file/folder name>
  restore to custom path: $bin_name -p <custom path> -r <file/folder name>
  empty trash: $bin_name -e <date|epoch|'now'> <up|down>
         $bin_name -e "2026-03-06 23:57:43" up    # deletes from set date up
         $bin_name -e "7 days ago" down           # deletes from set date down
${RST}
${BOLD}Documentation and examples:${YEL}
  Check out ${UL}https://github.com/Alpinine99/trashing-recovery-system.git${RST} for more.
EOF
}

err()  { printf '%sE - %s%s\n' "$RED" "$*" "$RST" >&2; }
warn() { printf '%sW - %s%s\n' "$YEL" "$*" "$RST" >&2; }
info() { printf '%sI - %s%s\n' "$GRN" "$*" "$RST"; }

TRASH=true
LOG=false
R_FILE=""
E_DATE=""
R_PATH=""
while getopts 'hlr:e:p:' opt; do
  case "$opt" in
    h) usage; exit 0;;
    l) LOG=true;;
    r) R_FILE=$OPTARG;;
    e) E_DATE=$OPTARG;;
    p) R_PATH=$OPTARG;;
    *) usage >&2; exit 1;;
  esac
  TRASH=false
done
shift $((OPTIND - 1))

BIN_PATH="$HOME/.local/.trash"
# Index of what is in the trash now, one entry per line: epoch<TAB>original path<TAB>trash path
LOG_FILE="$BIN_PATH/.trashing.log"
# Append-only history of everything that happened: trashed, restored, deleted
HIST_FILE="$BIN_PATH/.history.log"

fmt_date() { date -d "@$1" '+%Y-%m-%d %H:%M:%S'; }

# hist ACTION PATH [EPOCH]
hist() {
  printf '%s  %-9s %s\n' "$(fmt_date "${3:-$(date +%s)}")" "$1" "$2" >> "$HIST_FILE"
}

rand_id() { LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 15; }

# One-time conversion of the old "[date] path:trashpath" index to the epoch format.
migrate() {
  [ -f "$LOG_FILE" ] && grep -q '^\[' "$LOG_FILE" || return 0
  local re='^\[([^]]*)\] (.*):([^:]*)$'
  local tmp line d src trash ts hl
  tmp=$(mktemp "$BIN_PATH/.idx.XXXXXX") || return 1
  while IFS= read -r line; do
    if [[ $line =~ $re ]]; then
      d=${BASH_REMATCH[1]}; src=${BASH_REMATCH[2]}; trash=${BASH_REMATCH[3]}
      ts=$(date -d "$d" +%s 2>/dev/null) || ts=$(date +%s)
      hl=$(printf '%s  %-9s %s' "$(fmt_date "$ts")" TRASHED "$src")
      grep -qxF -- "$hl" "$HIST_FILE" 2>/dev/null || printf '%s\n' "$hl" >> "$HIST_FILE"
      src=${src%/}
      # items trashed by the old version have broken modes (440), make them usable again
      if [ -e "$trash" ] && [ ! -L "$trash" ]; then
        chmod -R u+rwX -- "$trash" 2>/dev/null
      fi
      printf '%s\t%s\t%s\n' "$ts" "$src" "$trash" >> "$tmp"
    else
      printf '%s\n' "$line" >> "$tmp"
    fi
  done < "$LOG_FILE"
  mv -- "$tmp" "$LOG_FILE"
  [ -f "$HIST_FILE" ] && LC_ALL=C sort -o "$HIST_FILE" "$HIST_FILE"
  return 0
}

trash() {
  mkdir -p "$BIN_PATH" && chmod 700 "$BIN_PATH" || { err "Cannot create $BIN_PATH"; return 1; }
  migrate
  local -a missing=()
  local failed=0 src dest shown now
  for src in "$@"; do
    if [ ! -e "$src" ] && [ ! -L "$src" ]; then
      missing+=("$src")
      continue
    fi
    src=$(realpath -s -- "$src")
    case "$src" in
      "$BIN_PATH"|"$BIN_PATH"/*) err "Refusing to trash the trash itself: $src"; failed=1; continue;;
    esac
    dest="$BIN_PATH/$(rand_id)"
    while [ -e "$dest" ]; do dest="$BIN_PATH/$(rand_id)"; done
    # mv keeps the original permissions, so nothing needs fixing on restore
    if mv -- "$src" "$dest"; then
      now=$(date +%s)
      shown=$src
      [ -d "$dest" ] && [ ! -L "$dest" ] && shown="$src/"
      printf '%s\t%s\t%s\n' "$now" "$src" "$dest" >> "$LOG_FILE"
      hist TRASHED "$shown" "$now"
    else
      err "Could not trash: $src"
      failed=1
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    printf '\a'
    err "missing: ${missing[*]}"
    return 1
  fi
  return $failed
}

log() {
  if [ ! -s "$HIST_FILE" ]; then
    warn "No logs available"
    return 0
  fi
  if [ -t 1 ]; then
    tac "$HIST_FILE" | less -FRX
  else
    tac "$HIST_FILE"
  fi
}

restore() {
  if [ ! -s "$LOG_FILE" ]; then
    warn "Nothing to restore, else confirm log file"
    return 0
  fi
  migrate

  local dest_dir=""
  if [ -n "$R_PATH" ]; then
    dest_dir=$(realpath -m -- "$R_PATH" 2>/dev/null)
    [ -z "$dest_dir" ] && err "Invalid recovery path!" && return 1
  fi

  local -a lines=()
  local ts src trash
  while IFS=$'\t' read -r ts src trash; do
    if [ "${src##*/}" = "$R_FILE" ] || [ "$src" = "$R_FILE" ]; then
      lines+=("$ts"$'\t'"$src"$'\t'"$trash")
    fi
  done < "$LOG_FILE"
  if [ ${#lines[@]} -eq 0 ]; then
    err "File '$R_FILE' not found, else confirm log file"
    return 1
  fi

  local pick=""
  if [ ${#lines[@]} -eq 1 ]; then
    pick=${lines[0]}
  else
    local -a labels=()
    local l
    for l in "${lines[@]}"; do
      IFS=$'\t' read -r ts src trash <<< "$l"
      labels+=("$(fmt_date "$ts")  $src")
    done
    PS3="Restore which one? "
    select label in "${labels[@]}"; do
      if [ -n "$label" ]; then
        pick=${lines[REPLY-1]}
        break
      fi
    done
    [ -z "$pick" ] && return 1
  fi

  IFS=$'\t' read -r ts src trash <<< "$pick"
  if [ ! -e "$trash" ] && [ ! -L "$trash" ]; then
    err "Trash copy is missing: $trash"
    return 1
  fi

  local name=${src##*/}
  local target_dir=${dest_dir:-${src%/*}}
  [ -z "$target_dir" ] && target_dir="/"
  if [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; then
    err "'$target_dir' conflicts, specify recovery path!"
    return 1
  fi
  if [ -e "$target_dir/$name" ] || [ -L "$target_dir/$name" ]; then
    err "'$target_dir/$name' already exists, specify recovery path!"
    return 1
  fi
  mkdir -p -- "$target_dir" || { err "Cannot create '$target_dir'"; return 1; }
  mv -- "$trash" "$target_dir/$name" || { err "Restore failed"; return 1; }

  # drop the restored entry from the index (matched by its unique trash path)
  local tmp
  tmp=$(mktemp "$BIN_PATH/.idx.XXXXXX")
  awk -F'\t' -v t="$trash" '$3 != t' "$LOG_FILE" > "$tmp"
  mv -- "$tmp" "$LOG_FILE"

  hist RESTORED "$target_dir/$name"
  info "Recovered to '$target_dir'"
  return 0
}

empty() {
  if [ ! -s "$LOG_FILE" ]; then
    warn "Nothing to clean!"
    return 0
  fi
  migrate

  local filter=${1:-down}
  case "$filter" in
    up|down) ;;
    *) err "Direction must be 'up' or 'down'"; return 1;;
  esac

  local now cutoff
  now=$(date +%s)
  if [ "$E_DATE" = "now" ]; then
    cutoff=$now
  elif [[ $E_DATE =~ ^[0-9]{9,}$ ]]; then
    cutoff=$E_DATE
  else
    cutoff=$(date -d "$E_DATE" +%s 2>/dev/null) || { err "Invalid date!"; return 1; }
  fi
  [ "$cutoff" -gt "$now" ] && err "Invalid date (future date)!" && return 1

  local tmp n=0 ts src trash hit
  tmp=$(mktemp "$BIN_PATH/.idx.XXXXXX") || return 1
  while IFS=$'\t' read -r ts src trash; do
    hit=false
    if [ "$E_DATE" = "now" ]; then
      hit=true
    elif [ "$filter" = "down" ] && [ "$ts" -le "$cutoff" ]; then
      hit=true
    elif [ "$filter" = "up" ] && [ "$ts" -ge "$cutoff" ]; then
      hit=true
    fi
    # only ever delete inside the trash folder, even if the index was edited by hand
    if $hit; then
      case "$trash" in
        "$BIN_PATH"/?*)
          if [ ! -L "$trash" ]; then chmod -R u+rwX -- "$trash" 2>/dev/null; fi
          rm -rf -- "$trash"
          hist DELETED "$src"
          ((n++))
          continue;;
      esac
    fi
    printf '%s\t%s\t%s\n' "$ts" "$src" "$trash" >> "$tmp"
  done < "$LOG_FILE"
  mv -- "$tmp" "$LOG_FILE"
  [ "$E_DATE" = "now" ] && rm -rf -- "${BIN_PATH:?}"/*
  info "$n files cleared in trash!"
  return 0
}

if $TRASH; then
  if [ $# -eq 0 ]; then
    err "Missing input!"
    usage
    exit 1
  fi
  trash "$@"
  exit $?
elif $LOG; then
  log
  exit 0
elif [ -n "$R_FILE" ]; then
  restore
  exit $?
elif [ -n "$E_DATE" ]; then
  empty "$@"
  exit $?
fi
