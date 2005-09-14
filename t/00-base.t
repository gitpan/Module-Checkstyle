#!perl
use Test::More tests => 23;

BEGIN { use_ok( 'Module::Checkstyle' ); } # 1

diag( "Testing Module::Checkstyle $Module::Checkstyle::VERSION" );

# Check that loading of checks works
{
    my $config = <<'END_OF_CONFIG';
[Package]
is-first-statement = 1
END_OF_CONFIG
    
    my $cs = Module::Checkstyle->new(\$config);
    isa_ok($cs, 'Module::Checkstyle'); # 2
    
    ok(exists $cs->{handlers}->{'enter PPI::Document'}); # 3
    ok(exists $cs->{handlers}->{'PPI::Statement::Package'}); # 4
    ok(exists $cs->{handlers}->{'leave PPI::Document'}); # 5

    is(scalar @{$cs->{handlers}->{'PPI::Statement::Package'}}     , 1); # 6
    is(scalar @{$cs->{handlers}->{'PPI::Statement::Package'}->[0]}, 2); # 7
    isa_ok($cs->{handlers}->{'PPI::Statement::Package'}->[0]->[0], 'Module::Checkstyle::Check::Package'); # 8
}

{
    ok(Module::Checkstyle::_any_match("bar", [qr/foo/, qr/bar/, qr/baz/])); # 9
}

# Check that finding files works
{
    my @files = Module::Checkstyle::_get_files('.', 1);
    is(scalar @files, 10); # 10
}

# Check _post_event and _traverse_document
{
    my $cs = Module::Checkstyle->new(\<<'END_OF_CONFIG');
[Test00base1]
END_OF_CONFIG

    $cs->_post_event('enter PPI::Statement::Sub', 1);
    $cs->_post_event('PPI::Token::Symbol',        2);
    $cs->_post_event('leave PPI::Statement::Sub', 3);

    my @problems = $cs->get_problems();
    is(scalar @problems, 3); # 11
    is(shift @problems, 1); # 12
    is(shift @problems, 2); # 13
    is(shift @problems, 3); # 14

    @problems = $cs->flush_problems();
    is(scalar @problems, 3); # 15
    @problems = $cs->get_problems();
    is(scalar @problems, 0); # 16

    my $doc = PPI::Document->new(\<<'END_OF_CODE');
sub enter {
    $x++;
}
END_OF_CODE

    $cs->_traverse_element($doc, "");

    @problems = $cs->get_problems();
    is(scalar @problems, 3); # 17
    is(ref shift @problems, 'PPI::Statement::Sub'); # 18
    is(ref shift @problems, 'PPI::Token::Symbol' ); # 19
    is(ref shift @problems, 'PPI::Statement::Sub'); # 20
}

{
    my $cs = Module::Checkstyle->new(\<<'END_OF_CONFIG');
[Test00base2]
END_OF_CONFIG

    is($cs->check('.'), 9); # 21

    $cs->flush_problems();
    is($cs->check('t/00-base.t'), 1); # 22

    $cs->flush_problems();
    is($cs->check('t', { ignore_common => 0 }), 9); # 23
}

package Module::Checkstyle::Check::Test00base1;

use base qw(Module::Checkstyle::Check);

sub register {
    return ('enter PPI::Statement::Sub' => sub { return $_[1]; },
            'PPI::Token::Symbol'        => sub { return $_[1]; },
            'leave PPI::Statement::Sub' => sub { return $_[1]; },
        );
}

package Module::Checkstyle::Check::Test00base2;

use base qw(Module::Checkstyle::Check);

sub register {
    return ('enter PPI::Document' => sub { return $_[2]; });
}

1;
