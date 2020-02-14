use JSON::Mask;
use Test;

is-deeply mask('a(b,c)', %(a => %(b => 1, c => 2))),
        %(a => %(b => 1, c => 2));

is-deeply mask('a(b)', %(a => %(b => 1, c => 2))),
        %(a => %(b => 1));

is-deeply mask('a(b(c(d)))', %(a => %(b => %(c => %(d => 0))))),
        %(a => %(b => %(c => %(d => 0))));

is-deeply mask('-a,b(c,d)', %(a => 1, b => %(a => 1, b => 2, c => 3, d => 4), c => 3)),
        %(b => %(c => 3, d => 4), c => 3);

is-deeply mask('a(b,c)', %()), %();

throws-like { mask('a()', %()) },
        Exception, message => /"Invalid empty nested rule"/;

throws-like { mask('a(b,c)', %(a => 1)) },
        Exception, message => /"Nested value for a doesn't have the right shape"/;

throws-like { mask('-a(b,c)', %(a => 1)) },
        Exception, message => /"Cannot have a nested negative group"/;

throws-like { mask('a(b),a', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('a(b),a(b)', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('a(b),-a', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('a(b(c(d,d))', %()) },
        Exception, message => /"Key d already present in a.b.c"/;

done-testing;
