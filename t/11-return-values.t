use strict;
use warnings FATAL => 'all';
use Test::More 0.88;

use Const::Fast;

my $rs = (const my $scalar => 'a scalar value');
my @ra = (const my @array => 'an', 'array', 'value');
my %rh = (const my %hash => (a => 'hash', of => 'things'));

is($rs, $scalar, 'scalar return is correct');
is_deeply(\@ra, \@array, 'array return is correct');
is_deeply(\%rh, \%hash, 'hash return is correct');

$rs = 'foo';
is($scalar, 'a scalar value', 'original const scalar is not touched');

push @ra, 'anothervalue';
is_deeply(\@array, ['an', 'array', 'value'], 'original const array is not touched');

$rh{foo} = 'another field';
is_deeply(\%hash, {a => 'hash', of => 'things'}, 'original const hash is not touched');

done_testing;
