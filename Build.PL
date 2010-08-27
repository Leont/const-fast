use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Const::Fast',
	license             => 'perl',
	dist_author         => q{Leon Timmermans <leont@cpan.org>},
	dist_version_from   => 'lib/Const/Fast.pm',
	configure_requires  => {
		'Module::Build' => 0
	},
	build_requires      => {
		'Test::More'    => 0,
		'Test::Exception' => 0,
		'Module::Build' => 0,
	},
	requires	        => {
		perl            => 5.008,
		'Sub::Exporter' => 0,
	},
	add_to_cleanup      => [ 'Const-Fast-*' ],
	create_makefile_pl  => 'traditional',
	sign                => 1,
);

$builder->create_build_script();
