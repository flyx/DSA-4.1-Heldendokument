#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ./configure.py <eingabe-mustache> <parameter-yaml> <name of parameter group in yaml> <output-tex>

import sys, yaml, codecs, pystache

if len(sys.argv) != 5:
    print "needs 4 arguments!"
    sys.exit(2)

with codecs.open(sys.argv[2], 'r', 'utf-8') as f:
    ef = yaml.load(f)
    name = sys.argv[3].decode('utf-8')
    if ef.has_key(name):
        params = ef[name]
        values = {}
        if params.has_key('Zeilen'):
            for key, value in params['Zeilen'].iteritems():
                values[key] = value
        if params.has_key('Optionen'):
            for key, value in params['Optionen'].iteritems():
                values[key] = value
        if params.has_key('Text'):
            for key, value in params['Text'].iteritems():
                values[key] = value
        if params.has_key('Seiten'):
            # mustache kann keinen for-loop => generiere Liste von Indices
            values['Seiten'] = range(1, params['Seiten'] + 1)
        with codecs.open(sys.argv[1], 'r', encoding='utf-8') as of:
            template = of.read()
            rendered = pystache.render(template, values)
            with codecs.open(sys.argv[4], "w", encoding="utf-8") as dest:
                dest.write(rendered)