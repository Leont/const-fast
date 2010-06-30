#!perl

# Test the Const function

use strict;
use warnings FATAL => 'all';
use Test::More tests => 14;
use Test::Exception;

use Const;

sub throws_readonly(&@) {
	my ($sub, $desc) = @_;
	my ($file, $line) = (caller)[1,2];
	my $error = qr/Modification of a read-only value attempted at $file line $line/;
	&throws_ok($sub, $error, $desc);
	return;
}

sub throws_reassign(&@) {
	my ($sub, $desc) = @_;
	my ($file, $line) = (caller)[1,2];
	my $error = qr/Attempt to reassign a readonly \w+ at $file line $line/;
	&throws_ok($sub, $error, $desc);
	return;
}

lives_ok {Const my $ros => 45} 'Create scalar';

throws_readonly { Const my $ros2 => 45; $ros2 = 45 } 'Modify scalar';

lives_ok {Const my @roa => (1, 2, 3, 4)} 'Create array';

throws_readonly { Const my @roa2 => (1, 2, 3, 4); $roa2[2] = 3 } 'Modify array';

lives_ok { Const my %roh => (key1 => "value", key2 => "value2")} 'Create hash (list)';

throws_ok { Const my %roh => (key1 => "value", "key2") } qr/odd number of/i, 'Odd number of values';

throws_readonly { Const my %roh2 => (key1 => "value", key2 => "value2"); $roh2{key1} = "value" } 'Modify hash';

my %computed_values = qw/a A b B c C d D/;
lives_ok { Const my %a2 => %computed_values } 'Hash, computed values';

Const my $s1 => 'a scalar value';
Const my @a1 => 'an', 'array', 'value';
Const my %h1 => (a => 'hash', of => 'things');

# Reassign scalar
throws_reassign { Const $s1 => "a second scalar value" } 'Readonly::Scalar reassign die';
is $s1 => 'a scalar value', 'Const reassign no effect';

# Reassign array
throws_reassign { Const @a1 => "another", "array" } 'Readonly::Array reassign die';
ok eq_array(\@a1, [qw[an array value]]) => 'Const reassign no effect';

# Reassign hash
throws_reassign { Const %h1 => "another", "hash" } 'Readonly::Hash reassign die';
ok eq_hash(\%h1, {a => 'hash', of => 'things'}) => 'Const reassign no effect';

