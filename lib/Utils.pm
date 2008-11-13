package Utils;
use strict;
use warnings;

my @export = qw(Iterator NEXTVAL imap igrep append filehandle_iterator list_iterator);
sub import {
    my $caller = caller();
    no strict 'refs';
    *{ $caller . '::' . $_ } = \&{$_} for (@export);
}

sub Iterator (&) {
    return $_[0];
}

sub NEXTVAL {
    my ($it) = @_;
    return $it->();
}

sub imap (&$) {
    my ( $transform, $it ) = @_;
    return Iterator {
        local $_ = NEXTVAL($it);
        return unless defined $_;
        return $transform->();
    };
}

sub igrep (&$) {
    my ( $is_interesting, $it ) = @_;
    return Iterator {
        local $_;
        while ( defined( $_ = NEXTVAL($it) ) ) {
            return $_ if $is_interesting->();
        }
        return;
    }
}

sub append {
    my @its = @_;
    return Iterator {
        my $val;
        until ( @its == 0 || defined( $val = NEXTVAL( $its[0] ) ) ) {
            shift @its;
        }
        return if @its == 0;
        return $val;
    };
}

sub filehandle_iterator {
    my $fh = shift;
    return Iterator { <$fh> };
}

sub list_iterator {
    my @items = @_;
    return Iterator {
        return shift @items;
    };
}

1;
