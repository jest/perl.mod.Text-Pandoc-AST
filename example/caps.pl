use Text::Pandoc::Filters;

use warnings;
use strict;

my $flt = Text::Pandoc::Filters->new(sub {
  my ($k, $v) = @_;
  say STDERR $k;
  if ($k eq 'Str') {
    return { t => 'Str', c => uc $v }
  }

  undef;
});

$flt->to_json_filter
