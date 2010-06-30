#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Const' ) || print "Bail out!
";
}

diag( "Testing Const $Const::VERSION, Perl $], $^X" );
