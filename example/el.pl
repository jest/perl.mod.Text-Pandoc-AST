use v5.18;
use warnings;
use strict;

use Text::Pandoc::AST;
use JSON;
use IO::Any;

my $d = IO::Any->slurp(shift @ARGV // *STDIN);
my $jtree = JSON->new->utf8->decode($d);

my $ast = Text::Pandoc::AST->from_json_tree($jtree);

IO::Any->spew(shift @ARGV // *STDOUT, JSON->new->utf8->encode($ast->{elems}));
