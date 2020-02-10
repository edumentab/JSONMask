use JSON::Mask;
use Test;

is-deeply mask('-a', %(a => 1)), %();
is-deeply mask('-d', %(a => 1, b => 2, c => 3)), %(a => 1, b => 2, c => 3);
is-deeply mask('-a,-b', %(a => 1, b => 2, c => 3)), %(c => 3);
is-deeply mask('-"weird key"', %(a => 1, "weird key" => 0)), %(a => 1);

throws-like { mask('-a,-a', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('a,-a', %()) },
        Exception, message => /"Cannot have a negative rule after a positive rule"/;

throws-like { mask('-a,a', %()) },
        Exception, message => /"Cannot have a positive rule after a negative rule"/;

done-testing;
