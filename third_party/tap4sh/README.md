# `tap4sh.sh`

[Test Anything Protocol](https://testanything.org/) library for POSIX
shells

https://github.com/rhansen/tap4sh

[![Build Status](https://travis-ci.org/rhansen/tap4sh.svg?branch=master)](https://travis-ci.org/rhansen/tap4sh)

## Features

  * [Test Anything Protocol
    v12](http://testanything.org/tap-specification.html) output
  * Conforms to [POSIX Issue 7
    TC1](http://pubs.opengroup.org/onlinepubs/9699919799/), so it
    should work with many shell implementations (bash, zsh, dash, ash,
    etc.) and associated utilities.
  * BSD 2-clause license
  * Available testcase types:
      - expected pass:  The usual pass case.
      - unexpected fail:  The usual fail case.
      - expected fail:  When something is known to be broken (e.g.,
        add a known-to-fail testcase before fixing a bug).
      - unexpected pass:  When something is known to be broken, but
        for some reason the test is passing.  (This usually happens
        immediately after fixing a bug but before the testcase has
        been changed to 'expected pass'.)
      - skip:  A prerequisite is unavailable so the test isn't even
        performed (e.g., Valgrind isn't installed so skip memory leak
        tests).
  * The `t4s_subtests()` function can be used to drive other TAP v12
    programs or shell functions.  Their results are merged into the
    script's test output stream.  Each subtest test description is
    prefixed with a (user-settable) string.
  * Tests can be configured to depend on other tests or user-supplied
    prerequisites:  If a dependency is not met, then any dependent
    tests are automatically skipped.
  * If a test script writes to standard error (stderr), the output is
    passed through to stderr unmodified.
  * If a test script writes to standard output (stdout), each line of
    the output is prefixed with `# ` to convert it to a TAP diagnostic
    line and then output to stdout.

## Caveats and Limitations

  * Testcases and subtests are run in a subshell, so any changes to
    variables, file descriptors, traps, etc. are lost when the
    testcase or subtest completes.
  * All function and variable names beginning with `t4s_` are reserved
    by this library.
  * `t4s_setup()` sets traps on `HUP`, `INT`, `TERM`, and `EXIT`.  If
    you need to run clean-up code on exit, you can use the
    `--exit-hook` argument to `t4s_setup()`.
  * `t4s_testcase()` and `t4s_subtests()` close file descriptors 3 and
    4 while running testcases and subtests because these file
    descriptors are used for internal purposes.  Testcases and
    subtests should feel free to use these file descriptors if
    desired, but they cannot be used to communicate outside the call
    to `t4s_testscase()` or `t4s_subtests()`.
  * Testcases must not write to or close file descriptor 9 as it is
    used to communicate a bailout message (see `t4s_bailout()`).
  * Standard output (stdout) is redirected in testcases and subtests,
    so any tests that require a terminal must provide their own
    pseudoterminal (pty).

## TODO

  * prefix all variables in `t4s_testcase()` and `t4s_subtests()` with
    `t4s_` to avoid collisions (user might set var/fn outside testcase
    and expect it to be usable inside a testcase)

## Available Functions

See each function's definition for usage details.

### Testing Functions

  * `t4s_setup()`:  Prepare to run testcases (required)
  * `t4s_done()`:  No more tests (required)
  * `t4s_bailout()`:  Abort the test script
  * `t4s_testcase()`:  Run a script as a testcase and output the
    results in TAP format
  * `t4s_testcase_diff()`:  Like `t4s_testcase()`, except rather than
    running a script it compares two files
  * `t4s_give()`:  Mark the named prerequisite(s) as having being met
    so that any testcase that uses `--needs` with the named
    prerequisite won't be skipped
  * `t4s_subtests()`:  Run a command that performs its own tests and
    integrate the results

### Helper Functions

  * `t4s_log()`, `t4s_debug()`, `t4s_warn()`, `t4s_error()`:  Logging
    functions
  * `t4s_fatal()`:  Log an error and exit non-zero
  * `t4s_try()`:  Run the given command and call `t4s_fatal()` if it
    returns non-zero
  * `t4s_usage_fatal()`:  Log an error, print the output of `usage()`
    to standard error, and exit non-zero
  * `t4s_pecho()`:  Portable echo
  * `t4s_esc()`:  Wrap each argument suitable for `eval`
  * `t4s_re_match()`:  Check if a string matches a regular expression
  * `t4s_discard_last_args()`:  Discard the last N positional
    arguments

## Example Test Script

```sh
#!/bin/sh

d=${0%/*}
. "${d}"/tap4sh.sh

t4s_setup "$@"

create_database || t4s_bailout "failed to prepare for tests"

t4s_testcase "basic addition" '
    [ $((1+1)) -eq 2 ]
'

t4s_testcase --xfail "waiting on mad scientist" --gives pigs_fly "pigs fly" '
    check_pigs_fly
'

t4s_testcase --needs pigs_fly "pigs carry > 20lbs" '
    launch_pig --weight 20lbs
'

my_subtests() {
    t4s_setup "$@"
    t4s_testcase "true returns 0" 'true'
    t4s_testcase "false returns non-zero" '!false'
    t4s_done
}

t4s_subtests my_subtests

t4s_done
```

The output of the above might look like this:

```
ok 1 basic addition
not ok 2 pigs fly # TODO waiting on mad scientist
ok 3 pigs carry > 20lbs # skip unsatisfied requirement: pigs_fly
ok 4 my_subtests: true returns 0
ok 5 my_subtests: false returns non-zero
1..5
```
