# whatsup

whatsup is a collection of scripts that can listen to and detect changes to system variables, and perform actions based on them. It's basically an overpowered version of IFTTT for your Linux machine.

## Layout

The simple idea is this: A watcher program sits in the background, listening to events with either scripts called fetchers or by hooking onto events on the ACPI/system level. 

A configuration file is defined based on a bunch of rules, which specify conditions to fulfill in order to run scripts. Sort of just to make it really really interoperable with the shell.

## Current scripts

### fetchers/battery-level.pl

```
battery-level.pl - outputs the system battery level

usage: battery-level.pl [options...]

options:
  -b, --battery battery_id    battery ID (x in /sys/class/power_supply/BATx/)
                              defaults to 0
  -o, --output  output_type   the thing to output (percentage, voltage)
                              defaults to percentage
  -v, --verbose               verbose output
  -h, --help                  display this message
```

### fetchers/lid-state.pl

```
lid-state.pl - outputs the lid state

usage: battery-level.pl [options...]

options:
  -l, --lid lid_id            lid ID (x in /sys/class/power_supply/BATx/)
                              defaults to 0
  -o, --output  output_type   the thing to output (word, number)
                              defaults to word
  -v, --verbose               verbose output
  -h, --help                  display this message
```


### watcher/watcher.pl

``` 
watcher.pl - watches a bunch of variables based on rules and runs stuff accordingly

usage: watcher.pl [options...]

options:
  -v, --verbose               verbose output
  -h, --help                  display this message
```

