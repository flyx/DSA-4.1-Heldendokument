#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ./talente.py <input-yaml> <output-tex>

import sys, yaml, yaml.nodes

if len(sys.argv) != 3:
    print "needs 2 arguments!"
    sys.exit(2)


class Talent(yaml.YAMLObject):

    @classmethod
    def from_yaml(cls, loader, node):
        if not isinstance(node, yaml.nodes.SequenceNode):
            raise Exception("Expected sequence node!")
        eigenschaften = []
        behinderung = ""
        for index, child in enumerate(node.value):
            scalar = loader.construct_scalar(child)
            if index < 3:
                eigenschaften.append(scalar)
            if index > 3:
                raise Exception("Too many values!")
            behinderung = scalar
        return cls(eigenschaften, behinderung)

    def __init__(self, eigenschaften, behinderung):
        self.eigenschaften = eigenschaften
        self.behinderung = behinderung

    def __repr__(self):
        return "(Eigenschaften: [" + ','.join(self.eigenschaften) + "], Behinderung: " + self.behinderung + ")"

class Spezialtalent(Talent):
    yaml_tag = u"!spez"

    def __init__(self, eigenschaften, behinderung):
        Talent.__init__(self, eigenschaften, behinderung)
        self.basis = False

    def __repr__(self):
        return "Spezialtalent" + Talent.__repr__(self)

class Basistalent(Talent):
    yaml_tag = u"!basis"

    def __init__(self, eigenschaften, behinderung):
        Talent.__init__(self, eigenschaften, behinderung)
        self.basis = True

    def __repr__(self):
        return "Basistalent" + Talent.__repr__(self)

class Kampftechnik(yaml.YAMLObject):

    @classmethod
    def from_yaml(cls, loader, node):
        if not isinstance(node, yaml.nodes.SequenceNode):
            raise Exception("Expected sequence node!")
        spalte = ""
        behinderung = ""
        for index, child in enumerate(node.value):
            scalar = loader.construct_scalar(child)
            if index is 0:
                spalte = scalar
            elif index is 1:
                behinderung = scalar
            else:
                raise Exception("Too many values!")
        return cls(spalte, behinderung)

    def __init__(self, spalte, behinderung):
        self.spalte = spalte
        self.behinderung = behinderung

    def __repr__(self):
        return "(Spalte: {}, Behinderung: {})".format(self.spalte, self.behinderung)

class Spezialkampftechnik(Kampftechnik):
    yaml_tag = u"!kampfspez"

    def __init__(self, spalte, behinderung):
        Kampftechnik.__init__(self, spalte, behinderung)
        self.basis = False

    def __repr__(self):
        return "Spezialkampftechnik" + Kampftechnik.__repr__(self)

class Basiskampftechnik(Kampftechnik):
    yaml_tag = u"!kampfbasis"

    def __init__(self, spalte, behinderung):
        Kampftechnik.__init__(self, spalte, behinderung)
        self.basis = True

    def __repr__(self):
        return "Basiskampftechnik" + Kampftechnik.__repr__(self)

class SprachSchriftTalent(yaml.YAMLObject):

    @classmethod
    def from_yaml(cls, loader, node):
        if not isinstance(node, yaml.nodes.ScalarNode):
            raise Exception("Excpected scalar node!")
        scalar = loader.construct_scalar(node)
        return cls(scalar)

    def __init__(self, komp):
        self.komp = komp

    def __repr__(self):
        return "(Komplexität: {})".format(self.komp)

class Sprache(SprachSchriftTalent):
    yaml_tag = u"!sprache"

    def __init__(self, komp):
        SprachSchriftTalent.__init__(self, komp)
        self.sprache = True

    def __repr__(self):
        return "Sprache" + SprachSchriftTalent.__repr__(self)

