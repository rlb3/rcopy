#!usr/bin/perl

use strict;
use warnings;
use File::Copy ();
use File::Spec ();
use Cwd        ();

my $dst = 'dst';
my $src = 'src';

rcopy( $src, $dst );

sub rcopy {
    my ( $src, $dst, $back_level ) = @_;

    if ( !-e $dst ) {

        # This would need to use mkdir -p or something like it
        mkdir( $dst, 0755 );
    }
    elsif ( -f $dst ) {
        die "Destination cannot be a file\n";
    }

    my $iter = walk_dir($src);
    while ( my $from = $iter->() ) {

        $from = Cwd::abs_path($from);
        my @src       = File::Spec->splitdir( Cwd::abs_path($src) );
        my $src_level = @src;
        $src_level-- if $back_level;
        @src = File::Spec->splitdir($from);
        my $to = File::Spec->catfile( Cwd::abs_path($dst), @src[ $src_level .. $#src ] );

        if ( -d $from ) {
            # This would need to copy the old permissions
            mkdir( $to, 0755 );
            chmod(mode($from), $to);
        }
        elsif ( -f $from ) {
            # This would need to copy the old permissions as well
            File::Copy::copy( $from, $to );
            chmod(mode($from), $to);
        }
    }
}

sub glob_rcopy {
    my ( $src, $dst ) = @_;
    my @src        = glob($src);
    my $back_level = 0;
    foreach my $file (@src) {
        $back_level++ if -d Cwd::abs_path($file);
        rcopy( $file, $dst, $back_level );
    }
}

sub walk_dir {
    my @queue = @_;
    return sub {
        if (@queue) {
            my $file = shift @queue;
            if ( -d $file ) {
                if ( opendir my $dh, $file ) {
                    my @newfiles = grep { $_ ne "." && $_ ne ".." } readdir $dh;
                    push @queue, map "$file/$_", @newfiles;
                }
            }
            return $file;
        }
        else {
            return;
        }
    };
}

sub mode {
    my ($file) = @_;
    return oct(sprintf "%04o", ((stat($file))[2]) & 07777);
}