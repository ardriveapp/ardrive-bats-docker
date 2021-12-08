#!/usr/bin/env bats


@test "example load" {
    #load helper.bash under dame path
    load helper
    #cast helper function
    assert_equal 1 1
}
