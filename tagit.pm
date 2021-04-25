sub open_or_die($)
{
  my $dir = shift;  
  opendir my $DH, $dir or die "Can't open directory '$dir'";
  return $DH;
}

"True";
