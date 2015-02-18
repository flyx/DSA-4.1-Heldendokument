#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ./wallpaper.py <input-mustache> <parameter-yaml> <output-tex>

import sys, yaml, codecs, pystache

if len(sys.argv) != 4:
    print "needs 3 arguments!"
    sys.exit(2)

with codecs.open(sys.argv[2], 'r', 'utf-8') as f:
    params = yaml.load(f)
    if not params.has_key('Hintergrund'):
        print '"Hintergrund" fehlt in Parameter-Datei!'
        sys.exit(2)
    hintergrund = params['Hintergrund']
    values = {}
    for key, default in [('Hochformat', 'wallpaper.jpg'), ('Querformat', 'wallpaper-landscape.jpg')]:
        if isinstance(hintergrund[key], bool):
            if hintergrund[key]:
                values[key] = default
            else:
                values[key] = False
        else:
            values[key] = hintergrund[key]

    with codecs.open(sys.argv[1], 'r', encoding='utf-8') as source:
        template = source.read()
        rendered = pystache.render(template, values)
        with codecs.open(sys.argv[3], 'w', encoding='utf-8') as dest:
            dest.write(rendered)