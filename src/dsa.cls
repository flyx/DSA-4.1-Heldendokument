%% dsa.cls
%% Copyright 2014 Felix Krause <contact@flyx.org>
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all distributions of LaTeX
% version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
%
% The Current Maintainer of this work is Felix Krause
%
% This work consists of the dsa.cls, fanpaket-setup.sh and fanpaket-setup.ps1.
% Other accompanying files may have different licenses, see their source code
% for details

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa}[2016/06/27 v0.2.1]

\usepackage{iftex}
\ifLuaTeX
  \RequirePackage{luatex85}
\fi

\DeclareOption*{
  \PassOptionsToClass{\CurrentOption}{scrartcl}
}

\ProcessOptions

\LoadClass[a4paper, fontsize=11pt]{scrartcl}

\usepackage[top=1.0cm, bottom=0.5cm, left=1cm, right=1cm]{geometry}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Package imports
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% language stuff

\usepackage{polyglossia}
\setdefaultlanguage{german}

% font stuff
% Note: If math packages are ever required, fontspec should
%       be loaded after them in order to load fonts correctly.
\usepackage{amssymb}
\usepackage{fontspec}
\usepackage{fontawesome5}

\setlength{\parindent}{0pt}
\setlength{\parskip}{7pt}

% coloring, drawing, picturing

\usepackage[table]{xcolor}
\usepackage{pgf}
\usepackage{wallpaper}
\usepackage{graphicx}

% misc

\usepackage{shadowtext}
\usepackage{environ}
\usepackage{multicol}

% tabulars

