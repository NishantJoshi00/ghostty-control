# shellcheck shell=sh

Describe 'regression: live bugs previously encountered'
  BeforeEach 'gt_live_setup'
  AfterEach 'gt_live_cleanup'

  It 'gt-close closes gracefully without typing exit, avoiding exit~ and xit'
    id=$(gt_live_open 'gt: test regression close')

    close_json=$(gt_live_close "$id")
    printf '%s\n' "$close_json" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["closed"] is True and d["method"] == "graceful"'

    When call gt gt-status "$id" --json
    The status should eq 1
    The output should include '"exists":false'
  End

  It 'status JSON keeps the terminal id exact instead of packing tab-delimited fields into id'
    id=$(gt_live_open 'gt: test regression status-delimiter')

    When call gt_assert_status_and_list_exact_id "$id"
    The status should eq 0
  End

  It 'gt-close --json avoids zsh read-only status variable collisions'
    id=$(gt_live_open 'gt: test regression status-var')

    When call gt_live_close "$id"
    The status should eq 0
    The output should include '"status":"closed"'
    The error should not include 'read-only variable: status'
  End

  It 'gt-open default readiness supports immediate gt-run without dropped input'
    id=$(gt_live_open 'gt: test regression ready')

    When call gt gt-run "$id" 'printf ready-race-ok' --timeout 15 --json
    The status should eq 0
    The output should include '"ok":true'
    The output should include 'ready-race-ok'
  End

End
