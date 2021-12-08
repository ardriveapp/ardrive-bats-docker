#!/usr/bin/env bats

# Support lib
load '/home/node/packages/node_modules/bats-support/load.bash'
# File methods. DEPENDS on SUPPORT lib.
load '/home/node/packages/node_modules/bats-file/load.bash'

# Like a beforeAll. Runs before first test.
setup_file() {
    echo "##### setup_file once" >>/home/node/bats.log
}

# Like an afterAll. Runs after last test.
teardown_file() {
    echo "##### teardown_file once" >>/home/node/bats.log
}

# Like a beforeEach. Runs before every test.
setup() {
    # Test name counter
    INDEX=$((${BATS_TEST_NUMBER} - 1))
    # Here we write something each time this runs
    echo "##### setup start" >>/home/node/bats.log
    # Prints test
    echo "BATS_TEST_NAME:        ${BATS_TEST_NAME}" >>/home/node/bats.log
    # Full path to filename inside Docker
    echo "BATS_TEST_FILENAME:    ${BATS_TEST_FILENAME}" >>/home/node/bats.log
    # Full path to folder containing test file
    echo "BATS_TEST_DIRNAME:     ${BATS_TEST_DIRNAME}" >>/home/node/bats.log
    # An array of function names for each test case
    echo "BATS_TEST_NAMES:       ${BATS_TEST_NAMES[$INDEX]}" >>/home/node/bats.log
    # Description of current TC
    echo "BATS_TEST_DESCRIPTION: ${BATS_TEST_DESCRIPTION}" >>/home/node/bats.log
    # (1-based) index of the current test case in the test file
    echo "BATS_TEST_NUMBER:      ${BATS_TEST_NUMBER}" >>/home/node/bats.log
    # Where BATS store preprocessed files. Useful to check the code.
    echo "BATS_TMPDIR:           ${BATS_TMPDIR}" >>/home/node/bats.log
    # Here we create an ENV var pointing to current file dir
    # Notice how we redirect output to avoid polluting stdout stream
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    # And here we print previous varible to log.
    echo "${DIR}" >>/home/node/bats.log
    echo "##### setup end" >>/home/node/bats.log
}

# Like an afterEach. Runs after every test.
teardown() {
    echo -e "##### teardown ${BATS_TEST_NAME}\n" >>/home/node/bats.log
}

@test "example skip" {
    echo -e"    example skip" >>/home/node/bats.log
    #Skip command
    skip "skipped test message here"
    #this test loads an unexistant helper, but we skip before it fails
    load helper
    assert_equal 1 1

}

@test 'example File method assert_exist()' {
    echo -e"    example file method" >>/home/node/bats.log
    #Bats provides &3 file descriptor to ALWAYS print custom texts.
    echo 'this text always prints to console' >&3
    #Fails if file does not exist
    assert_exist /home/node/entry.sh
}
