package IO::AIO::Util;

use strict;
use warnings;

use base qw(Exporter);
use IO::AIO 2;
use File::Spec::Functions qw(splitpath splitdir catpath catdir);
use POSIX ();

our $VERSION = '0.07';
our @EXPORT_OK = qw(aio_mkpath aio_mktree);

sub aio_mkpath ($$;$) {
    my ($path, $mode, $cb) = @_;

    my $pri = aioreq_pri;
    my $grp = aio_group $cb;

    # Default is success.
    $grp->result(0);

    my @make;
    my $statgrp = add $grp aio_group sub {
        my $dirgrp = add $grp aio_group;
        for my $path (@make) {
            aioreq_pri $pri;
            add $dirgrp aio_mkdir $path, $mode, sub {
                if ($_[0]) {
                    $grp->result($_[0]);
                    $grp->errno($!);
                    return $grp->cancel_subs;
                }
            };
        }
    };

    my ($vol, $dir, undef) = splitpath($path, 1);
    my @dirs = splitdir($dir);

    while (@dirs) {
        my $path = $path;

        aioreq_pri $pri;
        add $statgrp aio_stat $path, sub {
            # stat was successful
            if (not $_[0]) {
                # fail if part of the expected path is not a dir
                if (not -d _) {
                    $grp->result(-1);
                    $grp->errno(&POSIX::ENOTDIR);
                    return $grp->cancel_subs;
                }
                return $statgrp->cancel_subs;
            }
            # stat was not succesful, for reason other than non-existence
            elsif ($_[0] and $! != &POSIX::ENOENT) {
                $grp->result(-1);
                $grp->errno($!);
                return $grp->cancel_subs;
            }

            unshift @make, $path;
        };
    }
    continue {
        pop @dirs;
        $path = catpath($vol, catdir(@dirs), '');
    }

    $grp;
}

*aio_mktree = \&aio_mkpath;

1;

__END__

=head1 NAME

IO::AIO::Util - useful functions missing from IO::AIO

=head1 SYNOPSIS

    aio_mkpath "/tmp/dir1/dir2", 0755, sub {
        $_[0] and die "/tmp/dir1/dir2": $!";
    };

=head1 DESCRIPTION

This module provides useful functions that are missing from C<IO::AIO::Util>.

=head1 FUNCTIONS

=over

=item aio_mkpath $pathname, $mode, $callback->($status)

=item aio_mktree $pathname, $mode, $callback->($status)

This is a composite request that creates the directory and any intermediate
directories as required. The status is the same as aio_mkdir.

=back

=head1 SEE ALSO

L<IO::AIO|IO::AIO>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-AIO-Util>. I will
be notified, and then you'll automatically be notified of progress on your bug
as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::AIO::Util

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IO-AIO-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IO-AIO-Util>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IO-AIO-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/IO-AIO-Util>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut
