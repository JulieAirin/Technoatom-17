#!/usr/bin/perl

use strict;
use warnings;
use DDP;
use Time::Local;
 use List::Util qw(max min sum);

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my $result;
    my $time;

    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
        $log_line =~ /^
        (?<IP>\d+\.\d+\.\d+\.\d+)\s
        \[(?<mday>\d{2})\/(?<mon>\w{3})\/(?<year>\d{4})\:(?<hour>\d{2})\:(?<min>\d{2})\:(?<sec>\d{2})\s\+\d{4}\]\s
        \"(?<Request>.+)\"\s
        (?<Status>\d+)\s
        (?<ZData>\d+)\s
        \"(?<Referer>.+)\"\s
        \"(?<UA>.+)\"\s
        \"(?<Coef>(\d+(\.\d+)?)|\-)\"
        $/x;
        $time = timelocal($+{sec},$+{min},$+{hour},$+{mday},mon($+{mon}),$+{year} );
        if (($+{Status} == 200) && ($+{Coef} ne "-")) {
          push @{${$result}{$+{IP}}{data}}, $+{ZData}*$+{Coef};
        }
        push @{${$result}{$+{IP}}{time}}, $time;
        push @{${$result}{$+{IP}}{zdata}}, $+{ZData};
        push @{${$result}{$+{IP}}{status}}, $+{Status};
    }
    close $fd;
    return $result;
}

sub report {
    my $result = shift;
    my @list = sort { scalar @{${$result}{$b}{time}} <=> scalar @{${$result}{$a}{time}} } keys %{$result};
    my %table;
    my $min;
    my $max;
    ${$table{total}}{min} =  time();
    ${$table{total}}{max} =  0;

    for my $x (@list) {
      ${$table{total}}{count} += scalar @{${$result}{$x}{time}};
      ${$table{$x}}{count} = scalar @{${$result}{$x}{time}};
      $min = min(@{${$result}{$x}{time}});
      $max = max(@{${$result}{$x}{time}});
      if ($max != $min) {
        ${$table{$x}}{avg} = ${$table{$x}}{count}*60/($max-$min);
      } else {
        ${$table{$x}}{avg} = ${$table{$x}}{count};
      }
      if ($min < ${$table{total}}{min}) {
        ${$table{total}}{min} = $min;
      }
      if ($max > ${$table{total}}{max}) {
        ${$table{total}}{max} = $max;
      }
      if (exists ${$result}{$x}{data}) {
        ${$table{total}}{data} += sum (@{${$result}{$x}{data}});
        ${$table{$x}}{data} = sum (@{${$result}{$x}{data}});
      } else {
        ${$table{$x}}{data} = 0;
      }
      for my $i (0..(scalar @{${$result}{$x}{status}} - 1)) {
        ${$table{total}}{ ${$result}{$x}{status}[$i] } += ${$result}{$x}{zdata}[$i];
        ${$table{$x}}{ ${$result}{$x}{status}[$i] } += ${$result}{$x}{zdata}[$i];
      }
    }
    ${$table{total}}{avg} = ${$table{total}}{count}*60/(${$table{total}}{max}-${$table{total}}{min});

    p %table;
    print "IP\tcount\tavg\tdata\t";
    my @statuses;
    for my $x (keys %{$table{total}}) {
      if (($x ne "avg")&&($x ne "count")&&($x ne "data")&&($x ne "max")&&($x ne "min")) {
        push @statuses, $x;
      }
    }
    @statuses = sort @statuses;
    for my $x (@statuses) {
      print "data_$x\t";
    }
    print "\n";

    print "total\t${$table{total}}{count}\t".(sprintf "%.0f", ${$table{total}}{avg})."\t";
    print (sprintf "%.0f", ${$table{total}}{data})."\t";
    for my $x (@statuses) {
      print "${$table{total}}{$x}\t";
    }
    print "\n";

    for my $i (0..9) {
      my $ip = $list[$i];
      print "$ip\t${$table{$ip}}{count}\t".(sprintf "%.0f", ${$table{$ip}}{avg})."\t";
      if (exists ${$table{$ip}}{data}) {
        print (sprintf "%.0f", ${$table{$ip}}{data})."\t";
      } else {
        print "0\t";
      }
      for my $x (@statuses) {
        if (exists ${$table{$ip}}{$x}) {
          print "${$table{$ip}}{$x}\t";
        } else {
          print "0\t";
        }
      }
      print "\n";
    }
}

sub mon {
  my $mon = shift;
  my $abbr = {Jan => 0, Feb => 1, Mar => 2, Apr => 3, May => 4, Jun => 5, Jul => 6, Aug => 7, Sep => 8, Oct => 9, Nov => 10, Dec => 11};
  return ${$abbr}{$mon};
}
