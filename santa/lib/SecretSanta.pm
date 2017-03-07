package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	my @list = @members;
	my %pairs;
	for my $i (0..$#members) {
		if (ref($members[$i]) eq 'ARRAY') {
			$list[$i] = $members[$i][0];
			push @list, $members[$i][1];
			$pairs{$i} = $#list;
			$pairs{$#list} = $i;
		}
	}
	print $#members;
	print $#list;
	if (($#members < 2) && ($#list < 3)) {
		return @res;
	}
	my @num = 0..$#list;
	my $ok = 0;
	while (!$ok) {
		@num = sort { int(rand(3))-1 } @num;
		$ok = 1;
		for my $i (0..$#num) {
			if ( ((exists $pairs{$i}) && ($pairs{$i} == $num[$i])) || ($i == $num[ $num[$i] ]) ) {
				$ok = 0;
				last;
			}
		}
	}
	for my $i (0..$#num) {
		push @res,[ $list[$i], $list[ $num[$i] ] ];
	}
	return @res;
}

1;
