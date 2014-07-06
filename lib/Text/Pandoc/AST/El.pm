package Text::Pandoc::AST::El;

use warnings;
use strict;
use Readonly;
use List::AllUtils qw/ pairwise /;

Readonly::Hash my %DEFS => (
  'Meta' => sub { return $_[0]->{unMeta} }, # not yet implemented
  'Str' => [
    [ v => '$' ]
  ],
  'Space' => [ ],
  Plain => [
  	[ txt => '[]' ]
  ],
  Para  => [
    [ txt => '[]' ]
  ],
  Header => [
  	[ level => '$' ],
  	[ attrs => 'attr' ],
  	[ txt   => '[]' ]
  ],
  CodeBlock => [
  	[ attrs => 'attr' ],
  	[ v     => '$'    ]
  ],
  BulletList => [
  	[ items => sub {
  		my ($jval) = @_;
  		return [ map { decode_type('[]', $_) } @$jval ];
  	} ]
  ],
  Code => [
  	[ attrs => 'attr' ],
  	[ v     => '$'    ]
  ],
  
  # types
  attr => [
  	[ id      => '$'  ],
  	[ classes => '@' ],
  	[ other   => '@' ]
  ]
);

sub error_el {
	my ($msg, $jobj) = @_;
	return {
		t => 'Error',
		err_msg => $msg,
		jobj => $jobj
	};
}

sub from_json_object {
  my ($jobj) = @_;
  
  if ($jobj->{t} eq 'BulletList') {
  	warn;
  }
  if (ref $jobj ne 'HASH') {
  	die;
  }
  my $def = $DEFS{$jobj->{t}};
  return error_el("Unknown type $jobj->{t}", $jobj) unless defined $def;

  my $el = el($def, $jobj->{c}) or return;
  $el->{t} = $jobj->{t} unless exists $el->{t};

  $el;
}

sub from_json_type {
	my ($jobj, $jtype) = @_;
	my $def = $DEFS{$jtype} or die "Unknown type is specification: $jtype";
	
	return el($def, $jobj);
}

sub el {
  my ($defs, $data) = @_;
  if (@$defs == 0) {
    return (ref $data eq 'ARRAY' && @$data == 0) ? { } : error_el("Expected empty array", $data);
  } elsif (@$defs == 1) {
    $data = [ $data ];
  }
  if (@$data != @$defs) {
  	return error_el("Expected " . int(@$defs) . " elements but got " . int(@$data), $data);
  }
  my %obj = pairwise { $a->[0] => decode_type($a->[1], $b) } @$defs, @$data;
  return \%obj;
}

sub decode_type {
  my ($jtype, $jval) = @_;
  if (ref $jtype eq 'CODE') {
  	return $jtype->($jval);
  } elsif ($jtype eq '$') {
  	return (ref $jval eq '') ? $jval : error_el("Expected simple scalar", $jval);
  } elsif ($jtype eq '@') {
  	return (ref $jval eq 'ARRAY') ? $jval : error_el("Expected array ref", $jval);
  } elsif ($jtype eq '[]') {
    return (ref $jval eq 'ARRAY')
    	? [ map { from_json_object($_) } @$jval ]
    	: error_el("Expected array ref", $jval);
  } elsif ($jtype =~ /^[A-Z]/) {
    return from_json_object($jval);
  } elsif ($jtype =~ /^[a-z]/) {
  	return from_json_type($jval, $jtype);
  } else {
    return error_el("Can't decode type $jtype", $jval);
  }
}
