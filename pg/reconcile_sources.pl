#!/usr/bin/env perl
use warnings;
use strict;

=pod

A quick and dirty script for the purpose of reconciling the files to
run in the create scripts with the actual source files in the tasker
subdirectory.

The idea is to ensure that any files listed in the create scripts that
do not exist in the tasker source files is commented out while any new
source files get added.

=cut

my %obj_types = (
    'type'     => '06_create_types.sql',
    'sequence' => '07_create_sequences.sql',
    'table'    => '08_create_tables.sql',
    'view'     => '09_create_views.sql',
    'function' => '10_create_functions.sql',
    'procedure' => '11_create_procedures.sql',
);

foreach my $type ( sort keys %obj_types ) {
    my $create_file = $obj_types{$type};
    my $source      = "tasker/$type";
    reconcile_type( $create_file, $source );
}

sub reconcile_type {
    my ( $create_file, $source_dir ) = @_;

    return unless ( -d $source_dir ) ;

    opendir(my $dh, $source_dir) || warn "Can't opendir $source_dir: $!\n";
    return unless ( $dh ) ;

    my @source_files = map { "$source_dir/$_" } grep { /\.sql$/ && -f "$source_dir/$_" } readdir($dh);
    closedir $dh;

    my %avail = map { $_ => 'notseen' } @source_files;
    my $fh;
    my @lines;
    my @orig;

    open( $fh, '<:raw', $create_file )
      || die "Could not open $create_file. $!\n";

    while ( my $line = <$fh> ) {

        chomp $line;
        push @orig, $line;

        $line =~ s/^[ \t]+//;

        # check included files
        if ( $line =~ m/^\\i/ ) {
            my @ary = split /([ \t]+)/, $line;

            if ( exists $avail{ $ary[2] } ) {
                $avail{ $ary[2] } = 'seen';
                shift @ary;
                shift @ary;
                push @lines, '\i ' . join( '', @ary );
            }
            else {
                push @lines, '--' . $line;
            }
        }

        # check comments for included files. assert that if they are
        # commented out then there is a reason for having done so
        elsif ( $line =~ m/^\-\-/ ) {
            my @ary = split /([ \t]+)/, $line;

            if ( exists $avail{ $ary[2] } ) {
                $avail{ $ary[2] } = 'seen';
            }
            push @lines, $line;
        }

        # preserve all other lines
        else {
            push @lines, $line;
        }

    }
    close $fh;

    my @missing;
    foreach my $file ( sort keys %avail ) {
        if ( $avail{$file} eq 'notseen' ) {
            push @missing, '\i ' . $file;
        }
    }

    my @final;
    push @final, $_ for @lines;
    if (@missing) {
        push @final, "\n-- NEW -------------------------------";
        push @final, $_ for @missing;
        push @final, '';
    }

    if ( join( "\n", @orig ) eq join( "\n", @final ) ) {

        # Nothing changed
        return;
    }
    else {
        open( $fh, '>:raw', $create_file )
          || die "Could not open $create_file. $!\n";
        print $fh join( "\n", @final );
        close $fh;
    }
}
