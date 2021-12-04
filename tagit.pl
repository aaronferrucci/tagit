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

# read the cache file, if any
my $cachefile = 'tit2.cache';
my %cache;
if (open(my $cachefd, "<", $cachefile)) {
  while (my $line = <$cachefd>) {
    chomp($line);
    if ($line =~ /(^.*):\s*(.*)$/) {
      my $file = $1;
      my $title = $2;
      # get rid of any leading './'
      $file =~ s|^\./||;
      $cache{$file} = $title;
    }

  }
  close($cachefd)
}

sub print_cache($)
{
  my %cache = %{shift()};

  # debug: print the cache
  print STDERR "\n#####\ncache:\n";
  for my $title (sort keys %cache) {
    if ($title =~ /20210616_indicator_housing_ready_to_publish.mp3_b2a4d5ed9f3f1a8ee6bc1364dcada9ef_9475212.mp3/) {
      print STDERR "founding _housing_: $title: $cache{$title}\n";
    }
  }
  print STDERR "#####\n\n";
}

print_cache(\%cache);

# save each mp3 file's title (TIT2)
# to do: would it be useful to bundle everything into a single data structure?
my %titles;
my %blacklist;
my $debug_print;
{
  use lib('MP3-Tag-1.15/lib');
  use MP3::Tag;
  # blacklisted podcasts with missing or misleading titles
  my @blacklist = ("ACM ByteCast", "On the Media", "Planet Money", "The Indicator from Planet Money");
  for my $podcast (sort keys %db) {
    my $dir = "$podcastbase/$podcast";
    my $blacklisted = grep {/$podcast/} @blacklist;
    for my $episode (sort @{$db{$podcast}}) {
      $blacklist{$episode} = $blacklisted;
      $titles{$episode} = "";
      if (!$blacklisted) {
        my $mp3file = "$dir/$episode";
        my $mp3 = MP3::Tag->new($mp3file);
        $mp3->get_tags;
        $titles{$episode} =
          $mp3->{ID3v2} && $mp3->{ID3v2}->get_frame("TIT2") || "";
      } else {
        # use cached title, if found
        print STDERR "cached value for episode '$episode': '$cache{$episode}'\n";
        if ($cache{$episode}) {
          print STDERR "found title for '$episode' in cache, using it\n";
          $titles{$episode} = $cache{$episode};
        } else {
          print STDERR "no title for '$episode' in cache, it's up to you\n";
          if (not $debug_print) {
            print_cache(\%cache);
          }

        }
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
# Use venv python
# Assumption: it's been set up ("python3 -m venv tagit_venv"),
# and any needed packages have been installed inside it ("pip install eyed3")
PYTHON := ./tagit_venv/bin/python
.PHONY: TIT2
TIT2:
EOT

for my $podcast (sort keys %db) {
  for my $episode (sort @{$db{$podcast}}) {
    # need to update the podcast title if it's blacklisted, or if the
    # title is empty.
    # Why update if it's blacklisted but non-empty? The title came from the
    # cache, and is not in the mp3 file (yet).
    my $comment = '# ';
    $comment = "" if $titles{$episode} eq "" or $blacklist{$episode};

    print "\t${comment}id3v2 --TIT2 \"$titles{$episode}\" \"$episode\"\n";
  }
}
# cache TIT2 entries
print "\t\$(PYTHON) ./tit2.py\n";

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


