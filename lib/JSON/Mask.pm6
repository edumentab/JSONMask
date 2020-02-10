module AST { }

class AST::Rule is repr('Uninstantiable') { }

class AST::Rule::Positive is AST::Rule {
    has Str $.key;
}

class AST::Rule::Negative is AST::Rule {
    has Str $.key;
}

class AST::Rule::Nested is AST::Rule {
    has Str $.key;
    has $.pattern; # AST::Pattern:D TODO type it when Comma recognizes stub
}

class AST::Pattern {
    has AST::Rule:D @.rules;

    method positives { @!rules.grep(AST::Rule::Positive) }
    method negatives { @!rules.grep(AST::Rule::Negative) }
    method nesteds { @!rules.grep(AST::Rule::Nested) }
}

class X::ParseFail is Exception {
    has Str $.reason is required;
    has Cursor $.cursor is required;

    method message() {
        "JSON Mask parse failed: $!reason at line $.line near '$.near'"
    }

    method line() {
        $!cursor.orig.substr(0, $!cursor.pos).split(/\n/).elems
    }

    method near() {
        $!cursor.orig.substr($!cursor.pos, 40)
    }
}

grammar Mask {
    token TOP {
        :my @*stack;
        <pattern>
    }

    token pattern {
        :my $*has-seen-positive = False;
        :my $*has-seen-negative = False;
        :my @*seen-keys;
        <rule>+ %% ','
    }

    proto token rule { * }

    token rule:positive {
        <key> {}
        [ '()' <.panic: "Invalid empty nested rule">
        || '(' ~ ')' [ :temp @*stack; { push @*stack, $<key>.made } <pattern> ]
        || <?{ $*has-seen-negative }> <.panic: "Cannot have a positive rule after a negative rule">
        || { $*has-seen-positive = True; } ]
        { self.check-seen($<key>.made) }
    }

    token rule:negative {
        '-' <key>
        [ <?{ $*has-seen-positive }> <.panic: "Cannot have a negative rule after a positive rule">
        || { $*has-seen-negative = True; } ]
        { self.check-seen($<key>.made) }
        [ <?before '('> <.panic: "Cannot have a nested negative group"> ]?
    }

    method check-seen(Str $key) {
        if $key (elem) @*seen-keys {
            self.panic("Key $key already present");
        }
        @*seen-keys.push: $key;
    }

    proto token key { * }
    token key:simple { \w+ }
    token key:quoted { '"' ~ '"' (<-["]>+) } # TODO escapes

    method panic($reason is copy) {
        $reason ~= ' in ' ~ @*stack.join('.') if @*stack;
        die X::ParseFail.new(reason => $reason ~ (' in ' ~ @*stack.join('.') if @*stack),
                             :cursor(self));
    }
}

class MaskActions {
    method TOP($/) {
        make $<pattern>.made
    }

    method pattern($/) {
        make AST::Pattern.new(rules => $<rule>>>.made)
    }

    method rule:positive ($/) {
        if $<pattern> {
            make AST::Rule::Nested.new(key => $<key>.made, pattern => $<pattern>.made)
        } else {
            make AST::Rule::Positive.new(key => $<key>.made)
        }
    }

    method rule:negative ($/) {
        make AST::Rule::Negative.new(key => $<key>.made)
    }

    method key:simple ($/) { make ~$/ }
    method key:quoted ($/) { make ~$0 }
}

multi sub evaluate(AST::Pattern $pattern, @data) {
    # Pair code commented out as this format isn't JSON-like. Might be revisited.
    #return evaluate($pattern, %@data) if all(@data) ~~ Pair;
    @data.map({ evaluate($pattern, $_) }).List;
}

multi sub evaluate(AST::Pattern $pattern, %data) {
    my %scooped;
    if $pattern.negatives -> @negatives {
        %scooped = %data{keys %data.keys (-) @negatives.map(*.key)}:kv;
    } elsif $pattern.positives -> @positives {
        %scooped = %data{@positives.map(*.key)}:kv;
    }

    for $pattern.nesteds -> AST::Rule::Nested $nested {
        with %data{$nested.key} -> \value {
            @*stack.push: $nested.key;
            unless value ~~ Positional | Associative {
                die "Nested value for $(@*stack.join: '.') doesn't have the right shape under"
            }
            %scooped{$nested.key} = evaluate($nested.pattern, value)
        }
    }

    %scooped
}

sub mask(Str $mask, \data) is export {
    with Mask.parse($mask, :actions(MaskActions.new)) {
        my @*stack;
        evaluate(.made, data)
    } else {
        die "Unable to parse JSON Mask";
    }
}