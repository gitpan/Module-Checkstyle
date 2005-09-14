package Module::Checkstyle::Util;

use strict;
use warnings;

use Module::Checkstyle::Problem;

require Exporter;

our @ISA         = qw(Exporter);

our @EXPORT      = qw();
our @EXPORT_OK   = qw(format_expected_err make_problem as_true as_numeric);
our %EXPORT_TAGS = ( all     => [@EXPORT_OK],
                     problem => [qw(format_expected_err make_problem)],
                     args    => [qw(as_true as_numeric)],
                );

sub format_expected_err {
    my ($expected, $got) = @_;
    
    $expected = ref $expected || $expected;
    $got      = ref $got      || $got;

    $expected = q{} if !defined $expected;
    $got      = q{} if !defined $got;
    
    return qq(Expected '$expected' but got '$got');
}

sub make_problem {
    return Module::Checkstyle::Problem->new(@_);
}

sub as_true {
    my $value = shift;
    return 0 if !defined $value || !$value;
    return 1 if $value =~ m/^ y | yes | true | 1 $/xi;
    return 0;
}

sub as_numeric {
    my $value = shift;

    return 0       if !defined $value || !$value;
    return $value  if $value =~ /^\-?\d+$/;
    return 0;
}

1;
__END__

=head1 NAME

Module::Checkstyle::Util - Convenient functions for checks

=head1 SUBROUTINES

=over 4

=item format_expected_err ($expected, $got)

Return the string "Expected '$expected' but got '$got'" but with C<$expected> and C<$got> reduced to
the reftype if they are references.

=item make_problem ($severity, $message, $line, $file)

Creates a new C<Module::Checkstyle::Problem> object. See L<Module::Checkstyle::Problem> for more info.

=item as_true ($value)

Returns 1 if C<$value> is either "y", "yes", "true" or "1" not regarding case. All other value returns 0.

=item as_numeric ($value)    

Returns the numeric value given in C<$value> if it is integer-numeric with an optional minus-sign. All other values returns 0.

=back

=head1 SEE ALSO

L<Module::Checkstyle>

=cut

