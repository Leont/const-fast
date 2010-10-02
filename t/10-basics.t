#!perl

# Test the Const function

use strict;
use warnings FATAL => 'all';
use Test::More tests => 17;
use Test::Exception;

use Const::Fast;

sub throws_readonly(&@) {
	my ($sub, $desc) = @_;
	my ($file, $line) = (caller)[1,2];
	my $error = qr/\AModification of a read-only value attempted at \Q$file\E line $line\.\Z/;
	&throws_ok($sub, $error, $desc);
	return;
}

sub throws_reassign(&@) {
	my ($sub, $desc) = @_;
	my ($file, $line) = (caller)[1,2];
	my $error = qr/\AAttempt to reassign a readonly \w+ at \Q$file\E line $line\Z/;
	&throws_ok($sub, $error, $desc);
	return;
}

lives_ok {const my $scalar => 45} 'Create scalar';

throws_readonly { const my $scalar => 45; $scalar = 45 } 'Modify scalar';

lives_ok {const my @array => (1, 2, 3, 4)} 'Create array';

throws_readonly { const my @array => (1, 2, 3, 4); $array[2] = 3 } 'Modify array';

lives_ok { const my %hash => (key1 => "value", key2 => "value2")} 'Create hash (list)';

my ($file, $line) = (__FILE__, __LINE__ + 1);
throws_ok { const my %hash => (key1 => "value", "key2") } qr/\AOdd number of elements in hash assignment at \Q$file\E line $line\Z/i, 'Odd number of values';

throws_readonly { const my %hash => (key1 => "value", key2 => "value2"); $hash{key1} = "value" } 'Modify hash';

my %computed_values = qw/a A b B c C d D/;
lives_ok { const my %a2 => %computed_values } 'Hash, computed values';

my %foo;
$foo{bar} = \%foo;
lives_ok { const my %recur => ( baz => \%foo ) } 'recursive structures are handles properly';

const my $scalar => 'a scalar value';
const my @array => 'an', 'array', 'value';
const my %hash => (a => 'hash', of => 'things');

# Reassign scalar
throws_reassign { const $scalar => "a second scalar value" } 'Scalar reassign die';
is $scalar => 'a scalar value', 'const reassign no effect';

# Reassign array
throws_reassign { const @array => "another", "array" } 'Array reassign die';
ok eq_array(\@array, [qw[an array value]]) => 'const reassign no effect';

# Reassign hash
throws_reassign { const %hash => "another", "hash" } 'Hash reassign die';
ok eq_hash(\%hash, {a => 'hash', of => 'things'}) => 'Const reassign no effect';

# Test for RT#61726
const my $rx => qr/foo/;
isa_ok $rx, 'Regexp';

const my %rx => ( foo => qr/foo/ );
isa_ok $rx{foo}, 'Regexp' or diag( Dumper( \%rx ) ); # fails

