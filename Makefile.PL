use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'IO-AIO-Util',
    AUTHOR        => 'gray <gray@cpan.org>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/IO/AIO/Util.pm',
    ABSTRACT_FROM => 'lib/IO/AIO/Util.pm',
    PREREQ_PM     => {
        'File::Spec' => 0,
        'IO::AIO'    => 2,
        'Test::More' => 0,
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'IO-AIO-Util-*' },
);
