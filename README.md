JSON::Mask
==========

Allows to filter JSON-like data so it's suitable for public consumption.
The pattern describes the schema, and the module trims the extra data.

To select several keys, just list them:

```perl6
# Select keys a, b, and c.
mask('a,b,c', %data);
```

To select all keys except a few, negate them:

```perl6
# Select all the keys that aren't a and in b.
mask('-a,-b', %data);
```

To select subkeys, use parentheses:

```perl6
# Keeps only a, and in it only its subkeys b and c.
mask('a(b,c)', %data);
```

You can of course combine them:

```perl6
# Select everything but the password, but only keeps the name and email subkeys from the profile
mask('-password,profile(name,email)');
```

If you want to reuse masks, you can pre-compile them:

```perl6
my $mask = compile-mask('a,b,c');
mask($mask, %data1);
mask($mask, %data2);
mask($mask, %data3);
```
