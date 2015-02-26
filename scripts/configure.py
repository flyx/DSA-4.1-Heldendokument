#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ./configure.py <input-mustache> <parameter-yaml> <name of parameter group in yaml> <output-tex>

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
                values[key] = 1 if value else 0
        if params.has_key('Layout'):
            for seite in ['Links', 'Rechts']:
                values[seite] = []
                for key, value in [v.iteritems().next() for v in params['Layout'][seite]]:
                    if key == u'Sonderfertigkeiten':
                        values[seite].append(u'\\Sonderfertigkeiten{{{}}}'.format(value))
                    elif key == u'Sonstiges':
                        values[seite].append(u'\\Sonstiges[{}]{{{}}}'.format(value['Titel'], value['Zeilen']))
                    elif key == u'Kampftechniken':
                        values[seite].append(u'\\Kampftechniken{{{}}}'.format(value))
                    elif key == u'Körperliche Talente':
                        values[seite].append(u'\\KoerperlicheTalente{{{}}}'.format(value))
                    elif key == u'Gesellschaftliche Talente':
                        values[seite].append(u'\\GesellschaftlicheTalente{{{}}}'.format(value))
                    elif key == u'Naturtalente':
                        values[seite].append(u'\\NaturTalente{{{}}}'.format(value))
                    elif key == u'Wissenstalente':
                        values[seite].append(u'\\WissensTalente{{{}}}'.format(value))
                    elif key == u'Sprachen und Schriften':
                        values[seite].append(u'\\SprachenSchriften{{{}}}'.format(value))
                    elif key == u'Handwerkliche Talente':
                        values[seite].append(u'\\HandwerklicheTalente{{{}}}'.format(value))
                    elif key == u'Abstand':
                        values[seite].append(u'\\vspace{{{}pt}}'.format(value))
                    else:
                        print 'Unbekanntes Layoutelement: {}'.format(key)
                        sys.exit(2)

        if params.has_key('Seiten'):
            # mustache kann keinen for-loop => generiere Liste von Indices
            values['Seiten'] = range(1, params['Seiten'] + 1)
        with codecs.open(sys.argv[1], 'r', encoding='utf-8') as source:
            template = source.read()
            rendered = pystache.render(template, values)
            with codecs.open(sys.argv[4], "w", encoding="utf-8") as dest:
                dest.write(rendered)
