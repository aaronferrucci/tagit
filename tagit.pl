use strict;
use warnings;
use tagit;

my $podcastbase = "$ENV{HOME}/Music";

my $dir = open_or_die($podcastbase);
my @srcdirs = grep {not /^\.{1,2}$/} readdir $dir;
closedir $dir;
my %db = map {$_ => []} @srcdirs;

for my $podcast (keys %db) {
  my $podcastdir = $podcastbase . "/" . $podcast;
  my $fd = open_or_die($podcastdir);
  my @mp3s = grep {not /^\.{1,2}$/} readdir $fd;
  closedir $fd;
  push @{$db{$podcast}}, @mp3s;
}

# save each mp3 file's title (TIT2)
# to do: would it be useful to bundle everything into a single data structure?
my %titles;
{
  use lib('MP3-Tag-1.15/lib');
  use MP3::Tag;
  # blacklisted podcasts with missing or misleading titles
  my @blacklist = ("On the Media", "Planet Money");
  for my $podcast (sort keys %db) {
    my $dir = "$podcastbase/$podcast";
    my $blacklisted = grep {/$podcast/} @blacklist;
    for my $episode (sort @{$db{$podcast}}) {
      $titles{$episode} = "";
      if (!$blacklisted) {
        my $mp3file = "$dir/$episode";
        my $mp3 = MP3::Tag->new($mp3file);
        $mp3->get_tags;
        $titles{$episode} =
          $mp3->{ID3v2} && $mp3->{ID3v2}->get_frame("TIT2") || "";
      }
    }
  }
}

print << 'EOT';
.PHONY: all
all: cp TALB TCON

EOT

print << 'EOT';
# copy files
.PHONY: cp
cp:
EOT

for my $podcast (sort keys %db) {
  my $dir = "$podcastbase/$podcast";
  print map {"\tcp \"$dir/$_\" .\n"} (sort @{$db{$podcast}});
}
print << 'EOT';

# set album (TALB)
.PHONY: TALB
TALB:
EOT

for my $podcast (sort keys %db) {
  print map {"\tid3v2 --TALB \"$podcast\" \"$_\"\n"} (sort @{$db{$podcast}});
}

print << 'EOT';

# set content type (TCON)
.PHONY: TCON
TCON:
EOT

for my $podcast (sort keys %db) {
  print map {"\tid3v2 --TCON Podcast \"$_\"\n"} (sort @{$db{$podcast}});
}
print << 'EOT';

# set title (TIT2) - not auto-run, to be manually modified
.PHONY: TIT2
TIT2:
EOT

for my $podcast (sort keys %db) {
  for my $episode (sort @{$db{$podcast}}) {
    my $comment = $titles{$episode} ne "" ? "# " : "";

    print "\t${comment}id3v2 --TIT2 \"$titles{$episode}\" \"$episode\"\n";
  }
}
# cache TIT2 entries
print "\tperl tit2.pl >> tit2.cache\n";

print << 'EOT';

# clean
.PHONY: clean
clean:
EOT

for my $podcast (sort keys %db) {
  print map {"\trm -f \"$_\"\n"} (sort @{$db{$podcast}});
}
print << "EOT";
\trm Makefile
EOT


