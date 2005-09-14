package Module::Checkstyle::Check::Whitespace;

use strict;
use warnings;

use Carp qw(croak);
use Readonly;

use Module::Checkstyle::Util qw(:problem :args);

use base qw(Module::Checkstyle::Check);

# The directives we provide
Readonly my $AFTER_COMMA        => 'after-comma';
Readonly my $BEFORE_COMMA       => 'before-comma';
Readonly my $AFTER_FAT_COMMA    => 'after-fat-comma';
Readonly my $BEFORE_FAT_COMMA   => 'before-fat-comma';

sub register {
    return ('PPI::Token::Operator' => \&handle_operator );
}

sub new {
    my ($class, $config) = @_;
    
    $class = ref $class || $class;
    my $self = bless { config             => $config,
                  }, $class;
    
    # Keep configuration local
    foreach ($AFTER_COMMA, $BEFORE_COMMA, $AFTER_FAT_COMMA, $BEFORE_FAT_COMMA) {
        $self->{$_} = as_true($config->get_directive($_));
    }

    return $self;
}

sub handle_operator {
    my ($self, $operator, $file) = @_;

    my @problems;

    if ($operator->content() eq ',') {
        if ($self->{$AFTER_COMMA}) {
            # Next sibling should be whitespace
            my $sibling = $operator->next_sibling();
            if (!defined $sibling || !$sibling->isa('PPI::Token::Whitespace')) {
                push @problems, make_problem($self->{config}->get_severity($AFTER_COMMA),
                                             qq(Missing whitespace after comma (,)),
                                             $operator->location,
                                             $file);
            }
        }

        if ($self->{$BEFORE_COMMA}) {
            # Previous sibling should be whitespace
            my $sibling = $operator->previous_sibling();
            if (!defined $sibling || !$sibling->isa('PPI::Token::Whitespace')) {
                push @problems, make_problem($self->{config}->get_severity($BEFORE_COMMA),
                                             qq(Missing whitespace before comma (,)),
                                             $operator->location,
                                             $file);
            }
        }
    }

    if ($operator->content() eq '=>') {
        if ($self->{$AFTER_FAT_COMMA}) {
            # Next sibling should be whitespace
            my $sibling = $operator->next_sibling();
            if (!defined $sibling || !$sibling->isa('PPI::Token::Whitespace')) {
                push @problems, make_problem($self->{config}->get_severity($AFTER_FAT_COMMA),
                                             qq(Missing whitespace after fat comma (=>)),
                                             $operator->location,
                                             $file);
            }
        }

        if ($self->{$BEFORE_FAT_COMMA}) {
            # Previous sibling should be whitespace
            my $sibling = $operator->previous_sibling();
            if (!defined $sibling || !$sibling->isa('PPI::Token::Whitespace')) {
                push @problems, make_problem($self->{config}->get_severity($BEFORE_FAT_COMMA),
                                             qq(Missing whitespace before fat comma (=>)),
                                             $operator->location,
                                             $file);
            }
        }
    }
    
    return @problems;
}

1;
__END__

=head1 NAME

Module::Checkstyle::Check::Whitespace - Make sure whitespace is at correct places

=head1 CONFIGURATION DIRECTIVES

=over 4

=item Whitespace after comma

Checks that there is whitespace after a comma, for example as in C<my ($foo, $bar);>. Enable it by setting I<after-comma> to true.

C<after-comma = true>

=item Whitespace before comma

Checks that there is whitespace before a comma, for example as in C<my ($foo ,$bar);>. Enable it by setting I<before-comma> to 1.

C<before-comma = true>

=item Whitespace after fat comma

Checks that there is whitespace after a fat comma (=E<gt>), for example as in C<call(arg=E<gt> 1)>. Enable it by setting I<after-fat-comma> to true.

C<after-fat-comma = true>

=item Whitespace before fat comma

Checks that there is whitespace before a fat comma (=E<gt>), for example as in C<call(arg =E<gt>1)>. Enable it by setting I<before-fat-comma> to true.

C<before-fat-comma = true>

=back

=begin PRIVATE

=head1 METHODS

=over 4

=item register

Called by C<Module::Checkstyle> to get events we respond to.

=item new ($config)

Creates a new C<Module::Checkstyle::Check::Package> object.

=item handle_operator ($operator, $file)

Called when we encounter a C<PPI::Token::Operator> element.

=item handle_word ($word, $file)

Called when we encounter a C<PPI::Token::Word> element.

=back

=end PRIVATE

=head1 SEE ALSO

Writing configuration files. L<Module::Checkstyle::Config/Format>

L<Module::Checkstyle>

=cut
