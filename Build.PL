use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Const',
	license             => 'perl',
	dist_author         => q{Leon Timmermans <leont@cpan.org>},
	dist_version_from   => 'lib/Const.pm',
	build_requires      => {
		'Test::More'    => 0,
		'Module::Build' => 0
	},
	requires	        => {
		perl            => 5.008,
		Exporter        => 5.57,
	},
	add_to_cleanup      => [ 'Const-*' ],
	create_makefile_pl => 'traditional',
);

$builder->create_build_script();
