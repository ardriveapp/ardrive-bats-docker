#!/usr/bin/env bats

# Support lib
load '/home/node/packages/node_modules/bats-support/load.bash'
# File methods. DEPENDS on SUPPORT lib.
load '/home/node/packages/node_modules/bats-file/load.bash'
# Assertions
load '/home/node/packages/node_modules/bats-assert/load.bash'

@test "example support lib fail()" {
    #Display an error message and fail
    #Useful to fail when we do not reach expected state.
    fail 'this test always fails here'
}

@test 'example File method assert_exist()' {
    #Fails if file does not exist
    assert_exist /home/node/entry.sh
}

@test 'example Assert method assert_success()' {
    #Fails if $status is not 0.
    #We need to use bash -c to wrap compound commands.
    run bash -c "echo 'Error!'; echo 'Pass!'"
    assert_success
}
