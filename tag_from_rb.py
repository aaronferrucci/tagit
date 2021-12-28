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
for entry in root.findall('./entry'):
  hidden = entry.find('hidden')
  if hidden != None and hidden.text.encode('utf8') == b'1':
    continue
  location = entry.find('location').text.encode('utf8')
  if location.startswith(b'file:///'):
    title = entry.find('title').text.encode('utf8')
    print(title)
    print(location)
    print()
