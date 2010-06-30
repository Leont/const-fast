package Const;

## no critic (RequireArgUnpacking, ProhibitAmpersandSigils, ProhibitAutomaticExportation)

use 5.008;
use strict;
use warnings FATAL => 'all';
use warnings::register;
use Scalar::Util qw/reftype/;
use Carp qw/croak carp/;
use Exporter 5.57 'import';
our @EXPORT = qw/Const/;

our $VERSION = '0.001';

sub _is_readonly {
	return &Internals::SvREADONLY($_[0]);
}

sub _make_clone {
	my $reftype = reftype $_[0];
	if ($reftype eq 'SCALAR') {
		$_[0] = \(my $foo = ${ $_[0] });
	}
	elsif ($reftype eq 'ARRAY') {
		$_[0] = [ @{ $_[0] } ];
	}
	elsif ($reftype eq 'HASH') {
		$_[0] = { %{ $_[0] } };
	}
	return;
}

sub _make_readonly {
	my (undef, @args) = @_;
	if (my $reftype = reftype $_[0]) {
		_make_clone($_[0]) if &Internals::SvREFCNT($_[0]) > 1;
		if ($reftype eq 'ARRAY') {
			_make_readonly($_) for @{ $_[0] };
		}
		elsif ($reftype eq 'HASH') {
			Internals::hv_clear_placeholders %{ $_[0] };
			_make_readonly($_) for values %{ $_[0] };
		}
		elsif ($reftype ne 'SCALAR' and warnings::enabled()) {
			carp 'Can\'t make all of this variable readonly';
		}
		&Internals::SvREADONLY($_[0], 1);
	}
	Internals::SvREADONLY($_[0], 1);
	return;
}

## no critic (ProhibitSubroutinePrototypes, ManyArgs)
sub Const(\[$@%]@) {
	my (undef, @args) = @_;
	if (_is_readonly($_[0])) {
		croak 'Attempt to reassign a readonly variable';
	}
	if (reftype $_[0] eq 'SCALAR') {
		croak 'No value for readonly ' if @args == 0;
		carp 'Too many arguments in Readonly assignment' if @args > 1;
		${ $_[0] } = $args[0];
	}
	elsif (reftype $_[0] eq 'ARRAY') {
		@{ $_[0] } = @args;
	}
	elsif (reftype $_[0] eq 'HASH') {
		%{ $_[0] } = @args;
	}
	else {
		croak 'Can\'t make variable readonly';
	}
	_make_readonly($_[0], @args);
	return;
}

1;    # End of Const

=head1 NAME

Const - The great new Const!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Const;

    my $foo = Const->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 Const

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-const at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Const>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT
 
You can find documentation for this module with the perldoc command.

    perldoc Const


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Const>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Const>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Const>

=item * Search CPAN

L<http://search.cpan.org/dist/Const/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Leon Timmermans.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
