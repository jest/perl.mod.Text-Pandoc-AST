package Text::Pandoc::AST;

use v5.10;

use warnings;
use strict;

use Text::Pandoc::AST::El;

our $VERSION = '0.001';

sub from_json_tree {
	my ( $class, $jtree ) = @_;
	my @elems = map {
		Text::Pandoc::AST::El::from_json_object($_)
	} @{ $jtree->[1] };
	return bless {
		elems => \@elems
	}, $class;
}

1;

__END__

=encoding UTF-8

=head1 NAME

Text::Pandoc::AST - Pandoc AST structure parsing and walking

=head1 SYNOPSIS

As the software is in the pre-alpha state and everything can change, this is
just my imagination of the future API.

  use JSON 2.90;
  use Text::Pandoc::AST;

  my $jtree = JSON->new->utf8->decode($json_text);
  my $ast = Text::Pandoc::AST->from_json($jtree);
  
  # and possibly use it with Text::Pandoc::Filters
  
  my $filter = Text::Pandoc::Filters->new(\&filter_sub);
  my $modified_ast = $filter->walk($ast);

  print JSON->new->utf8->encode($modified_ast->to_json);

=head1 DESCRIPTION

This class simplifies parsing JSON structure, as provided by C<pandoc -t json> command. 

=head1 SEE ALSO

L<Text::Pandoc::Filters> - for easy writing Pandoc tree modifying filters.

L<http://johnmacfarlane.net/pandoc/scripting.html> - Pandoc filters docs.

L<https://github.com/jgm/pandocfilters> - pandocfilters Python project, by
which this module is inspired.

=head1 AUTHOR

Przemyslaw Wesolek <jest@go.art.pl>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Przemyslaw Wesolek.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
