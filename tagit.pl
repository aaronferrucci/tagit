use strict;
use warnings;
use tagit;

sub print_cache($)
{
  my %cache = %{shift()};

  # debug: print the cache
  print STDERR "\n#####\ncache:\n";
  for my $title (sort keys %cache) {
    print STDERR "'$title': '$cache{$title}'\n";
  }
  print STDERR "#####\n\n";
}

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
    if ($line =~ /(^[^:]*):\s*(.*)$/) {
      my $file = $1;
      my $title = $2;
      # get rid of any leading './'
      $file =~ s|^\./||;
      $cache{$file} = $title;
    }

  }
  close($cachefd)
}
# print_cache(\%cache);

# save each mp3 file's title (TIT2)
# to do: would it be useful to bundle everything into a single data structure?
my %titles;
my %blacklist;
my $debug_print;
{
  use lib('MP3-Tag-1.15/lib');
  use MP3::Tag;
  # blacklisted podcasts with missing or misleading titles
  my @blacklist = ("ACM ByteCast", "Freakonomics Radio", "On the Media", "Planet Money", "The Indicator from Planet Money", "What Bitcoin Did");
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

my $msg = "";

$msg .= << 'EOT';
.PHONY: all
all: cp TALB TCON TIT2

EOT

$msg .= << 'EOT';
# copy files
.PHONY: cp
cp:
EOT

for my $podcast (sort keys %db) {
  my $dir = "$podcastbase/$podcast";
  $msg .= join("", map {"\tcp \"$dir/$_\" .\n"} (sort @{$db{$podcast}}));
}
$msg .= << 'EOT';

# set album (TALB)
.PHONY: TALB
TALB:
EOT

for my $podcast (sort keys %db) {
  $msg .= join("", map {"\tid3v2 --TALB \"$podcast\" \"$_\"\n"} (sort @{$db{$podcast}}));
}

$msg .= << 'EOT';

# set content type (TCON)
.PHONY: TCON
TCON:
EOT

for my $podcast (sort keys %db) {
  $msg .= join("", map {"\tid3v2 --TCON Podcast \"$_\"\n"} (sort @{$db{$podcast}}));
}

# 'deploy' (copy podcasts into subdirectories)
# some podcasts need this treatment lest they show up as one
# directory per episode on the garmin watch
# experimentally determined, manually implemented here.
$msg .= << 'EOT';
.PHONY: deploy
deploy:
	mkdir -p 'Planet Money'
	-mv *pmoney* 'Planet Money'
	mkdir -p WBD
	-mv _WBD?* WBD?* WBD
	mkdir -p 'The Indicator'
	-mv *indic* 'The Indicator'
EOT

my $tit2_inc = "tit2.mk";
$msg .= "\ninclude $tit2_inc\n";

my $msg2 = "";
$msg2 .= << 'EOT';

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

    $msg2 .= "\t${comment}id3v2 --TIT2 \"$titles{$episode}\" \"$episode\"\n";
  }
}
# cache TIT2 entries
$msg2 .= "\t\$(PYTHON) ./tit2.py\n";

$msg .= << 'EOT';

# clean
.PHONY: clean
clean:
EOT

for my $podcast (sort keys %db) {
  $msg .= join("", map {"\trm -f \"$_\"\n"} (sort @{$db{$podcast}}));
}
$msg .= << "EOT";
\trm $tit2_inc
\trm Makefile
EOT

my $filename = 'Makefile';
open(my $fh, '>', $filename);
print $fh $msg;
close($fh);

open($fh, '>', $tit2_inc);
print $fh $msg2;
close($fh);
