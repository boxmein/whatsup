#!/usr/bin/perl 
# Perl script to watch variables based on rules, run things accordingly
# usage: watcher.pl [options...]
# depends on: Getopt::Long::Modern

use Getopt::Long::Modern;
use strict;
use warnings;

my $usage = <<EOF;
watcher.pl - watches a bunch of variables based on rules and runs stuff accordingly

usage: watcher.pl [options...]

options:
  -v, --verbose               verbose output
  -h, --help                  display this message
EOF

my $verbose = 0;

GetOptions (
  "v|verbose!" => \$verbose,
  "h|help" => sub { print $usage; exit }
) or die("Error getting command line options :(");

die("Not yet implemented :D");