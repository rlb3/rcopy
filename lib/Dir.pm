package Dir;
use strict;
use warnings;

use Utils;

sub walk {
    my @queue = @_;
    return Iterator {
        if (@queue) {
            my $file = shift @queue;
            if ( -d $file ) {
                if (opendir my $dh, $file) {
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

1;
