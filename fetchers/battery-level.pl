#!/usr/bin/perl 
# Perl script to return the battery level. 
# usage: battery-level.pl [options...]
# depends on: Getopt::Long::Modern

use Getopt::Long::Modern;
use strict;
use warnings;

my $usage = <<EOF;
battery-level.pl - outputs the system battery level

usage: battery-level.pl [options...]

options:
  -b, --battery battery_id    battery ID (x in /sys/class/power_supply/BATx/)
                              defaults to 0
  -o, --output  output_type   the thing to output (percentage, voltage)
                              defaults to percentage
  -v, --verbose               verbose output
  -h, --help                  display this message
EOF

my $batteryid = 0;
my $response = 'percentage';
my $verbose = 0;


GetOptions (
  "b|batt|battery=i" => \$batteryid,
  "o|output=s" => \$response,
  "v|verbose!" => \$verbose,
  "h|help" => sub { print $usage; exit }
) or die("Error getting command line options :(");

my ($BATTERY_INTERFACE, $BATTERY_DATA, $BATTERY_CHARGE, $BATTERY_CHARGE_FULL, $BATTERY_VOLTAGE);

# 
# Detect battery data interface
# 

if (-d '/sys/class/power_supply') {

  if ($verbose) {
    print "Detected /sys/class/power_supply, using that as info source";
  }

  $BATTERY_INTERFACE = '/sys/class/power_supply';
  $BATTERY_DATA = "$BATTERY_INTERFACE/BAT$batteryid";
  $BATTERY_CHARGE = "$BATTERY_DATA/charge_now";
  $BATTERY_CHARGE_FULL = "$BATTERY_DATA/charge_full";
  $BATTERY_VOLTAGE = "$BATTERY_DATA/voltage_now";
}

# TODO: add ACPI interface support...?


# Check if battery data interface is readable
if (! -d $BATTERY_DATA || ! -r $BATTERY_DATA) {

  my $found = 0;

  # Detect if there's some other battery between 0 and 20
  for (my $i = 0; $i <= 20; $i++) {
    my $batt_cur = "$BATTERY_INTERFACE/BAT$i";
    if (-d $batt_cur && -r $batt_cur) {
      $BATTERY_DATA = $batt_cur;
      $found = 1;
      last;
    }
  }

  if (!$found) {
    print STDERR "Could not find a battery!";
    print STDERR "Try running `ls $BATTERY_INTERFACE`\n";
    die "error code: $!\n";
  }
}



# Other files are checked directly on open

sub get_battery_percentage {
  open my $cn, "<", $BATTERY_CHARGE or die("Couldn't open $BATTERY_CHARGE: $!\n");
  my $charge_now = <$cn>;
  chomp $charge_now;
  close $cn;

  if ($verbose) {
    print ("charge_now = $charge_now\n");
  }
  
  open my $cf, "<", $BATTERY_CHARGE_FULL or die("Couldn't open $BATTERY_CHARGE_FULL: $!\n");
  my $charge_full = <$cf>;
  chomp $charge_full;
  close $cf;

  if ($verbose) {
    print ("charge_full = $charge_full\n");
  }

  my $result = ($cn / $cf) * 100;

  if ($verbose) {
    print ("result = $result\n");
  }

  return ($charge_now / $charge_full) * 100;
}



sub get_battery_voltage {
  open my $vf, "<", "$BATTERY_VOLTAGE" or die("Couldn't open $BATTERY_VOLTAGE: $!\n");
  my $volts = <$vf>;
  chomp $volts;
  close $vf;

  if ($verbose) {
    print("voltage_now = $volts\n");
  }

  return $volts;
}



if ($response eq 'percentage') {
  print(get_battery_percentage() . "\n");
} elsif ($response eq 'voltage') {
  print(get_battery_voltage() . "\n");
} else {
  print $usage;
}
