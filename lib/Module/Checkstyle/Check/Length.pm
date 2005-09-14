package Module::Checkstyle::Check::Length;

use strict;
use warnings;

use Carp qw(croak);
use Readonly;

use Module::Checkstyle::Util qw(:args :problem);

use base qw(Module::Checkstyle::Check);

# The directives we provide
Readonly my $MAX_SUBROUTINE_LENGTH => 'max-subroutine-length';

sub register {
    return ('enter PPI::Statement::Sub' => \&handle_named_subroutine );
}

sub new {
    my ($class, $config) = @_;
    
    $class = ref $class || $class;
    my $self = bless { config => $config, }, $class;
    
    # Keep configuration local
    $self->{$MAX_SUBROUTINE_LENGTH} = as_numeric($config->get_directive($MAX_SUBROUTINE_LENGTH));

    return $self;
}

sub handle_named_subroutine {
    my ($self, $subroutine, $file) = @_;

    my @problems;

    if ($self->{$MAX_SUBROUTINE_LENGTH}) {
        my $block = $subroutine->block;
        if (defined $block) {
            my $first_line = $subroutine->location()->[0];
            my $last_line  = $block->last_element()->location()->[0];
            my $length = $last_line - $first_line;
            if ($length > $self->{$MAX_SUBROUTINE_LENGTH}) {
                my $name = $subroutine->name;
                push @problems, make_problem($self->{config}->get_severity($MAX_SUBROUTINE_LENGTH),
                                            qq(Subroutine '$name' is too long ($length)),
                                            $subroutine->location(),
                                            $file);
            }
        }
    }
    
    return @problems;
}

1;
__END__

=head1 NAME

Module::Checkstyle::Check::Length - Check length of subs, packages, blocks etc.

=head1 CONFIGURATION DIRECTIVES

=over 4

=item Named subroutine length

Checks that named subroutines doesn't exceed a specified length. Use I<max-subroutine-length> to specify the maximum number of lines a subroutine may be.

C<max-subroutine-length = 40>

=back

=begin PRIVATE

=head1 METHODS

=over 4

=item register

Called by C<Module::Checkstyle> to get events we respond to.

=item new ($config)

Creates a new C<Module::Checkstyle::Check::Length> object.

=item handle_named_subroutine ($subroutine, $file)

Called when we encounter a C<PPI::Statement::Sub> element.

=back

=end PRIVATE

=head1 SEE ALSO

Writing configuration files. L<Module::Checkstyle::Config/Format>

L<Module::Checkstyle>

=cut
