#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

if len(sys.argv) != 3:
	print "needs 2 arguments!"
	sys.exit(2)

with open('build/wallpaper-extern.tex', 'w') as f:
	if len(sys.argv[1]) is 0:
		f.write('\\newcommand{\\dsaClassParams}{}\n')
		f.write('\\newcommand{\\setwp}{}\n')
	elif sys.argv[1] == 'none':
		f.write('\\newcommand{\\dsaClassParams}{nowallpaper}\n')
		f.write('\\newcommand{\\setwp}{}\n')
	else:
		f.write('\\newcommand{\\dsaClassParams}{nowallpaper}\n')
		f.write('\\newcommand{{\\setwp}}{{\\ThisCenterWallPaper{{1.0275}}{{{}}}}}\n'.format(sys.argv[1]))
	f.write('\\newcommand{{\\landscapewp}}{{{}}}\n'.format(sys.argv[2]))