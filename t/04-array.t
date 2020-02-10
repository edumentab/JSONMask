use JSON::Mask;
use Test;

is-deeply mask('a(b)', %(a => $(%(b => 1, other => 1), %(b => 2, other => 2), %(b => 3, other => 3)))),
            %(a => $(%(b => 1), %(b => 2), %(b => 3)));