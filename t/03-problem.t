#!perl
use Test::More tests => 10;

BEGIN { use_ok( 'Module::Checkstyle::Problem' ); } # 1

my $problem = Module::Checkstyle::Problem->new('warn', 'message', 10, 'file.pl');
isa_ok($problem, 'Module::Checkstyle::Problem'); # 2

is($problem->get_severity(), 'warn');    # 3
is($problem->get_message(),  'message'); # 4
is($problem->get_line(),     10);        # 5
is($problem->get_file(),     'file.pl'); # 6

$problem = Module::Checkstyle::Problem->new('warn', 'message', [10, 0], 'file.pl');

is($problem->get_line(),     10);        # 7

$problem = $problem->new('warn', 'message', 10, 'file.pl');

my $err = "$problem";
is($err, '[WARN] message at line 10 in file.pl'); # 8

$problem = $problem->new();
isa_ok($problem, 'Module::Checkstyle::Problem'); # 9
$err = "$problem";
is($err, '');; # 10
