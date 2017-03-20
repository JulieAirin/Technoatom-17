package DeepClone;

use 5.010;
use strict;
use warnings;
use DDP;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

my $allisok = 1;
my %arefs; # {$orig => $cloned}
my %hrefs;

sub clone {
	my $orig = shift;
	my $cloned;

	say "ORIGINAL ", Dumper($orig);
	say "CLONED   ", Dumper($cloned);
	#p %arefs;
	#p %hrefs;

	if (ref($orig) eq 'ARRAY') {
		if (exists $arefs{$orig}) {
			$cloned = $arefs{$orig};
		} else {
			for my $x (@{$orig}) {
				$arefs{$orig} = $cloned;
				push @{$cloned}, clone($x);
			}
			$arefs{$orig} = $cloned;
		}
	} elsif (ref($orig) eq 'HASH') {
		if (exists $hrefs{$orig}) {
			$cloned = $hrefs{$orig};
		} else {
			for my $x (keys %{$orig}) {
				$hrefs{$orig} = $cloned;
				${$cloned}{$x} = clone(${$orig}{$x});
			}
			$hrefs{$orig} = $cloned;
		}
	} elsif (ref(\$orig) eq 'SCALAR') {
		$cloned = $orig;
	} elsif (!$orig) {
		$cloned = undef;
	} else {
		$allisok = 0;
	}

	if ($allisok)	{
		return $cloned;
	} else {
		return undef;
	}
}

1;
