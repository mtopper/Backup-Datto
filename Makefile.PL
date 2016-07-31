use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Backup::Datto',
    AUTHOR           => q{Matthew Topper <mtopper@cpan.org>},
    VERSION_FROM     => 'lib/Backup/Datto/Collection.pm',
    ABSTRACT         => 'Collection of modules to report data from Datto backup devices.',
    LICENSE          => 'GPL_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'XML::SIMPLE'    => 0,
		'Time::Interval' => 1.22,
		'Time::Piece'    => 1.15,
		'Time::Seconds'  => 1.15,
        'LWP'            => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Backup::Datto-*' },
);
