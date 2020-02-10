use JSON::Mask;
use Test;

is-deeply mask('a', %(a => 1)), %(a => 1);
is-deeply mask('a,b,c', %(a => 1, b => 2, c => 3)), %(a => 1, b => 2, c => 3);
is-deeply mask('a,b', %(a => 1, b => 2, c => 3)), %(a => 1, b => 2);
is-deeply mask('a', %(a => 1, b => 2, c => 3)), %(a => 1);

is-deeply mask('other', %(a => 1, b => 2, c => 3)), %();
is-deeply mask('a,"weird key"', %(a => 1, "weird key" => 0)), %(a => 1, "weird key" => 0);

throws-like { mask('a,a', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('a,"a"', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('"a",a', %()) },
        Exception, message => /"Key a already present"/;

throws-like { mask('"a","a"', %()) },
        Exception, message => /"Key a already present"/;

done-testing;
