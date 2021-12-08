#!/usr/bin/env bats

@test "example status and output lines" {
    #Execute external script
    #run ./status.sh --> WRONG
    #This test will fail if ran outisde this directory for being relative.

    #Instead we could use absolute path directly OR
    #We fetch current test file dir absolute path redirecting stdout.
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    #We run command using DIR as Absolute Path
    run $DIR/status.sh

    #check stdout
    [ "${status}" -eq 1 ]
    [ "${output}" = "foobar" ]
    [ "${lines[0]}" = "foobar" ]
}
