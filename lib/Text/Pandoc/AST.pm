package Text::Pandoc::AST;

use v5.10;

use warnings;
use strict;

use Text::Pandoc::AST::El;

our $VERSION = '0.001';

sub from_json_tree {
  my ($class, $jtree) = @_;
  my @elems = map {
    Text::Pandoc::AST::El::from_json_object($_);
  } @{$jtree->[1]};
  return bless {
    jtree => $jtree,
    elems => \@elems
  }, $class;
}

sub to_json_tree {
  my ($self) = @_;
  return $self->{jtree};
}

1;