\usepackage{makecell}
\usepackage{multirow}
\usepackage{array}
\usepackage{nicematrix}
\newcolumntype{x}[1]{>{\centering\arraybackslash\hspace{0pt}}p{#1}}
\newcolumntype{y}[1]{>{\raggedleft\arraybackslash\hspace{0pt}}p{#1}}
\newcolumntype{I}{!{\vrule}}

% graphics

\usepackage{tikz}
\usepackage{calc}
\usetikzlibrary{positioning,fit,calc,backgrounds}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% font selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newfontfamily{\mansontt}{Manson}
\DeclareTextFontCommand{\textmansontt}{\mansontt}
\setmainfont{NewG8}[
  Extension      = .otf,
  UprightFont    = NewG8-Reg,
  BoldFont       = NewG8-Bol,
  BoldItalicFont = NewG8-BolIta,
  ItalicFont     = NewG8-Ita
]
\setmonofont{Copse}[
  Extension      = .ttf,
  UprightFont    = Copse-Regular
]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% environments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newlength\dsaOldParindent
\newenvironment{dsaCharacterSheet}{
  \pagebreak
  \setlength{\dsaOldParindent}{\parindent}
  \setlength{\parindent}{0pt}
  \ClearWallPaper
  \IfFileExists{../img/wallpaper.jpg}{
    \setlength{\wpXoffset}{-0.3cm}%
    \setlength{\wpYoffset}{-0.1cm}%
    \ThisCenterWallPaper{1.0275}{../img/wallpaper.jpg}%
  }{}
}{
  \setlength{\parindent}{\dsaOldParindent}
}

% Set default value for border spacing within character sheet boxes
\setlength{\fboxsep}{3mm}

\newsavebox\blockbox
\NewEnviron{dsaSheetBox}[1][\textwidth]{%
  \begin{lrbox}{\blockbox}%
    \noindent\hspace{\fboxsep}\begin{minipage}{#1-2\fboxsep}
      \vspace{\fboxsep}%
      \BODY%
      \vspace{.66\fboxsep}%
    \end{minipage}%
  \end{lrbox}
  \noindent
  \begin{tikzpicture}
    \node[text width=#1,fill=white,fill opacity=0.4,text opacity=1,outer sep=0pt,inner sep=0pt](textwidth){\usebox\blockbox};
    % Rahmen oben
    \fill[black!60] (textwidth.north west) -- ($(textwidth.north west) + (0.02,-0.02)$) -- ($(textwidth.north east) - (0.02,0.02)$) -- (textwidth.north east) -- cycle;
    \fill[black!80] ($(textwidth.north west) + (0.02,-0.02)$) -- ($(textwidth.north west) + (0.08, -0.08)$) -- ($(textwidth.north east) - (0.08, 0.08)$) -- ($(textwidth.north east) - (0.02, 0.02)$) -- cycle;
    \fill[black!90] ($(textwidth.north west) + (0.08,-0.08)$) -- ($(textwidth.north west) + (0.1, -0.1)$) -- ($(textwidth.north east) - (0.1, 0.1)$) -- ($(textwidth.north east) - (0.08, 0.08)$) -- cycle;
    % Rahmen links
    \fill[black!60] (textwidth.north west) -- ($(textwidth.north west) + (0.02,-0.02)$) -- ($(textwidth.south west) + (0.02,0.02)$) -- (textwidth.south west) -- cycle;
    \fill[black!80] ($(textwidth.north west) + (0.02,-0.02)$) -- ($(textwidth.north west) + (0.08, -0.08)$) -- ($(textwidth.south west) + (0.08, 0.08)$) -- ($(textwidth.south west) + (0.02, 0.02)$) -- cycle;
    \fill[black!90] ($(textwidth.north west) + (0.08,-0.08)$) -- ($(textwidth.north west) + (0.1, -0.1)$) -- ($(textwidth.south west) + (0.1, 0.1)$) -- ($(textwidth.south west) + (0.08, 0.08)$) -- cycle;
    % Rahmen rechts
    \fill[black!90] (textwidth.south east) -- ($(textwidth.south east) - (0.02,-0.02)$) -- ($(textwidth.north east) - (0.02,0.02)$) -- (textwidth.north east) -- cycle;
    \fill[black!80] ($(textwidth.south east) - (0.02,-0.02)$) -- ($(textwidth.south east) - (0.08, -0.08)$) -- ($(textwidth.north east) - (0.08, 0.08)$) -- ($(textwidth.north east) - (0.02, 0.02)$) -- cycle;
    \fill[black!60] ($(textwidth.south east) - (0.08,-0.08)$) -- ($(textwidth.south east) - (0.1, -0.1)$) -- ($(textwidth.north east) - (0.1, 0.1)$) -- ($(textwidth.north east) - (0.08, 0.08)$) -- cycle;
    % Rahmen unten
    \fill[black!90] (textwidth.south east) -- ($(textwidth.south east) - (0.02,-0.02)$) -- ($(textwidth.south west) + (0.02,0.02)$) -- (textwidth.south west) -- cycle;
    \fill[black!80] ($(textwidth.south east) - (0.02,-0.02)$) -- ($(textwidth.south east) - (0.08, -0.08)$) -- ($(textwidth.south west) + (0.08, 0.08)$) -- ($(textwidth.south west) + (0.02, 0.02)$) -- cycle;
    \fill[black!60] ($(textwidth.south east) - (0.08,-0.08)$) -- ($(textwidth.south east) - (0.1, -0.1)$) -- ($(textwidth.south west) + (0.1, 0.1)$) -- ($(textwidth.south west) + (0.08, 0.08)$) -- cycle;
  \end{tikzpicture}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Character sheet macros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Internal - for making tiny rows in tables
\makeatletter
\newsavebox\saved@arstrutbox
\newcommand*{\setarstrut}[1]{%
  \noalign{%
    \begingroup
      \global\setbox\saved@arstrutbox\copy\@arstrutbox
      #1%
      \global\setbox\@arstrutbox\hbox{%
        \vrule \@height\arraystretch\ht\strutbox
               \@depth\arraystretch \dp\strutbox
               \@width\z@
      }%
    \endgroup
  }%
}
\newcommand*{\restorearstrut}{%
  \noalign{%
    \global\setbox\@arstrutbox\copy\saved@arstrutbox
  }%
}
\makeatother

\newcommand{\dsaRow}[3]{\setarstrut{#1}\rowfont{#2}#3\\ \restorearstrut}
