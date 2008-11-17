#!/usr/bin/perl

use strict;
use warnings;
use File::Copy ();
use File::Spec ();
use File::Path ();
use Cwd        ();

my $src = shift;
my $dst = shift;

unless ($dst && $src) {
    usage();
    exit;
}

if (-d $src) {
    rcopy( $src, $dst );
}
else {
    glob_rcopy($src, $dst);
}

sub rcopy {
    my ( $src, $dst, $back_level ) = @_;

    if ( !-e $dst ) {
        File::Path::mkpath($to, 0, 0777);
    }
    elsif ( -f $dst ) {
        die "Destination cannot be a file\n";
    }

    my $iter = walk_dir($src);
    while ( my $from = $iter->() ) {
        $from         = Cwd::abs_path($from);
        my @src       = File::Spec->splitdir( Cwd::abs_path($src) );
        my $src_level = @src;
        $src_level-- if $back_level;
        @src = File::Spec->splitdir($from);
        my $to = File::Spec->catfile( Cwd::abs_path($dst), @src[ $src_level .. $#src ] );

        if ( -d $from ) {
            File::Path::mkpath($to, 0, mode($from));
        }
        elsif ( -f $from ) {
            File::Copy::copy( $from, $to );
            chmod(mode($from), $to) if !-e $to;
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
    return (stat($file))[2] & 0777;
}

sub usage {
    my $prog = $0;
    print <<EOF;
$prog source destination
EOF
}