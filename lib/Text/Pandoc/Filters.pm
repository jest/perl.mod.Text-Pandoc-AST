package Text::Pandoc::Filters;

use warnings;
use strict;

use v5.10;
use Scalar::Util qw/ reftype /;
use JSON 2.90;

our $VERSION = '0.001';

sub new {
  my ($class, $action) = @_;
  return bless {
    action => $action
  }, $class;
}

sub walk {
  my ($self, $x) = @_;
  my $t_x = reftype $x;
  return $x unless defined $t_x;
  if ($t_x eq 'ARRAY') {
    my $arr = [ ];
    for my $item (@$x) {
      if (reftype($item) eq 'HASH' && exists $item->{t}) {
        # make an action on the item and, depending on
        # returned value, do different things to the tree
        my $res = $self->{action}($item->{t}, $item->{c});
        if (!defined $res) {
          push @$arr, $self->walk($item);
        } elsif (defined reftype($res) && reftype($res) eq 'ARRAY') {
          push @$arr, map { $self->walk($_) } @$res;
        } else {
          push @$arr, $self->walk($res);
        }
      } else {
        push @$arr, $self->walk($item);
      }
    }
    return $arr;
  } elsif ($t_x eq 'HASH') {
    return { map { $_ => $self->walk($x->{$_}) } keys %$x };
  } else {
    return $x;
  }
}

sub to_json_filter {
  my ($self, $fh_in, $fh_out) = @_;
  $fh_in  //= \*STDIN;
  $fh_out //= \*STDOUT;

  my $txt = do { local $/; <$fh_in> };
  my $json = JSON->new->utf8;
  my $doc = $json->decode($txt);
  my $mod_doc = $self->walk($doc);
  print $fh_out $json->encode($mod_doc);
}

1;

__END__

=encoding UTF-8

=head1 NAME

Text::Pandoc::Filters - Writing Pandoc filters in Perl simplified

=head1 SYNOPSIS

As the software is in the alpha state and everything can change, this is
just my imagination of the future API.

  use Text::Pandoc::Filters;

  my $filter = Text::Pandoc::Filters->new(\&filter_sub);

  # work on previously read Pandoc AST structures...
  my $modified_ast = $filter->walk($ast);

  # ... or simply read AST from a filehandle and write to the other one
  $filter->transform_json($fh_in, $fh_out);

  # ... or even assume STDIN/STDOUT
  $filter->transform_json;

=head1 DESCRIPTION

This class provides a simple way of writing filters for Pandoc. If the file F<filter.pl> is as simple as:

  #!/usr/bin/env perl
  use Text::Pandoc::Filters;
  Text::Pandoc::Filters->new(sub {
    my ($k, $v) = @_;
    return Text::Pandoc::Str->new(uc $v) if $k isa 'Text::Pandoc::Str';
  })->transform_json;

it can be used with pandadoc as a filter that changes all regular text
to uppercase

  pandoc -f SOURCEFORMAT -t TARGETFORMAT --filter ./filter.pl

=head1 SEE ALSO

L<http://johnmacfarlane.net/pandoc/scripting.html> - Pandoc filters docs.

L<https://github.com/jgm/pandocfilters> - pandocfilters Python project, on
which this module is based.

=head1 AUTHOR

Przemyslaw Wesolek <jest@go.art.pl>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Przemyslaw Wesolek.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
