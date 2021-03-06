package Anagram;

use 5.010;
use strict;
use warnings;
use DDP;
use Encode;
use utf8;
use List::MoreUtils qw/uniq/;

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
    my $words_list = shift;
    my %result;
    my %preresult;
    my $key;
    my @uniq;

    for my $x (@{$words_list}) {
      $x = lc (decode('utf8',$x));
      $x = lc $x;
      my $charstr = join '', sort split '', $x;
      push @{ $preresult{$charstr} }, encode('utf8', $x);
    }

    for my $x (keys %preresult) {
      $key = $preresult{$x}[0];
      @uniq = uniq @{$preresult{$x}};
      if (scalar @uniq > 1) {
        @{$result{$key}} = sort @uniq;
      }
    }
    return \%result;
}

1;
