#!/usr/bin/perl 
# Perl script to return a laptop's lid state.
# usage: lid-state.pl [options...]
# depends on: Getopt::Long::Modern

use Getopt::Long::Modern;
use strict;
use warnings;

my $usage = <<EOF;
lid-state.pl - outputs the lid state

usage: battery-level.pl [options...]

options:
  -l, --lid lid_id            lid ID (x in /sys/class/power_supply/BATx/)
                              defaults to 0
  -o, --output  output_type   the thing to output (word, number)
                              defaults to word
  -v, --verbose               verbose output
  -h, --help                  display this message
EOF

my $lidid = 0;
my $response = 'word';
my $verbose = 0;


GetOptions (
  "l|lid=i" => \$lidid,
  "o|output=s" => \$response,
  "v|verbose!" => \$verbose,
  "h|help" => sub { print $usage; exit }
) or die("Error getting command line options :(");

my ($LID_INTERFACE, $LID_DATA, $LID_STATE);

# 
# Detect battery data interface
# 

if (-d '/proc/acpi/button/lid') {

  if ($verbose) {
    print "Detected /proc/acpi/button/lid, using that as info source";
  }

  $LID_INTERFACE = '/proc/acpi/button/lid';
  $LID_DATA = "$LID_INTERFACE/LID$lidid";
  $LID_STATE = "$LID_DATA/state";
}

# TODO: add ACPI interface support...?


# Check if lid data interface is readable
if (! -d $LID_DATA || ! -r $LID_DATA) {

  my $found = 0;

  # Detect if there's some other lid between 0 and 20
  for (my $i = 0; $i <= 20; $i++) {
    my $lid_cur = "$LID_INTERFACE/LID$i";
    if (-d $lid_cur && -r $lid_cur) {
      $LID_DATA = $lid_cur;
      $found = 1;
      last;
    }
  }

  if (!$found) {
    print STDERR "Could not find a battery!";
    print STDERR "Try running `ls $LID_INTERFACE`\n";
    die "error code: $!\n";
  }
}

sub get_lid_state {
  my $response = shift;

  open my $vf, "<", "$LID_STATE" or die("Couldn't open $LID_STATE: $!\n");
  my $lidstate = <$vf>;
  chomp $lidstate;
  close $vf;

  if ($lidstate =~ /^state:      (open|closed)$/) {
    $lidstate = $1;
  }

  if ($verbose) {
    print("lid_state = $lidstate\n");
  }

  if ($response eq 'word') {
    return $lidstate;   
  } else {
    return $lidstate eq 'open' ? 1 : 0;
  }

}

print get_lid_state($response) . "\n";
