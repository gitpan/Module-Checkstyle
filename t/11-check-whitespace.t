#!perl
use Test::More tests => 31;

BEGIN { use_ok('Module::Checkstyle::Check::Whitespace'); } # 2

use strict;
use PPI;
use Module::Checkstyle::Config;

# after-comma
{
    my $checker = Module::Checkstyle::Check::Whitespace->new(Module::Checkstyle::Config->new(\<<'END_OF_CONFIG'));
[Whitespace]
after-comma = true
END_OF_CONFIG
    
    my $doc = PPI::Document->new(\<<'END_OF_CODE');
my ($x, $y, $z);
call($x, $y, $z);
END_OF_CODE

    my $tokens = $doc->find('PPI::Token::Operator');
    is(scalar @$tokens, 4); # 2
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 0); # 3, 4, 5, 6
    }

    $doc = PPI::Document->new(\<<'END_OF_CODE');
my ($x,$y,$z);
call($x,$y,$z);
END_OF_CODE

    $tokens = $doc->find('PPI::Token::Operator');
    is(scalar @$tokens, 4); # 7
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 1); # 8, 9, 10, 11
    }
}

# after-comma
{
    my $checker = Module::Checkstyle::Check::Whitespace->new(Module::Checkstyle::Config->new(\<<'END_OF_CONFIG'));
[Whitespace]
before-comma = true
END_OF_CONFIG
    
    my $doc = PPI::Document->new(\<<'END_OF_CODE');
my ($x ,$y ,$z);
call($x ,$y ,$z);
END_OF_CODE

    my $tokens = $doc->find('PPI::Token::Operator');
    is(scalar @$tokens, 4); # 12
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 0); # 13, 14, 15, 16
    }

    $doc = PPI::Document->new(\<<'END_OF_CODE');
my ($x,$y,$z);
call($x,$y,$z);
END_OF_CODE

    $tokens = $doc->find('PPI::Token::Operator');
    is(scalar @$tokens, 4); # 17
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 1); # 18, 19, 20, 21
    }
}

# after-fat-comma
{
    my $checker = Module::Checkstyle::Check::Whitespace->new(Module::Checkstyle::Config->new(\<<'END_OF_CONFIG'));
[Whitespace]
after-fat-comma = true
END_OF_CONFIG
    
    my $doc = PPI::Document->new(\<<'END_OF_CODE');
my %args = (foo=> 1, bar=> 2);
call(foo=> $bar, bar=> $baz);
END_OF_CODE

    my $tokens = $doc->find('PPI::Token::Operator');
    @$tokens = grep { $_->content eq '=>' } @$tokens; # Ignore other than =>
    is(scalar @$tokens, 4); # 22
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 0); # 23, 24, 25, 26
    }

    $doc = PPI::Document->new(\<<'END_OF_CODE');
my %args = (foo=>1, bar=>2);
call(foo=>$bar, bar=>$baz);
END_OF_CODE

    $tokens = $doc->find('PPI::Token::Operator');
    @$tokens = grep { $_->content eq '=>' } @$tokens; # Ignore other than =>
    is(scalar @$tokens, 4); # 27
    foreach my $token (@$tokens) {
        my @problems = $checker->handle_operator($token);
        is(scalar @problems, 1); # 28, 29, 30, 31
    }
}


# Handle_package with wrong args
#{
    #     eval {
#         my $problems = $checker->handle_package(bless {}, 'MyModule');
#         fail('Called handle_package with wrong argument'); # 22
#     };
#     if($@) {
#         like($@, qr(^Expected 'PPI::Statement::Package' but got 'MyModule' at)); # 22
#     }
#}

1;

__DATA__
global-error-level    = WARN

[Whitespace]
after-comma      = true
before-comma     = true
after-fat-comma  = true
before-fat-comma = true
after-keyword    = true
