# shellcheck shell=sh

Describe 'unit: command contracts against real Ghostty'
  BeforeEach 'gt_live_setup'
  AfterEach 'gt_live_cleanup'

  It 'gt-probe returns parseable readiness JSON'
    When call gt gt-probe --json
    The status should eq 0
    The output should include '"ok":true'
    The output should include '"backend":"applescript"'
  End

  It 'gt-open --json returns a live terminal id'
    open_json=$(gt gt-open --cwd "$GT_TEST_ROOT" --name 'gt: test unit open' --json)
    id=$(printf '%s\n' "$open_json" | gt_json_field id)
    gt_live_track "$id"

    When call gt gt-status "$id" --json
    The status should eq 0
    The output should include '"exists":true'
    The output should include "\"id\":\"$id\""
  End

  It 'gt-list --json includes a newly opened terminal'
    id=$(gt_live_open 'gt: test unit list')

    When call gt gt-list --json
    The status should eq 0
    The output should include "\"id\":\"$id\""
  End
End
