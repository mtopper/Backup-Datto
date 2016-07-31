#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'Backup::Datto::Collection' ) || print "Bail out!\n";
    use_ok( 'Backup::Datto::Agent' ) || print "Bail out!\n";
    use_ok( 'Backup::Datto::Device' ) || print "Bail out!\n";
}

diag( "Testing Backup::Datto::Collection $Backup::Datto::Collection::VERSION, Perl $], $^X" );
