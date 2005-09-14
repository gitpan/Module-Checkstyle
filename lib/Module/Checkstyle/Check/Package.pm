package Module::Checkstyle::Check::Package;

use strict;
use warnings;

use Carp qw(croak);
use File::Spec::Functions qw(splitpath);
use Readonly;

use Module::Checkstyle::Util qw(:problem :args);

use base qw(Module::Checkstyle::Check);

# The directives we provide
Readonly my $PACKAGE_MATCHES_NAME     => 'matches-name';
Readonly my $MAX_PACKAGES_PER_FILE    => 'max-per-file';
Readonly my $PACKAGE_COMES_FIRST      => 'is-first-statement';
Readonly my $PACKAGE_MATCHES_FILENAME => 'has-matching-filename';

sub register {
    return ('enter PPI::Document'     => \&begin_document,
            'leave PPI::Document'     => \&end_document,
            'PPI::Statement::Package' => \&handle_package,
        );
}

sub new {
    my ($class, $config) = @_;
    
    $class = ref $class || $class;
    my $self = bless { config                    => $config,
                       packages                  => [],
                       document                  => undef,
                       $PACKAGE_MATCHES_NAME     => undef,
                       $MAX_PACKAGES_PER_FILE    => 0,
                  }, $class;
    
    # Keep configuration local
    if (my $matches_name = $config->get_directive($PACKAGE_MATCHES_NAME)) {
        $self->{$PACKAGE_MATCHES_NAME} = qr/$matches_name/;
    }
    
    $self->{$MAX_PACKAGES_PER_FILE} = as_numeric($config->get_directive($MAX_PACKAGES_PER_FILE)) || 0;

    foreach ($PACKAGE_COMES_FIRST, $PACKAGE_MATCHES_FILENAME) {
        $self->{$_} = as_true($config->get_directive($_));
    }
    
    return $self;
}

sub begin_document {
    my ($self, $document, $file) = @_;

    $self->{count} = 0;
    
    my @problems;
    
    # Check first statement ignoring whitespace, comments and pod
    if ($self->{$PACKAGE_COMES_FIRST}) {
        my @children = $document->schildren;
        my $statement = shift @children;
        if (!defined $statement || !$statement->isa('PPI::Statement::Package')) {
            push @problems, make_problem($self->{config}->get_severity($PACKAGE_COMES_FIRST),
                                         qq(First statement is not a package declaration),
                                         defined $statement ? $statement->location : undef,
                                         $file);
        }
    }
    
    return @problems;
}

sub handle_package {
    my ($self, $package, $file) = @_;
    
    if (!$package->isa('PPI::Statement::Package')) {
        croak format_expected_err('PPI::Statement::Package', $package);
    }
    
    my @problems;
    
    my $namespace = $package->namespace;
    
    # Check naming
    if ($namespace && $self->{$PACKAGE_MATCHES_NAME}) {
        if ($namespace !~ $self->{$PACKAGE_MATCHES_NAME}) {
            push @problems, make_problem($self->{config}->get_severity($PACKAGE_MATCHES_NAME),
                                         qq(The package name '$namespace' does not match '$self->{$PACKAGE_MATCHES_NAME}'),
                                         $package->location,
                                         $file);
        }
    }
    
    # Check count
    if ($self->{$MAX_PACKAGES_PER_FILE}) {
        $self->{count}++;
        if ($self->{count} > $self->{$MAX_PACKAGES_PER_FILE}) {
            my $err = qq(The declration 'package $namespace;' exceeds the maximum number of ($self->{$MAX_PACKAGES_PER_FILE}) packages per file);
            push @problems, make_problem($self->{config}->get_severity($MAX_PACKAGES_PER_FILE),
                                         $err,
                                         $package->location,
                                         $file);
        }
    }
    
    push @{$self->{packages}}, $namespace if $namespace;
    
    return @problems;
}

sub end_document {
    my ($self, $document, $file) = @_;
    my @problems;

    # Check that we have a package that matches the path if it's a module
    if ($self->{$PACKAGE_MATCHES_FILENAME} && $file) {
        if ($file =~ /\.pm$/) {
            my $ok_filename = 0;
          CHECK_PACKAGES:
            while (my $package = shift @{$self->{packages}}) {
                my $fake_file = File::Spec->catfile(split/\:\:/,$package) . ".pm";
                my $real_file = substr($file, -length($fake_file));
                if ($real_file eq $fake_file) {
                    $ok_filename = 1;
                    last CHECK_PACKAGES;
                }
            }
            
            if (!$ok_filename) {
                my $err = qq(The file '$file' does not seem to contain a package matching the filename);
                push @problems, make_problem($self->{config}->get_severity($PACKAGE_MATCHES_FILENAME),
                                             $err,
                                             undef,
                                             $file);
            }
        }
    }


    
    # Clean up
    delete $self->{packages};
    
    return @problems;
}

1;
__END__

=head1 NAME

Module::Checkstyle::Check::Package - Handles 'package' declarations

=head1 CONFIGURATION DIRECTIVES

=over 4

=item Package naming

Checks that your package is named correctly. Use I<matches-name> to
declare a regular expression that must match.

C<matches-name = /^\w+(\:\:\w+)*$/>

=item Max packages in single file

Checks that you only declare a specified number of packages in a
single source file. Use I<max-per-file> to set the maximum
number of C<package>-statements allowed. You usually want this to be
set to 1.

C<max-per-file = 1>

=item Package declaration is first statement

Checks that the the first significantstatement in a file is a C<package>-declaration.
Enable by setting I<package-comes-first> to true. This
test is only enabled if the parsed file ends with C<.pm>

C<is-first-statement = true>

=item Package in file matches filename

Checks that at least one package in the given file matches the name
of the file. That is if  the file is named lib/Module/Checkstyle.pm it
must declare Module::Checkstyle as a package in the file. Enable by setting 
I<has-matching-filename> to true.

C<has-matching-filename = true>

=back

=begin PRIVATE

=head1 METHODS

=over 4

=item register

Called by C<Module::Checkstyle> to get events we respond to.

=item new ($config)

Creates a new C<Module::Checkstyle::Check::Package> object.

=item begin_document ($document, $file)

Called when we enter a C<PPI::Document>.

=item handle_package ($package, $file)

Called when we encounter a C<PPI::Statement::Package> element.

=item end_document ($document, $file)

Called when we leave a C<PPI::Document>.

=back

=end PRIVATE

=head1 SEE ALSO

Writing configuration files. L<Module::Checkstyle::Config/Format>

L<Module::Checkstyle>

=cut
