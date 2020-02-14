use JSON::Mask;
use Test;

my $mask = compile-mask('a,c(1)');

is-deeply mask($mask, %(a => 1, b => 2, c => (1 => 0))),
        %(a => 1, c => %(1 => 0));

is-deeply mask($mask, %()), %();

done-testing;