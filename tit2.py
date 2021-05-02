#! /usr/bin/env python3.9
import eyed3
import argparse

# parse args
parser = argparse.ArgumentParser(description='accumulate mp3 titles in cache file.')
parser.add_argument("dirs", default=['.'], nargs='*', help='source directories (default: [.])')
def_cache = 'tit2.cache'
parser.add_argument("--cachefile", default=def_cache, help='cache file (default: %s)' % def_cache)
parser.add_argument("--force", '-f', action='store_true', help='force cache update')
args = parser.parse_args()

# read cache file (if it exists)
cache = {}
cachefd = None
try:
  with open(args.cachefile, 'r') as cachefd:
    # read each line of the file, parse line, store in cache
    for record in cachefd:
      record = record.strip()
      # format of cache file: filename, colon, title
      # split the parts on first colon
      try:
        (filename, title) = record.split(':', 1)
        cache[filename.strip()] = title.strip()
      except ValueError:
        pass
except FileNotFoundError:
  print("no such file '%s', starting with a fresh cache" % args.cachefile)
  pass

# print(cache)

# read titles from all mp3 files
import glob
newcache = {}
for d in args.dirs:
  mp3files = glob.glob(d + "/*.mp3")
  for mp3file in mp3files:
    try:
      mp3 = eyed3.load(mp3file)
      newcache[mp3file] = mp3.tag.title
    except Exception as e:
      print("file %s got a %s exception (%s), skipping it." % (mp3file, type(e), e))

# if the new cache file is identical to the old one, nothing to do
if not args.force and cache == newcache:
  print("no new cache entries; not updating cache file %s" % args.cachefile)
  exit(0)
# write cache file
print("write new cache file %s" % args.cachefile)
try:
  with open(args.cachefile, 'w') as cachefd:
    for f in sorted(newcache.keys()):
      print("%s: %s" % (f, newcache[f]), file=cachefd)
      print("%s: %s" % (f, newcache[f]))
except Exception as e:
  print("opening/writing file %s, got exception %s (%s)." % (args.cachefile, type(e), e))

