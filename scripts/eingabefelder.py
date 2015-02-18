#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ./eingabefelder.py <input-yaml> <output-tex>

import sys, yaml, yaml.nodes, yaml.constructor, codecs
from unidecode import unidecode
from string import maketrans

if len(sys.argv) != 3:
    print "needs 2 arguments!"
    sys.exit(2)


class Liste(yaml.YAMLObject):
    yaml_tag = u"!liste"

    @classmethod
    def from_yaml(cls, loader, node):
        if not isinstance(node, yaml.nodes.MappingNode):
            raise yaml.constructor.ConstructorError(None, None, "!liste muss ein Mapping sein, aber ist ein %s" % node.id, node.start_mark)
        zeilen = None
        felder = {}
        for key, value in node.value:
            if not isinstance(key, yaml.nodes.ScalarNode):
                raise yaml.constructor.ConstructorError("Beim Erstellen einer !liste", node.start_mark, "Name muss ein Skalar sein, aber ist ein %s" % key.id, key.start_mark)
            name = loader.construct_scalar(key)
            if name == u"Zeilen":
                if not isinstance(value, yaml.nodes.MappingNode):
                    raise yaml.constructor.ConstructorError("Beim Erstellen einer !liste", node.start_mark, "Zeilen muss ein Mapping sein, aber ist ein %s" % value.id, value.start_mark)
                zeilen = loader.construct_pairs(value)
            else:
                if not isinstance(value, yaml.nodes.ScalarNode):
                    raise yaml.constructor.ConstructorError("Beim Erstellen einer !liste", node.start_mark, "Template %s muss ein Skalar sein, aber ist ein %s" % (name, value.id), value.start_mark)
                template = loader.construct_object(value)
                felder[name] = template
        if zeilen is None:
            raise yaml.constructor.ConstructorError(None, None, "!liste muss einen Schlüssel namens Zeilen enthalten!", node.start_mark)
        return cls(zeilen, felder)

    def __init__(self, zeilen, felder):
        self.zeilen = zeilen
        self.felder = felder

class Mehrfach(yaml.YAMLObject):
    yaml_tag=u"!mehrfach"

    @classmethod
    def from_yaml(cls, loader, node):
        if not isinstance(node, yaml.nodes.ScalarNode):
            raise yaml.constructor.ConstructorError(None, None, "!mehrfach muss ein Skalar sein, aber ist ein %s" % node.id, node.start_mark)
        return cls(loader.construct_scalar(node))

    def __init__(self, template):
        self.template = template

def texify(string):
    if isinstance(string, str):
        return unidecode(string.decode('utf-8')).translate(maketrans('1234567890', 'abcdefghij'), '!/ .-:&(){}')
    return unidecode(string).translate(maketrans('1234567890', 'abcdefghij'), '!/ .-:&(){}')

def transform(name, path, node, output, zeile=None, zeilenCommand=None):

    if isinstance(node, dict):
        for key, value in node.iteritems():
            transform(path + texify(key), path + texify(key)[0:3], value, output)
    elif isinstance(node, str):
        if zeile is not None:
            output.write('\\newcommand{{\\{0}}}[1]{{{1}}}\n'.format(name, node.format(z='\\{0}{{#1}}'.format(zeilenCommand))))
        else:
            output.write('\\newcommand{{\\{0}}}{{{1}}}\n'.format(name, node))
    elif isinstance(node, unicode):
        if zeile is not None:
            output.write(u'\\newcommand{{\\{0}}}{{{1}}}\n'.format(name, node.format(z=u'\\{0}{{#1}}'.format(zeilenCommand))))
        else:
            output.write(u'\\newcommand{{\\{0}}}{{{1}}}\n'.format(name, node))
    elif isinstance(node, Mehrfach):
        if zeile is not None:
            output.write('\\newcommand{{\\{0}}}[2]{{{1}}}\n'.format(name, node.template.format(n='#2', z=u'\\{0}{{#1}}'.format(zeilenCommand))))
        else:
            output.write('\\newcommand{{\\{0}}}[1]{{{1}}}\n'.format(name, node.template.format(n='#1')))
    elif isinstance(node, Liste):
        if zeile is not None:
            raise Exception(u"Verschachtelte Listen werden nicht unterstützt!")
        zCommand = path + 'Zeilen'
        output.write(u'\\newcommand{{\\{0}}}[1]{{\\ifcase#1 '.format(zCommand))
        l = []
        for zeilenname, zeilenwert in node.zeilen:
            l.append(zeilenwert)
        output.write(u'{0}\\fi}}\n'.format(u'\\or '.join(l)))
        for feldname, feldwert in node.felder.iteritems():
            transform(path + texify(feldname), path + texify(feldname)[0:3], feldwert, output, zeilenwert, zCommand)
    else:
        raise Exception("Nicht unterstützter Typ: %s" % type(node))


with codecs.open(sys.argv[1], 'r', 'utf-8') as f:
    ef = yaml.load(f)
    with codecs.open(sys.argv[2], 'w', 'utf-8') as o:
        transform('', '', ef, o)