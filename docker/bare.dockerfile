FROM debian:bullseye-slim

RUN apt update --fix-missing -y && apt upgrade -y && apt install -f -y --no-install-recommends \
      texlive-luatex \
      latexmk \
      texlive-pictures \
      texlive-latex-extra \
      texlive-lang-german && \
    mkdir -p /heldendokument/img /tmp /fonts

COPY src/*.lua src/*.tex src/.latexmkrc src/dsa.cls /heldendokument/src/
COPY img/silhouette.png /heldendokument/img/silhouette.png
COPY docker/held.sh /heldendokument
COPY *.otf /fonts

ENV OSFONTDIR /fonts
ENV TERM xterm

WORKDIR /tmp

# installs curl build dependency, downloads everything it needs, then uninstalls
# again to avoid having it in the image.
RUN apt install -y curl && \
    curl -L https://github.com/probonopd/font-newg8/releases/download/continuous/newg8-otf.zip -O && \
    curl -L https://mirrors.ctan.org/fonts/fontawesome5.zip -O && \
    curl -L https://mirrors.ctan.org/macros/latex/contrib/nicematrix.zip -O && \
    curl -L -s -o wds.pdf http://www.ulisses-spiele.de/download/468/ && \
    curl -L http://www.ulisses-spiele.de/download/889/ -o fanpaket.zip && \
    apt remove -y --purge curl && \
# same with unzip…
    apt install -y unzip && \
    unzip newg8-otf.zip && \
    unzip fontawesome5.zip && \
    unzip nicematrix.zip && \
    unzip -p fanpaket.zip "Das Schwarze Auge - Fanpaket - 2013.07.29/Logo - Fanprodukt.png" >/heldendokument/img/logo-fanprodukt.png && \
    apt remove -y --purge unzip && \
# … poppler and imagemagic
    apt install -y poppler-utils imagemagick && \
    pdfimages -f 2 -l 2 wds.pdf wds && \
    convert wds-000.ppm /heldendokument/img/wallpaper.jpg && \
    apt remove -y --purge poppler-utils imagemagick && \
    apt autoremove -y && \
# move things into place
    mv *.otf /fonts && \
# install fontawesome
    mv fontawesome5/tex /usr/share/texmf/tex/latex/fontawesome5 && \
    mv fontawesome5/type1 /usr/share/texmf/fonts/type1/public/fontawesome5 && \
    mv fontawesome5/tfm /usr/share/texmf/fonts/tfm/public/fontawesome5 && \
    mv fontawesome5/enc/*.enc /usr/share/texmf/fonts/enc && \
    mv fontawesome5/map/*.map /usr/share/texmf/fonts/map && \
    mv fontawesome5/opentype /usr/share/texmf/fonts/opentype/public/fontawesome5 && \
# install nicematrix
    cd nicematrix && latex nicematrix.ins && cd .. && \
    mkdir /usr/share/texmf/tex/latex/nicematrix && \
    mv nicematrix/nicematrix.sty /usr/share/texmf/tex/latex/nicematrix && \
# re-hash tex stuff
    texhash && updmap-sys --enable Map=fontawesome5.map && \
    luaotfload-tool -u && \
# and remove tmp stuff
    rm -rf /tmp/*

WORKDIR /heldendokument
ENTRYPOINT ["/heldendokument/held.sh", "-"]