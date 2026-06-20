# shellcheck shell=sh

GT_TEST_ROOT="${SHELLSPEC_PROJECT_ROOT:-$PWD}"
GT_LIVE_IDS=""

gt_script() {
  printf '%s/scripts/%s\n' "$GT_TEST_ROOT" "$1"
}

gt() {
  name="$1"
  shift
  "$GT_TEST_ROOT/scripts/$name" "$@"
}

gt_json_field() {
  python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"
}

gt_json_assert() {
  python3 -c "$1"
}

gt_live_setup() {
  GT_LIVE_IDS=""
  export GT_LIVE_IDS
}

gt_live_cleanup() {
  for id in $GT_LIVE_IDS; do
    "$GT_TEST_ROOT/scripts/gt-close" "$id" --force >/dev/null 2>&1 || true
  done
  GT_LIVE_IDS=""
}

gt_live_track() {
  GT_LIVE_IDS="$GT_LIVE_IDS $1"
  export GT_LIVE_IDS
}

gt_live_untrack() {
  remove="$1"
  next=""
  for id in $GT_LIVE_IDS; do
    [ "$id" = "$remove" ] || next="$next $id"
  done
  GT_LIVE_IDS="$next"
  export GT_LIVE_IDS
}

gt_live_open() {
  name="$1"
  id=$("$GT_TEST_ROOT/scripts/gt-open" --cwd "$GT_TEST_ROOT" --name "$name")
  gt_live_track "$id"
  printf '%s\n' "$id"
}

gt_live_close() {
  id="$1"
  "$GT_TEST_ROOT/scripts/gt-close" "$id" --json
  rc=$?
  [ "$rc" -eq 0 ] && gt_live_untrack "$id"
  return "$rc"
}

gt_require_live_ghostty() {
  "$GT_TEST_ROOT/scripts/gt-probe" >/dev/null 2>&1
}

gt_grep_character_id_9() {
  grep -F 'character id 9' "$GT_TEST_ROOT/scripts/gt-status" "$GT_TEST_ROOT/scripts/gt-list"
}

gt_assert_status_and_list_exact_id() {
  id="$1"
  status_json=$(gt gt-status "$id" --json)
  list_json=$(gt gt-list --json)
  GT_EXPECTED_ID="$id" python3 -c '
import json
import os
import sys

status = json.loads(sys.argv[1])
listing = json.loads(sys.argv[2])
expected = os.environ["GT_EXPECTED_ID"]

assert status["exists"] is True
assert status["id"] == expected
assert status["window_id"]
assert status["tab_id"]

matches = [t for t in listing["terminals"] if t["id"] == expected]
assert matches
assert matches[0]["window_id"]
assert matches[0]["tab_id"]
' "$status_json" "$list_json"
}
