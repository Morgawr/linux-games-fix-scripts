#!/usr/bin/env bash
set -euo pipefail

# Ed3_win.exe palette fix:
# Remove the branch at VA 0x434259 / file offset 0x34259 that skips
# IDirectDraw::CreatePalette() when the desktop is not a paletted device.

OFFSET=$((0x34259))
LENGTH=6
ORIGINAL_HEX="0f847e010000"
PATCHED_HEX="909090909090"

usage() {
  cat <<'EOF' >&2
Usage:
  patch.sh [path-to-Ed3_win.exe]
  patch.sh --restore [path-to-Ed3_win.exe]

Defaults to:
  falcom_0002/ED3_XP/Ed3_win.exe
EOF
  exit 1
}

read_hex() {
  local file=$1
  od -An -tx1 -j "$OFFSET" -N "$LENGTH" -- "$file" | tr -d ' \n'
}

write_hex() {
  local file=$1
  local hex=$2
  local escaped=""
  local i

  for ((i = 0; i < ${#hex}; i += 2)); do
    escaped+="\\x${hex:i:2}"
  done

  # shellcheck disable=SC2059
  printf '%b' "$escaped" | dd of="$file" bs=1 seek="$OFFSET" conv=notrunc status=none
}

mode="patch"
if [[ "${1:-}" == "--restore" ]]; then
  mode="restore"
  shift
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

if [[ $# -gt 1 ]]; then
  usage
fi

target="${1:-falcom_0002/ED3_XP/Ed3_win.exe}"
backup="${target}.palette_fix_backup"

if [[ ! -f "$target" ]]; then
  echo "error: file not found: $target" >&2
  exit 1
fi

current_hex=$(read_hex "$target")

if [[ "$mode" == "patch" ]]; then
  if [[ "$current_hex" == "$PATCHED_HEX" ]]; then
    echo "already patched: $target"
    exit 0
  fi

  if [[ "$current_hex" != "$ORIGINAL_HEX" ]]; then
    echo "error: unexpected bytes at offset 0x34259: $current_hex" >&2
    echo "expected original bytes: $ORIGINAL_HEX" >&2
    exit 1
  fi

  if [[ ! -e "$backup" ]]; then
    cp -p -- "$target" "$backup"
    echo "backup created: $backup"
  fi

  write_hex "$target" "$PATCHED_HEX"

  if [[ "$(read_hex "$target")" != "$PATCHED_HEX" ]]; then
    echo "error: patch verification failed" >&2
    exit 1
  fi

  echo "patched: $target"
  echo "changed bytes at 0x34259 from $ORIGINAL_HEX to $PATCHED_HEX"
  exit 0
fi

if [[ "$current_hex" == "$ORIGINAL_HEX" ]]; then
  echo "already restored: $target"
  exit 0
fi

if [[ "$current_hex" != "$PATCHED_HEX" ]]; then
  echo "error: unexpected bytes at offset 0x34259: $current_hex" >&2
  echo "expected patched bytes: $PATCHED_HEX" >&2
  exit 1
fi

write_hex "$target" "$ORIGINAL_HEX"

if [[ "$(read_hex "$target")" != "$ORIGINAL_HEX" ]]; then
  echo "error: restore verification failed" >&2
  exit 1
fi

echo "restored: $target"
echo "changed bytes at 0x34259 from $PATCHED_HEX to $ORIGINAL_HEX"
