package IO::AIO::Util;

use strict;
use warnings;
use base qw(Exporter);

use IO::AIO 2;
use File::Spec::Functions qw(
    canonpath catpath catdir splitdir splitpath updir
);
use POSIX ();

our $VERSION = '0.08';
$VERSION = eval $VERSION;

our @EXPORT_OK = qw(aio_mkpath aio_mktree);

sub aio_mkpath {
    my ($path, $mode, $cb) = @_;

    my $pri = aioreq_pri;
    my $grp = aio_group $cb;

    # Default is success.
    local $!;
    $grp->result(0);

    # Clean up the path.
    $path = canonpath($path);

    my ($vol, $dir, undef) = splitpath($path, 1);
    my @dirs = splitdir($dir);

    for my $idx (0 .. $#dirs) {
        # Root and parent directories are assumed to always exist.
        next if '' eq $dirs[$idx] or updir eq $dirs[$idx];

        my $path = catpath($vol, catdir(@dirs[0 .. $idx]), '');

        aioreq_pri $pri;
        add $grp aio_mkdir $path, $mode, sub {
            return unless $_[0];

            # Ignore "file exists" errors unless it is the last component,
            # then stat it to ensure it is a directory. This matches
            # the behaviour of `mkdir -p` from GNU coreutils.
            return if &POSIX::EEXIST == $!
                and not ($idx == $#dirs and not -d $path);

            $grp->cancel_subs;
            $grp->errno($!);
            $grp->result($_[0]);
            return;
        };
    }

    return $grp;
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

This module provides useful functions that are missing from
C<IO::AIO::Util>.

=head1 FUNCTIONS

=over

=item aio_mkpath $pathname, $mode, $callback->($status)

=item aio_mktree $pathname, $mode, $callback->($status)

This is a composite request that creates the directory and any intermediate
directories as required. The status is the same as aio_mkdir.

=back

=head1 NOTES

As this module uses C<IO::AIO>, it is subject to the same underlying
restrictions. Most importantly, that the pathname parameter be encoded as
bytes and be absolute, or ensure that the working does not change.

See the documentation for C<IO::AIO> for more details.

=head1 SEE ALSO

L<IO::AIO>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=IO-AIO-Util>. I will be
notified, and then you'll automatically be notified of progress on your bug
as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IO::AIO::Util

You can also look for information at:

=over

=item * GitHub Source Repository

L<http://github.com/gray/io-aio-util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IO-AIO-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IO-AIO-Util>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/Public/Dist/Display.html?Dist=IO-AIO-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/IO-AIO-Util>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2009 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut
