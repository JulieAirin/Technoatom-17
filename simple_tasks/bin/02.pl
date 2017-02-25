#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры:

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut

sub run {
    my ($x, $y) = @_;
    my @table = ();
    $table[1] = 0;
    for (my $i = 2; $i <= $y; $i++) {
      $table[$i] = $i;
    }
    for (my $i = 2; $i**2 <= $y; $i++) {
      for (my $j = $i**2; $j <= $y; $j += $i) {
        $table[$j] = 0;
      }
    }
    for (my $i = $x; $i <= $y; $i++) {
      if ($table[$i] != 0) {
        print "$i\n";
      }
    }
}

1;
