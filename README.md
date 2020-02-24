JSON::Mask
==========

Allows to filter JSON-like data so it's suitable for public consumption.
The pattern describes the schema, and the module trims the extra data.

### Basic Syntax

To select keys, list them in a comma-separated string:

```perl6
# Select keys `a`, `b`, and `c`.
mask('a,b,c', %data);
```

To select all keys except a few, negate them:

```perl6
# Select all the keys that aren't `a` or `b`.
mask('-a,-b', %data);
```

To select subkeys, use parentheses:

```perl6
# Keeps only `a`, and in it only its subkeys `b` and `c`.
mask('a(b,c)', %data);
```

You can of course combine them:

```perl6
# Select everything but `password`, but only keep the `name` and `email` subkeys from `profile`.
mask('-password,profile(name,email)', %data);
```

### Compilation

If you want to reuse masks, you can pre-compile them:

```perl6
my $mask = compile-mask('a,b,c');
mask($mask, %data1);
mask($mask, %data2);
mask($mask, %data3);
```

### Array handling

The module handles arrays without you needing to do anything -- a mask will be applied recursively on each element of the array.

```perl6
my $data =
    %(id => 1, name => "First Volume"),
    %(id => 2, name => "Second adventure"),
    %(id => 3, name => "Final Countdown")
  ],
mask('id', $data); # Select key `a` in each sub-hash
```

### Error handling

The module ignores missing keys.
It will however throw an exception if a nested key (`a(b,c)`) is not actually `Associative` (or `Positional`).
