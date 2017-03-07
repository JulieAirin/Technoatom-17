use FindBin;
use lib "$FindBin::Bin/lib";

use SecretSanta;
use DDP;

my @res = SecretSanta::calculate(('A', 'B', 'C', 'D'));
p @res;
my @res = SecretSanta::calculate( (['A', 'B'], ['C', 'D']));
p @res;
my @res = SecretSanta::calculate(('A', 'B', 'C'));
p @res;
my @res = SecretSanta::calculate((['A', 'B'], 'C'));
p @res;
my @res = SecretSanta::calculate(('A', 'B'));
p @res;
