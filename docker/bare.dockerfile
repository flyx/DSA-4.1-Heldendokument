FROM debian:bullseye-slim

RUN apt update && apt upgrade && apt install -y --no-install-recommends \
      texlive-luatex \
      latexmk \
      texlive-pictures \
      texlive-latex-extra \
      texlive-lang-german && \
    apt install -y curl unzip poppler-utils imagemagick && \
    mkdir /heldendokument

RUN mkdir -p /tmp /fonts
COPY src/ /heldendokument/src
COPY img/ /heldendokument/img
COPY docker/held.sh /heldendokument
COPY *.otf /fonts

ENV OSFONTDIR /fonts
ENV TERM xterm

WORKDIR /tmp

RUN curl -L https://github.com/probonopd/font-newg8/releases/download/continuous/newg8-otf.zip -O && \
    unzip newg8-otf.zip && \
    mv *.otf /fonts && \
    curl -L https://mirrors.ctan.org/fonts/fontawesome.zip -O && \
    unzip fontawesome.zip && \
    mv fontawesome/tex /usr/share/texmf/tex/latex/fontawesome && \
    mv fontawesome/type1 /usr/share/texmf/fonts/type1/public/fontawesome && \
    mv fontawesome/tfm /usr/share/texmf/fonts/tfm/public/fontawesome && \
    mv fontawesome/enc/*.enc /usr/share/texmf/fonts/enc && \
    mv fontawesome/map/*.map /usr/share/texmf/fonts/map && \
    mv fontawesome/opentype /usr/share/texmf/fonts/opentype/public/fontawesome && \
    curl -L https://mirrors.ctan.org/macros/latex/contrib/nicematrix.zip -O && \
    unzip nicematrix.zip && \
    cd nicematrix && latex nicematrix.ins && cd .. && \
    mkdir /usr/share/texmf/tex/latex/nicematrix && \
    mv nicematrix/nicematrix.sty /usr/share/texmf/tex/latex/nicematrix && \
    texhash && updmap-sys --enable Map=fontawesome.map && \
    luaotfload-tool -u && \
    apt remove --purge -y curl unzip poppler-utils imagemagick && apt autoremove -y && \
    rm -rf /tmp/*

WORKDIR /heldendokument
CMD /heldendokument/held.sh -