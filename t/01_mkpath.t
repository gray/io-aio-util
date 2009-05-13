use strict;
use warnings;
use Test::More tests => 11;
use IO::AIO::Util qw(aio_mkpath);
use File::Spec::Functions qw(catdir);
use File::Temp qw(tempdir tempfile);
use POSIX ();

# Copied from IO::AIO tests
sub pcb {
    while (IO::AIO::nreqs) {
        vec (my $rfd="", IO::AIO::poll_fileno, 1) = 1;
        select $rfd, undef, undef, undef;
        IO::AIO::poll_cb;
    }
}

my $tmp = tempdir(CLEANUP => 1);

{
    my $dir = catdir($tmp, qw(dir1 dir2));

    aio_mkpath $dir, 0777, sub {
        is($_[0], 0, 'new path: return status');
        ok(! $!, 'new path: errno');
        is(-d $dir, 1, "new path: -d $dir");
    };

    pcb;

    aio_mkpath $dir, 0777, sub {
        is($_[0], 0, 'existing path: return status');
        ok(! $!, 'existing path: errno');
    };

    pcb;
}

{
    my (undef, $file) = tempfile(DIR => $tmp);

    aio_mkpath $file, 0777, sub {
        is($_[0], -1, 'existing file: return status');
        is(0 + $!, &POSIX::ENOTDIR, 'existing file: errno');
    };

    pcb;
}

SKIP: {
    skip "cannot test permissions errors as this user", 2
        unless $> > 0 and $) > 0;

    my $dir = catdir($tmp, qw(dir1 dir2));
    chmod 0000, $dir or die "$!\n";
    my $subdir = catdir($dir, 'dir3');

    aio_mkpath $subdir, 0777, sub {
        is($_[0], -1, "permission denied: return status");
        is(0 + $!, &POSIX::EACCES, 'permission denied: errno');
    };

    pcb;
}

SKIP: {
    skip "cannot test permissions errors as this user", 2
        unless $> > 0 and $) > 0;

    my $dir = catdir($tmp, qw(dir4 dir5));

    aio_mkpath $dir, 0111, sub {
        is($_[0], -1, "bad permissions: return status");
        is(0+$!, &POSIX::EACCES, 'bad permissions: errno');
    };

    pcb;
}
