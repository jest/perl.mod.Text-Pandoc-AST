package Text::Pandoc::AST::El;

sub from_json_object {
  my ($jobj) = @_;

}

my %DEFS = (
  'Str' => [
    v => 'string'
  ],
  'Space' => [ ],
  'Para' => [
    elems => '[Inline]'
  ]
);
my %CLASSES = (
  Inline => [ map { $_ => 1 }
    qw/ Str Space / ],
  Block => [ map { $_ => 1 }
    qw/ Para / ]
);

sub from_json_object {
  my ($jobj, $class) = @_;
  my $def = $DEFS{$jobj->{t}};
  warn "Unknown type $jobj->{t}" and return
    unless defined $def;

  if ($class) {
    warn "Element $jobj->{t} is not of class $class" and return undef
      unless $jobj->{t} eq $class || exists $CLASSES{$class}{$jobj->{t}};
  }

  my $el = el($def, $jobj->{c}) or return;
  $el->{t} = $jobj->{t};

  $el;
}

sub el {
  my ($defs, $data) = @_;
  if (@$defs == 0) {
    if (ref $data eq 'ARRAY' && @$data == 0) {
      return { }
    }
    warn "Expected empty array";
    return undef;
  } elsif (@$defs == 2 && $defs->[1] eq 'string') {
    if (ref $data ne '') {
      warn "Expected simple scalar";
      return undef;
    }
    $data = [ $data ];
  }
  if (2 * @$data != @$defs) {
    warn "Expected " . int(@$defs) . " elements but got " . int(@$data);
    return undef;
  }
  my $obj = { };
  for my $jval (@$data) {
    my $key  = shift @$def;
    my $type = shift @$def;

    $obj->{$key} = decode_type($type, $jval);
  }
  return $obj;
}

sub decode_type {
  my ($jtype, $jval) = @_;
  if ($jtype eq 'string') {
    warn "Expected simple scalar" and return undef
      unless ref $jval eq '';
    return $jval;
  } elsif ($jtype =~ /^[A-Z]/) {
    return from_json_object($jval, $jtype);
  } elsif ($jtype =~ /^\[(.*)\]$/) {
    my $class = $1;
    warn "Expected array ref" and return undef
      unless ref $jval eq 'ARRAY';
    return [
      map { from_json_objects($_, $class) } @$jval
    ];
  } else {
    warn "Can't decode type $jtype";
  }
}