class Schrif(SprachSchriftTalent):
    yaml_tag = u"!schrift"

    def __init__(self, komp):
        SprachSchriftTalent.__init__(self, komp)
        self.sprache = False

    def __repr__(self):
        return "Schrift" + SprachSchriftTalent.__repr__(self)

def latex_umlauts(s):
    return s.replace(u'ä', u'\\"a').replace(
                     u'ü', u'\\"u').replace(
                     u'ö', u'\\"o').replace(
                     u'Ä', u'\\"A').replace(
                     u'Ü', u'\\"U').replace(
                     u'Ö', u'\\"O').replace(
                     u'(', u'\\lparen{}').replace(
                     u')', u'\\rparen{}')


def write_basis(dest, talente, name, varname):
    current = talente[name]
    dest.write(u'\\newcommand{\\' + varname + '}[2]{\\ifcase#1')
    lines = []
    for key in sorted(current):
        talent = current[key]
        if talent.basis:
            eigenschaften = talent.eigenschaften
            # best format string ever
            lines.append(u"\\talent{{#2}}{{{}}}{{{}}}{{{}}}{{{}}}{{{}}}".format(
                key, eigenschaften[0], eigenschaften[1], eigenschaften[2], talent.behinderung))
    dest.write(u'\\or'.join(lines).encode('utf-8'))
    dest.write('\\fi}\n\n')

def write_list(dest, talente, name, varname):
    current = talente[name]
    dest.write(u'\\newcommand{\\' + varname + '}{()')
    for key in sorted(current):
        dest.write(u'({})'.format(latex_umlauts(key)).encode('utf-8'))
    dest.write('}\n\n')

def write_kampfbasis(dest, talente, name, varname):
    current = talente[name]
    dest.write(u'\\newcommand{\\' + varname + '}[2]{\\ifcase#1')
    lines = []
    for key in sorted(current):
        kampf = current[key]
        if kampf.basis:
            lines.append(u'\\kampf{{#2}}{{{}}}{{{}}}{{{}}}'.format(
                key, kampf.spalte, kampf.behinderung))
    dest.write(u'\\or'.join(lines).encode('utf-8'))
    dest.write(u'\\fi}\n\n')

def write_kampflist(dest, talente, name, varname):
    current = talente[name]
    dest.write(u'\\newcommand{\\' + varname + '}{()')
    for key in sorted(current):
        dest.write(u'({})'.format(latex_umlauts(key)).encode('utf-8'))
    dest.write('}\n\n')

def write_sprachschriftlist(dest, talente, name, varname):
    current = talente[name]
    dest.write(u'\\newcommand{\\' + varname + '}{()')
    for key in sorted(current):
        dest.write(u'({} \\lparen{{}}{}\\rparen{{}})'.format(latex_umlauts(key), u'Sprache' if current[key].sprache else u'Schrift').encode('utf-8'))
    dest.write('}\n\n')

def process_category(dest, talente, category, categoryTrunk):
    write_basis(dest, talente, category, categoryTrunk + 'Basis')
    write_list(dest, talente, category, categoryTrunk + 'Talentliste')

def process_kampf(dest, talente, category, categoryTrunk):
    write_kampfbasis(dest, talente, category, categoryTrunk + 'Basis')
    write_kampflist(dest, talente, category, categoryTrunk + 'Talentliste')

with open(sys.argv[1], 'r') as f:
    talente = yaml.load(f)

    with open(sys.argv[2], 'w') as dest:
        process_category(dest, talente, u'Körperliche Talente', u'Koerper')
        process_category(dest, talente, u'Gesellschaftliche Talente', u'Gesellschaft')
        process_category(dest, talente, u'Naturtalente', u'Natur')
        process_category(dest, talente, u'Wissenstalente', u'Wissen')
        process_category(dest, talente, u'Handwerkliche Talente', u'Handwerk')
        process_kampf(dest, talente, u'Kampftechniken', u'Kampftechniken')
        write_sprachschriftlist(dest, talente, u'Sprachen und Schriften', u'SprachenTalentliste')