package Const::Fast;

use 5.008;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw/reftype/;
use Carp qw/croak/;
use Sub::Exporter -setup => { exports => [qw/const/], groups => { default => [qw/const/] } };

our $VERSION = '0.004';

## no critic (RequireArgUnpacking, ProhibitAmpersandSigils)
# The use of $_[0] is deliberate and essential, to be able to use it as an lvalue and to keep the refcount down.

sub _make_readonly {
	my (undef, $dont_clone) = @_;
	if (my $reftype = reftype $_[0] and not &Internals::SvREADONLY($_[0])) {
		my $needs_cloning = !$dont_clone && &Internals::SvREFCNT($_[0]) > 1;
		&Internals::SvREADONLY($_[0], 1);
		if ($reftype eq 'ARRAY') {
			$_[0] = [ @{ $_[0] } ] if $needs_cloning;
			_make_readonly($_) for @{ $_[0] };
		}
		elsif ($reftype eq 'HASH') {
			$_[0] = { %{ $_[0] } } if $needs_cloning;
			&Internals::hv_clear_placeholders($_[0]);
			_make_readonly($_) for values %{ $_[0] };
		}
		elsif ($reftype eq 'SCALAR' and $needs_cloning) {
			$_[0] = \(my $anon = ${ $_[0] });
		}
	}
	Internals::SvREADONLY($_[0], 1);
	return;
}

## no critic (ProhibitSubroutinePrototypes, ManyArgs)
sub const(\[$@%]@) {
	my (undef, @args) = @_;
	croak 'Attempt to reassign a readonly variable' if &Internals::SvREADONLY($_[0]);
	if (reftype $_[0] eq 'SCALAR') {
		croak 'No value for readonly variable' if @args == 0;
		croak 'Too many arguments in readonly assignment' if @args > 1;
		${ $_[0] } = $args[0];
	}
	elsif (reftype $_[0] eq 'ARRAY') {
		@{ $_[0] } = @args;
	}
	elsif (reftype $_[0] eq 'HASH') {
		croak 'Odd number of elements in hash assignment' if @args % 2;
		%{ $_[0] } = @args;
	}
	else {
		croak 'Can\'t make variable readonly';
	}
	_make_readonly($_[0], 1);
	return;
}

1;    # End of Const::Fast

__END__

=head1 NAME

Const::Fast - Facility for creating read-only scalars, arrays, hashes

=head1 VERSION

Version 0.004

=head1 SYNOPSIS

 use Const::Fast;
 
 const my $foo => 'a scalar value';
 const my @bar => qw/a list value/;
 const my %buz => (a => 'hash', of => 'something');

=head1 SUBROUTINES/METHODS

=head2 const $var, $value

=head2 const @var, @value...

=head2 const %var, %value...

This the only function of this module and it is exported by default. It takes a scalar, array or hash lvalue as first argument, and a list one or more values depending on the type of the first argument as the value for the variable. It will set the variable to that value and subsequently make it readonly. Arrays and hashes will be made deeply readonly.

Exporting is done using Sub::Exporter for flexibility on import.

=head1 RATIONALE

This module was written because I stumbled on some serious issues of L<Readonly> that aren't easily fixable without breaking backwards compatibility in subtle ways. In particular Reasonly's use of ties is a source of subtle bugs and bad performance. Instead this module is using the builtin readonly feature of perl, making access to the variables just as fast as any normal variable without the weird side-effects of ties. Readonly can do the same for scalars when Readonly::XS is installed, but chooses not to do so in the most common case.

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-const-fast at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Const-Fast>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT
 
You can find documentation for this module with the perldoc command.

    perldoc Const::Fast

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Const-Fast>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Const-Fast>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Const-Fast>

=item * Search CPAN

L<http://search.cpan.org/dist/Const-Fast/>

=back

=head1 ACKNOWLEDGEMENTS

The interface for this module was inspired by Eric Roode's L<Readonly>. The implementation is inspired by doing everything the opposite way Readonly does it.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Leon Timmermans.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
