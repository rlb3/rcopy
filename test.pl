#!usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Dir;
use Utils;
use Data::Dumper;


my $dst = 'dst';
my $src = 'src';

globrcopy("$src/dir1*", $dst);


#rcopy($src, $dst);

sub rcopy {
    my ($src, $dst) = @_;

    if (!-e $dst) {
        mkdir ($dst, 0700);
    }
    elsif (-f $dst) {
        die "Destination cannot be a file\n";
    }

    my $it = Dir::walk($src);

    while ( my $file = $it->() ) {
        my $newfile = $file;

        if ( -d $file ) {
            my $dir = (split('/', $newfile))[-1] . "\n";
            print $dir . "\n";
            mkdir( "$dst/$dir", 0700 );
        }
        elsif ( -f $file ) {
            system( 'cp', $file, $newfile );
        }

    }
}

sub globrcopy {
    my ($src, $dst) = @_;
    my @src = glob($src);
    print Dumper \@src;
    foreach my $file (@src) {
        rcopy($file, $dst);
    }
}