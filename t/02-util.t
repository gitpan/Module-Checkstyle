#!perl
use Test::More tests => 17;

BEGIN { use_ok('Module::Checkstyle::Util', qw(format_expected_err as_true as_numeric)); } # 1

is(format_expected_err(1,     2)    , q(Expected '1' but got '2')); # 2
is(format_expected_err(undef, 0)    , q(Expected '' but got '0')); # 3
is(format_expected_err("foo", "foo"), q(Expected 'foo' but got 'foo')); # 4

is(as_true('y')   , 1); # 5
is(as_true('yes') , 1); # 6
is(as_true('true'), 1); # 7
is(as_true('TrUe'), 1); # 8
is(as_true('n'),    0); # 9
is(as_true('nope'), 0); # 10
is(as_true(undef),  0); # 11
is(as_true(""),     0); # 12

is(as_numeric(undef), 0); # 13
is(as_numeric("0"),   0); # 14
is(as_numeric("foo"), 0); # 15
is(as_numeric("-2"), -2); # 16
is(as_numeric("10"), 10); # 17

1;