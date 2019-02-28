use strict;
use warnings;
use ExtUtils::MakeMaker;

my %conf = (
    NAME          => 'IO::AIO::Util',
    AUTHOR        => 'gray <gray@cpan.org>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/IO/AIO/Util.pm',
    ABSTRACT_FROM => 'lib/IO/AIO/Util.pm',
    PREREQ_PM => {
        'File::Spec::Functions' => 0,
        'IO::AIO'               => 2,
        'POSIX'                 => 0,
        'Test::More'            => 0,
        'parent'                => 0,
    },
    META_MERGE    => {
        resources => {
            repository => 'http://github.com/gray/io-aio-util',
        },
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'IO-AIO-Util-*' },
);

unless (eval { ExtUtils::MakeMaker->VERSION(6.46) }) {
    delete $conf{META_MERGE};
}

WriteMakefile(%conf);


sub MY::postamble {
    return <<"    MAKE_FRAG";
authortest:
\t\$(MAKE) -e \$(TEST_TYPE) TEST_FILES="xt/*.t"
    MAKE_FRAG
}

sub MY::dist_test {
    my $self = shift;
    return $self->MM::dist_test . <<"    MAKE_FRAG";
\tcd \$(DISTVNAME) && \$(MAKE) authortest \$(PASTHRU)
    MAKE_FRAG
}
