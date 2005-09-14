#!perl
use Test::More tests => 4;

BEGIN { use_ok('Module::Checkstyle::Check::Length'); } # 1

use strict;
use PPI;
use Module::Checkstyle::Config;

# max-subroutine-length
{
    my $checker = Module::Checkstyle::Check::Length->new(Module::Checkstyle::Config->new(\<<'END_OF_CONFIG'));
[Length]
max-subroutine-length = 3
END_OF_CONFIG
    
    my $doc = PPI::Document->new(\<<'END_OF_CODE');
sub my_sub_fail {
    # This should
    # make the
    # subroutine
    # just a bit
    # too long
}

sub my_sub_pass {
    # This should pass
}
END_OF_CODE

    # Normally index_locations is called by Module::Checkstyle
    # when it loads a document but since we're loading
    # documents directlly here we have to do it manually
    $doc->index_locations();

    my $tokens = $doc->find('PPI::Statement::Sub');
    is(scalar @$tokens, 2); # 2
    my $token = shift @$tokens;

    my @problems = $checker->handle_named_subroutine($token);
    is(scalar @problems, 1); # 3

    $token = shift @$tokens;
    @problems = $checker->handle_named_subroutine($token);
    is(scalar @problems, 0); # 4
}
