#!usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Dir;
use Utils;

my $dst = 'dst';
my $src = 'src';

rcopy($src, $dst);

sub rcopy {
    my ($src, $dst) = @_;

    die "Destination is not a directory\n" if !-d $dst;

    my $it = Dir::walk($src);

    while ( my $file = $it->() ) {
        my $newfile = $file;
        $newfile =~ s/^$src/$dst/;
        if ( -d $file ) {
            mkdir( $newfile, 0700 );
        }
        elsif ( -f $file ) {
            system( 'cp', $file, $newfile );
        }

    }
}
