use JSON::Mask;
use Test;

is-deeply mask('-a,b(c,d(e),f(-g))', %(a => 1, b => %(c => 2, d => %(e => 3, other => 4), f => %(g => 5, h => 6, i => 7)))),
        %(b => %(c => 2, d => %(e => 3), f => %(h => 6, i => 7)));

done-testing;
