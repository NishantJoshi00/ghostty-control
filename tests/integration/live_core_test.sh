# shellcheck shell=sh

Describe 'integration: live Ghostty command flow'
  BeforeEach 'gt_live_setup'
  AfterEach 'gt_live_cleanup'

  It 'opens, runs, waits, reads, and closes a real terminal'
    id=$(gt_live_open 'gt: test integration core')

    run_json=$(gt gt-run "$id" 'printf integration-ok' --timeout 15 --json)
    printf '%s\n' "$run_json" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["ok"] is True and d["exit_code"] == 0 and "integration-ok" in d["screen"]'

    wait_json=$(gt gt-wait "$id" --for integration-ok --timeout 5 --json)
    printf '%s\n' "$wait_json" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["ok"] is True and d["matched"] is True'

    screen_json=$(gt gt-screen "$id" --json)
    printf '%s\n' "$screen_json" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["ok"] is True and "integration-ok" in d["text"]'

    When call gt_live_close "$id"
    The status should eq 0
    The output should include '"closed":true'
  End

  It 'creates a split workspace and runs commands in both panes'
    root=$(gt_live_open 'gt: test integration workspace')

    split_json=$(gt gt-split "$root" right --cmd 'printf split-pane' --title 'gt: test split pane' --json)
    split=$(printf '%s\n' "$split_json" | gt_json_field id)
    gt_live_track "$split"

    split_screen=$(gt gt-screen "$split" --json)
    printf '%s\n' "$split_screen" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["ok"] is True and "split-pane" in d["text"]'

    focus_result=$(gt gt-focus "$root")
    [ "$focus_result" = "$root" ] || return 1

    run_json=$(gt gt-run "$root" 'printf root-pane' --timeout 15 --json)
    printf '%s\n' "$run_json" | gt_json_assert 'import json,sys; d=json.load(sys.stdin); assert d["ok"] is True and "root-pane" in d["screen"]'

    When call gt_live_close "$split"
    The status should eq 0
    The output should include '"closed":true'
  End

  It 'preserves non-zero command exit code in gt-run --json'
    id=$(gt_live_open 'gt: test integration exit')

    When call gt gt-run "$id" 'false' --timeout 15 --json
    The status should eq 1
    The output should include '"ok":false'
    The output should include '"exit_code":1'
  End
End
