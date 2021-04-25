use strict;
use warnings;
use tagit;

use lib('MP3-Tag-1.15/lib');
use MP3::Tag;

# For now, "current directory". Means this is runnable only from "here".
my $mp3_dir = '.';

my $dir = open_or_die($mp3_dir);
my @mp3s = grep {not /^\.{1,2}$/ and /\.mp3$/i} readdir $dir;
closedir $dir;

for my $mp3file (@mp3s) {
  my $mp3 = MP3::Tag->new($mp3file);
  $mp3->get_tags;
  my $title = $mp3->{ID3v2} && $mp3->{ID3v2}->get_frame("TIT2") || "";
  print "$mp3file: $title\n";
}
