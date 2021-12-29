#! /usr/bin/env python3
import os
import xml.etree.ElementTree as ET
db = os.path.join(
  os.environ['HOME'],
  '.local',
  'share',
  'rhythmbox',
  'rhythmdb.xml'
)

tree = ET.parse(db)

root = tree.getroot()
print(".PHONY: TIT2")
print("TIT2:")
print("\ttrue")
for entry in root.findall('./entry'):
  hidden = entry.find('hidden')
  if hidden != None and hidden.text == '1':
    continue
  location = entry.find('location').text
  if location.startswith('file:///'):
    the_file = os.path.basename(location)
    title = entry.find('title').text
    print("\t[ -f %s ]" % (the_file))
    print("\tid3v2 --TIT2 \"%s\" \"%s\"" % (title, the_file))
