package Module::Checkstyle::Check::Subroutine;

use strict;
use warnings;

use Carp qw(croak);
use Readonly;

use Module::Checkstyle::Util qw(:args :problem);

use base qw(Module::Checkstyle::Check);

# The directives we provide
Readonly my $MATCHES_NAME => 'matches-name';
Readonly my $MAX_LENGTH   => 'max-length';
Readonly my $DISALLOW_FQN => 'disallow-fully-qualified-name';

sub register {
    return (
            'enter PPI::Statement::Sub' => \&handle_subroutine
        );
}

sub new {
    my ($class, $config) = @_;
    
    my $self = $class->SUPER::new($config);
    
    # Keep configuration local
    $self->{$MATCHES_NAME} = as_regexp($config->get_directive($MATCHES_NAME));
    $self->{$MAX_LENGTH}   = as_numeric($config->get_directive($MAX_LENGTH));
    $self->{$DISALLOW_FQN} = as_true($config->get_directive($DISALLOW_FQN));
    
    return $self;
}

sub handle_subroutine {
    my ($self, $subroutine, $file) = @_;

    my @problems;

    # Naming
    if ($self->{$MATCHES_NAME}) {
        my $name = $subroutine->name();
        if ($name && $name !~ $self->{$MATCHES_NAME}) {
            push @problems, make_problem(
                                         $self->{config}->get_severity($MATCHES_NAME),
                                         qq(Subroutine '$name' does not match '$self->{$MATCHES_NAME}'),
                                         $subroutine->location(),
                                         $file,
                                         );
        }
    }

    # Qualified names
    if ($self->{$DISALLOW_FQN}) {
        my $name = $subroutine->name();
        if ($name && $name =~ m{ :: | \' }x) {
            push @problems, make_problem(
                                         $self->{config}->get_severity($DISALLOW_FQN),
                                         qq(Subroutine '$name' is a fully qualified ),
                                         $subroutine->location(),
                                         $file,
                                     );
        }
    }
    
    # Length
    if ($self->{$MAX_LENGTH}) {
        my $block = $subroutine->block();
        # Forward declarations has no block hence no length to check
        if (defined $block) {
            my $first_line = $subroutine->location()->[0];
            my $last_line  = $block->last_element()->location()->[0];
            my $length = $last_line - $first_line;
            if ($length > $self->{$MAX_LENGTH}) {
                my $name = $subroutine->name();
                push @problems, make_problem(
                                             $self->{config}->get_severity($MAX_LENGTH),
                                             qq(Subroutine '$name' is too long ($length lines)),
                                             $subroutine->location(),
                                             $file,
                                         );
            }
        }
    }
    
    return @problems;
}

1;
__END__

=head1 NAME

Module::Checkstyle::Check::Subroutine - Checks length, naming etc. of named subroutines

=head1 CONFIGURATION DIRECTIVES

=over 4

=item Subroutine naming

Checks that a subroutine is named correctly. Use I<matches-name> to specify a regular expression that must match.

C<matches-name = qr/\w+/>

=item Subroutine length

Checks that named subroutines doesn't exceed a specified length. Use I<max-subroutine-length> to specify the maximum number of lines a subroutine may be.

C<max-length = 40>

=item Disallow fully qualified names

Checks if a subroutine is fully-qualified. That if it contains :: or '. Set I<disallow-fully-qualified-names> to a true value to enable.

C<disallow-fully-qualified-name = true>

=back

=begin PRIVATE

=head1 METHODS

=over 4

=item register

Called by C<Module::Checkstyle> to get events we respond to.

=item new ($config)

Creates a new C<Module::Checkstyle::Check::Length> object.

=item handle_subroutine ($subroutine, $file)

Called when we encounter a C<PPI::Statement::Sub> element.

=back

=end PRIVATE

=head1 SEE ALSO

Writing configuration files. L<Module::Checkstyle::Config/Format>

L<Module::Checkstyle>

=cut
