#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Const::Fast' ) || print "Bail out!
";
}

diag( "Testing Const::Fast $Const::Fast::VERSION, Perl $], $^X" );
