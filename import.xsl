<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:dsa="https://flyx.org/dsa-4.1-heldendokument"
    extension-element-prefixes="exslt func">
  <xsl:param name="sf_zeilen" as="xs:integer" select="6"/>
  <xsl:param name="min_gaben" as="xs:integer" select="2"/>
  <xsl:param name="min_begabungen" as="xs:integer" select="0"/>
  <xsl:param name="min_kampf" as="xs:integer" select="12"/>
  <xsl:param name="min_koerper" as="xs:integer" select="17"/>
  <xsl:param name="min_gesellschaft" as="xs:integer" select="10"/>
  <xsl:param name="min_natur" as="xs:integer" select="7"/>
  <xsl:param name="min_wissen" as="xs:integer" select="17"/>
  <xsl:param name="min_sprachen" as="xs:integer" select="10"/>
  <xsl:param name="min_handwerk" as="xs:integer" select="15"/>

  <xsl:output method="text"/>

  <xsl:variable name="meta" select="document('heldensoftware-meta.xml')/meta"/>
  <xsl:variable name="kulturen" select="$meta/kulturen"/>
  <xsl:variable name="vorUndNachteile" select="$meta/vorUndNachteile"/>
  <xsl:variable name="kampfTalente" select="$meta/talente/kampf"/>
  <xsl:variable name="naturTalente" select="$meta/talente/natur"/>
  <xsl:variable name="sonderfertigkeiten" select="$meta/sonderfertigkeiten"/>
  <xsl:variable name="kampfstile" select="$meta/kampfstile"/>

  <xsl:template match="/">
    <xsl:apply-templates select="helden/held[1]"/>
  </xsl:template>

  <xsl:template match="held">
    <xsl:text>return {
  dokument = {
    seiten = {"front", "talente", "kampf", </xsl:text>
    <xsl:choose>
      <xsl:when test="vt/vorteil[starts-with(@name, 'Geweiht')] or sf/sonderfertigkeit[starts-with(@name, 'Spätweihe')]">
        <xsl:text>"liturgien"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"ausruestung"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="zauberliste/zauber[@repraesentation != 'Magiedilletant']">
      <xsl:text>, "zauber"</xsl:text>
    </xsl:if>
    <xsl:if test="talentliste/talent[starts-with(@name, 'Ritualkenntnis')]">
      <xsl:text>, "zauberdok"</xsl:text>
    </xsl:if>
    <xsl:text>},
    talentreihenfolge = {
      "sonderfertigkeiten", "gaben", "begabungen", "kampf", "koerper",
      "gesellschaft", "natur", "wissen", "sprachen", "handwerk"
    },
  },
</xsl:text>
    <xsl:apply-templates select="basis"/>
    <xsl:apply-templates select="vt"/>
    <xsl:apply-templates select="eigenschaften"/>
    <xsl:apply-templates select="basis" mode="ap"/>
    <xsl:text>
  m_spalte = false,</xsl:text>
    <xsl:apply-templates select="talentliste"/>
    <xsl:apply-templates select="sf"/>
    <xsl:text>
  nahkampf = {
    {}, {}, {}, {}, {}
  },
  fernkampf = {
    {}, {}, {},
  },
  schilde = {
    {},
    {},
  },
  ruestung = {
    {}, {}, {}, {}, {}, {},
  },
  kleidung = "",
  ausruestung = {
    {"",   "",      ""},
    {},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}
  },
  proviant = {
    {"", "", "", "", ""},
    {}, {}, {}, {}, {}, {}, {}
  },
  vermoegen = {
    {"Dukaten", "", "", "", "", "", "", "", ""},
    {"Silbertaler"},
    {"Heller"},
    {"Kreuzer"},
    --  Mehrzeilig, standardmäßig 4 Zeilen.
    sonstiges = ""
  },
  verbindungen = "",
  notizen = "",
  tiere = {
    {"",   "",  "",  "", "", "", "", "", "", "", "", "", "", "", ""},
    {}, {}, {}
  },
  </xsl:text>
    <xsl:if test="talentliste/talent[starts-with(@name, 'Ritualkenntnis')] or zauberliste/zauber[@repraesentation != 'Magiedilletant']">
      <xsl:text>magie = {</xsl:text>
      <xsl:apply-templates select="sf" mode="rituale"/>
      <xsl:apply-templates select="sf" mode="repraesentationen"/>
      <xsl:text>
    asp_regeneration = "",
    artefakte = "",
    notizen = "",</xsl:text>
    <xsl:apply-templates select="sf" mode="merkmale">
      <xsl:with-param name="id" select="'merkmale'"/>
      <xsl:with-param name="item" select="'sonderfertigkeit'"/>
      <xsl:with-param name="name" select="'Merkmalskenntnis'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="vt" mode="merkmale">
      <xsl:with-param name="id" select="'begabungen'"/>
      <xsl:with-param name="item" select="'vorteil'"/>
      <xsl:with-param name="name" select="'Begabung für [Merkmal]'"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="vt" mode="merkmale">
      <xsl:with-param name="id" select="'unfaehigkeiten'"/>
      <xsl:with-param name="item" select="'vorteil'"/>
      <xsl:with-param name="name" select="'Unfähigkeit für [Merkmal]'"/>
    </xsl:apply-templates>
    <xsl:text>
  },
  </xsl:text>
    </xsl:if>
    <xsl:if test="zauberliste/zauber[@repraesentation != 'Magiedilletant']">
      <xsl:apply-templates select="zauberliste"/>
    </xsl:if>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:stringVal">
    <xsl:param name="id"/>
    <xsl:param name="value"/>
    <func:result><xsl:value-of select="$id"/><xsl:text> = [[</xsl:text><xsl:value-of select="$value"/><xsl:text>]]</xsl:text></func:result>
  </func:function>

  <xsl:template match="basis">
    <xsl:text>
  held = {
    </xsl:text><xsl:value-of select="dsa:stringVal('name', parent::held/@name)"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('gp', rasse/aussehen/@gpstart)"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('rasse', rasse/@string)"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('kultur', kultur/@string)"/><xsl:text>,
    profession = [[</xsl:text>
      <xsl:value-of select="ausbildungen/ausbildung[@art='Hauptprofession']/@string"/>
      <xsl:apply-templates select="ausbildungen/ausbildung[@art!='Hauptprofession']"/><xsl:text>]],
    </xsl:text><xsl:value-of select="dsa:stringVal('geschlecht', geschlecht/@name)"/><xsl:text>,
    tsatag = [[</xsl:text>
      <xsl:value-of select="rasse/aussehen/@gbtag"/><xsl:text>. </xsl:text>
      <xsl:choose>
        <xsl:when test="rasse/aussehen/@gbmonat = 1"><xsl:text>Praios</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 2"><xsl:text>Rondra</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 3"><xsl:text>Efferd</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 4"><xsl:text>Travia</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 5"><xsl:text>Boron</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 6"><xsl:text>Hesinde</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 7"><xsl:text>Firun</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 8"><xsl:text>Tsa</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 9"><xsl:text>Phex</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 10"><xsl:text>Peraine</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 11"><xsl:text>Ingerimm</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 12"><xsl:text>Rahja</xsl:text></xsl:when>
        <xsl:when test="rasse/aussehen/@gbmonat = 13"><xsl:text>Namenloser</xsl:text></xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:value-of select="rasse/aussehen/@gbjahr"/>
      <xsl:text> BF]],
    </xsl:text><xsl:value-of select="dsa:stringVal('groesse', concat(rasse/groesse/@value, ' Schritt'))"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('gewicht', concat(rasse/groesse/@gewicht, ' Stein'))"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('haarfarbe', rasse/aussehen/@haarfarbe)"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('augenfarbe', rasse/aussehen/@augenfarbe)"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('stand', rasse/aussehen/@stand)"/><xsl:text>,
    sozialstatus = </xsl:text><xsl:value-of select="parent::held/eigenschaften/eigenschaft[@name='Sozialstatus']/@value"/><xsl:text>,
    </xsl:text><xsl:value-of select="dsa:stringVal('titel', rasse/aussehen/@titel)"/><xsl:text>,
    aussehen = {[[</xsl:text>
      <xsl:value-of select="rasse/aussehen/@aussehentext0"/>
      <xsl:text>]], {}, [[</xsl:text>
      <xsl:value-of select="rasse/aussehen/@aussehentext1"/>
      <xsl:text>]], {}, [[</xsl:text>
      <xsl:value-of select="rasse/aussehen/@aussehentext2"/><xsl:text>]]}
  },</xsl:text>
  </xsl:template>

  <xsl:template match="ausbildung">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@art"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@string"/>
  </xsl:template>

  <xsl:template match="vt">
    <xsl:text>
  vorteile = {
    </xsl:text>
    <xsl:apply-templates select="vorteil" mode="filter"/>
    <xsl:apply-templates select="vorteil" mode="filter-benamt"/><xsl:text>
    magisch = {
      </xsl:text>
      <xsl:apply-templates select="vorteil" mode="filter">
        <xsl:with-param name="magisch" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="vorteil" mode="filter-benamt">
        <xsl:with-param name="magisch" select="true()"/>
      </xsl:apply-templates><xsl:text>
    }
  },
  nachteile = {
    </xsl:text>
    <xsl:apply-templates select="vorteil" mode="filter">
      <xsl:with-param name="nachteil" select="true()"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="vorteil" mode="filter-benamt">
      <xsl:with-param name="nachteil" select="true()"/>
    </xsl:apply-templates><xsl:text>
    magisch = {
      </xsl:text>
      <xsl:apply-templates select="vorteil" mode="filter">
        <xsl:with-param name="nachteil" select="true()"/>
        <xsl:with-param name="magisch" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="vorteil" mode="filter-benamt">
        <xsl:with-param name="nachteil" select="true()"/>
        <xsl:with-param name="magisch" select="true()"/>
      </xsl:apply-templates><xsl:text>
    }
  },</xsl:text>
  </xsl:template>

  <xsl:template match="vorteil">
    <xsl:text>[[</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:if test="@value != ''">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@value"/>
      </xsl:if>
      <xsl:for-each select="auswahl">
        <xsl:sort select="@position" data-type="number" order="descending"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@value"/>
      </xsl:for-each>
    <xsl:text>]], </xsl:text>
  </xsl:template>

  <xsl:template match="vorteil" mode="filter">
    <xsl:param name="magisch" as="xs:boolean" select="false()"/>
    <xsl:param name="nachteil" as="xs:boolean" select="false()"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$vorUndNachteile/vn[@name=$name]"/>
    <xsl:if test="($def/@nachteil = '1') = $nachteil and ($def/@magisch = '1') = $magisch and string($def/@id) = ''">
      <xsl:apply-templates select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vorteil" mode="filter-benamt">
    <xsl:param name="magisch" as="xs:boolean" select="false()"/>
    <xsl:param name="nachteil" as="xs:boolean" select="false()"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$vorUndNachteile/vn[@name=$name]"/>
    <xsl:if test="($def/@nachteil = '1') = $nachteil and ($def/@magisch = '1') = $magisch and string($def/@id) != ''">
      <xsl:choose>
        <xsl:when test="$def/@liste = '1' and not(preceding-sibling::vorteil[@name=$name])">
          <xsl:text>
    </xsl:text><xsl:value-of select="$def/@id"/><xsl:text> = {</xsl:text>
          <xsl:for-each select="parent::vt/vorteil[@name=$name]">
            <xsl:text>[[</xsl:text><xsl:value-of select="@value"/><xsl:text>]], </xsl:text>
          </xsl:for-each>
          <xsl:text>},</xsl:text>
        </xsl:when>
        <xsl:when test="$def/@liste != '1'">
          <xsl:text>
    </xsl:text><xsl:value-of select="$def/@id"/><xsl:text> = </xsl:text>
          <xsl:apply-templates select="."/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <func:function name="dsa:basisEig">
    <xsl:param name="label"/>
    <xsl:param name="id"/>
    <func:result>
      <xsl:text>
    </xsl:text>
      <xsl:value-of select="$id"/><xsl:text> = {</xsl:text>
      <xsl:value-of select="eigenschaft[@name=$label]/@mod"/><xsl:text>, </xsl:text>
      <xsl:value-of select="eigenschaft[@name=$label]/@startwert"/><xsl:text>, </xsl:text>
      <xsl:value-of select="eigenschaft[@name=$label]/@value"/><xsl:text>},</xsl:text>
    </func:result>
  </func:function>

  <func:function name="dsa:abglEig">
    <xsl:param name="label"/>
    <xsl:param name="id"/>
    <func:result>
      <xsl:text>
    </xsl:text>
      <xsl:value-of select="$id"/><xsl:text> = {</xsl:text>
      <xsl:value-of select="eigenschaft[@name=$label]/@mod"/><xsl:text>, </xsl:text>
      <xsl:value-of select="eigenschaft[@name=$label]/@value"/><xsl:text>, 0},</xsl:text>
    </func:result>
  </func:function>

  <xsl:template match="eigenschaften">
    <xsl:text>
  eig = {</xsl:text>
    <xsl:value-of select="dsa:basisEig('Mut', 'MU')"/>
    <xsl:value-of select="dsa:basisEig('Klugheit', 'KL')"/>
    <xsl:value-of select="dsa:basisEig('Intuition', 'IN')"/>
    <xsl:value-of select="dsa:basisEig('Charisma', 'CH')"/>
    <xsl:value-of select="dsa:basisEig('Fingerfertigkeit', 'FF')"/>
    <xsl:value-of select="dsa:basisEig('Gewandtheit', 'GE')"/>
    <xsl:value-of select="dsa:basisEig('Konstitution', 'KO')"/>
    <xsl:value-of select="dsa:basisEig('Körperkraft', 'KK')"/>
    <xsl:value-of select="dsa:abglEig('Lebensenergie', 'LE')"/>
    <xsl:value-of select="dsa:abglEig('Ausdauer', 'AU')"/>
    <xsl:value-of select="dsa:abglEig('Astralenergie', 'AE')"/>
    <xsl:value-of select="dsa:abglEig('Magieresistenz', 'MR')"/>
    <xsl:value-of select="dsa:abglEig('Karmaenergie', 'KE')"/>
    <xsl:text>
    INI = {</xsl:text><xsl:value-of select="eigenschaft[@name='ini']/@mod"/><xsl:text>}
  },</xsl:text>
  </xsl:template>

  <xsl:template match="basis" mode="ap">
    <xsl:variable name="gesamt" as="xs:integer" select="abenteuerpunkte/@value"/>
    <xsl:variable name="frei" as="xs:integer" select="freieabenteuerpunkte/@value"/>
    <xsl:variable name="eingesetzt" select="$gesamt - $frei"/>
    <xsl:text>
  ap = {
    gesamt = </xsl:text><xsl:value-of select="$gesamt"/><xsl:text>,
    eingesetzt = </xsl:text><xsl:value-of select="$eingesetzt"/><xsl:text>,
    guthaben = </xsl:text><xsl:value-of select="$frei"/><xsl:text>
  },</xsl:text>
  </xsl:template>

  <func:function name="dsa:isNatur">
    <xsl:param name="name" as="xs:string"/>
    <func:result select="count($naturTalente/t[@name = $name]) &gt; 0"/>
  </func:function>

  <func:function name="dsa:muttersprache">
    <xsl:param name="kultur"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$kultur/@sprache">
          <xsl:value-of select="$kultur/@sprache"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('Sprachen kennen ', $kulturen/k[@name=$kultur/@name]/@muttersprache)"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:zweitsprache">
    <xsl:param name="kultur"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$kultur/@zweitsprache">
          <xsl:value-of select="$kultur/@zweitsprache"/>
        </xsl:when>
        <xsl:when test="$kulturen/k[@name=$kultur/@name]/@zweitsprache">
          <xsl:value-of select="concat('Sprachen kennen ', $kulturen/k[@name=$kultur/@name]/@zweitsprache)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:isGabe">
    <xsl:param name="vorteile"/>
    <xsl:param name="name"/>
    <func:result select="count($vorteile/vorteil[@name = $name]) &gt; 0"/>
  </func:function>

  <xsl:template match="talentliste">
    <xsl:variable name="vorteile" select="../vt"/>
    <xsl:text>
  talente = {</xsl:text>
    <xsl:variable name="koerper" select="talent[@be]"/>
    <xsl:variable name="kampf" select="$koerper[1]/preceding-sibling::talent"/>
    <xsl:variable name="natur" select="talent[dsa:isNatur(@name)]"/>
    <xsl:variable name="gesellschaft" select="$koerper[last()]/following-sibling::talent[following-sibling::talent[@name=$natur[1]/@name]]"/>
    <xsl:variable name="sprachenSchriften" select="talent[@k]"/>
    <xsl:variable name="wissen" select="$natur[last()]/following-sibling::talent[following-sibling::talent[@name=$sprachenSchriften[1]/@name]]"/>
    <xsl:variable name="handwerk" select="$sprachenSchriften[last()]/following-sibling::talent[not(dsa:isGabe($vorteile, @name))][not(starts-with(@name, 'Ritualkenntnis') or starts-with(@name, 'Liturgiekenntnis'))]"/>
    <xsl:variable name="gaben" select="$wissen/following-sibling::talent[dsa:isGabe($vorteile, @name)]"/>
    <xsl:variable name="begabungen" select="../zauberliste/zauber[@repraesentation='Magiedilletant']"/>
    <xsl:text>
    gaben = {</xsl:text><xsl:apply-templates select="$gaben"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($gaben) + 1"/>
      <xsl:with-param name="max" select="$min_gaben"/>
    </xsl:call-template>
    <xsl:text>
    },
    begabungen = {</xsl:text><xsl:apply-templates select="$begabungen" mode="begabungen"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($begabungen) + 1"/>
      <xsl:with-param name="max" select="$min_begabungen"/>
    </xsl:call-template>
    <xsl:text>
    },
    kampf = {</xsl:text><xsl:apply-templates select="$kampf" mode="kampf"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($kampf) + 1"/>
      <xsl:with-param name="max" select="$min_kampf"/>
    </xsl:call-template>
    <xsl:text>
    },
    koerper = {</xsl:text><xsl:apply-templates select="$koerper" mode="koerper"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($koerper) + 1"/>
      <xsl:with-param name="max" select="$min_koerper"/>
    </xsl:call-template>
    <xsl:text>
    },
    gesellschaft = {</xsl:text><xsl:apply-templates select="$gesellschaft"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($gesellschaft) + 1"/>
      <xsl:with-param name="max" select="$min_gesellschaft"/>
    </xsl:call-template>
    <xsl:text>
    },
    natur = {</xsl:text><xsl:apply-templates select="$natur"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($natur) + 1"/>
      <xsl:with-param name="max" select="$min_natur"/>
    </xsl:call-template>
    <xsl:text>
    },
    wissen = {</xsl:text><xsl:apply-templates select="$wissen"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($wissen) + 1"/>
      <xsl:with-param name="max" select="$min_wissen"/>
    </xsl:call-template>
    <xsl:text>
    },
    sprachen = {</xsl:text>
      <xsl:variable name="kultur" select="../basis/kultur"/>
      <xsl:apply-templates select="$sprachenSchriften[@name = dsa:muttersprache($kultur)]" mode="sprachen-schriften">
        <xsl:with-param name="praefix" select="'Muttersprache'"/>
      </xsl:apply-templates>
      <xsl:if test="dsa:zweitsprache(../basis/kultur) != ''">
        <xsl:apply-templates select="$sprachenSchriften[@name = dsa:zweitsprache($kultur)]" mode="sprachen-schriften">
          <xsl:with-param name="praefix" select="'Zweitsprache'"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="$sprachenSchriften[@name != dsa:muttersprache($kultur) and @name != dsa:zweitsprache($kultur)]" mode="sprachen-schriften"/>
      <xsl:call-template name="fill">
        <xsl:with-param name="cur" select="count($sprachenSchriften) + 1"/>
        <xsl:with-param name="max" select="$min_sprachen"/>
      </xsl:call-template>
      <xsl:text>
    },
    handwerk = {</xsl:text><xsl:apply-templates select="$handwerk"/>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($handwerk) + 1"/>
      <xsl:with-param name="max" select="$min_handwerk"/>
    </xsl:call-template>
    <xsl:text>
    },
  },</xsl:text>
  </xsl:template>

  <xsl:template match="talent" mode="kampf">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$kampfTalente[@name=$name]"/>
    <xsl:variable name="kampfwerte" select="../../kampf/kampfwerte[@name=$name]"/>

    <xsl:text>
      {[[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>]], "</xsl:text>
    <xsl:value-of select="$def/@steigern"/>
    <xsl:text>", "</xsl:text>
    <xsl:value-of select="$def/@be"/>
    <xsl:text>", </xsl:text>
    <xsl:choose>
      <xsl:when test="$kampfwerte">
        <xsl:value-of select="number($kampfwerte/attacke/@value) - number(//eigenschaft[@name='at']/@value)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="number($kampfwerte/parade/@value) - number(//eigenschaft[@name='pa']/@value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"", ""</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <func:function name="dsa:probe">
    <xsl:param name="input"/>
    <xsl:variable name="sub1" select="substring-after($input, '(')"/>
    <xsl:variable name="sub2" select="substring-after($sub1, '/')"/>
    <xsl:variable name="sub3" select="substring-after($sub2, '/')"/>
    <func:result>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="substring($sub1, 1, 2)"/>
      <xsl:text>", "</xsl:text>
      <xsl:value-of select="substring($sub2, 1, 2)"/>
      <xsl:text>", "</xsl:text>
      <xsl:value-of select="substring($sub3, 1, 2)"/>
      <xsl:text>"</xsl:text>
    </func:result>
  </func:function>

  <xsl:template match="talent" mode="koerper">
    <xsl:text>
      {[[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>]], </xsl:text>
    <xsl:value-of select="dsa:probe(@probe)"/>
    <xsl:text>, "</xsl:text>
    <xsl:if test="starts-with(@be, 'BE')">
      <xsl:value-of select="@be"/>
    </xsl:if>
    <xsl:text>", </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="talent">
    <xsl:text>
      {[[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>]], </xsl:text>
    <xsl:value-of select="dsa:probe(@probe)"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="talent" mode="sprachen-schriften">
    <xsl:param name="praefix" select="''"/>
    <xsl:text>
      {[[</xsl:text>
    <xsl:if test="$praefix != ''">
      <xsl:value-of select="concat($praefix, ': ')"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="starts-with(@name, 'Sprachen kennen ')">
        <xsl:value-of select="substring(@name, 17)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]], </xsl:text>
    <xsl:value-of select="@k"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="zauber" mode="begabungen">
    <xsl:text>
      {[[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:if test="@variante != ''">
      <xsl:value-of select="concat(' (', @variante, ')')"/>
    </xsl:if>
    <xsl:value-of select="concat(']], ', dsa:probe(@probe), ', ', @value)"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="sf">
    <xsl:text>
  sf = {</xsl:text>
    <xsl:apply-templates select="$sonderfertigkeiten/sf[@id]" mode="id">
      <xsl:with-param name="items" select="sonderfertigkeit"/>
    </xsl:apply-templates>
    <xsl:text>
    allgemein = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit"/>
      <xsl:text>
    },
    nahkampf = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'nahkampf'"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    fernkampf = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'fernkampf'"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    waffenlos = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'waffenlos'"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    magisch = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'magisch'"/>
      </xsl:apply-templates>
      <xsl:text>
    },
  },</xsl:text>
  </xsl:template>

  <func:function name="dsa:endsWith">
    <xsl:param name="haystack" as="xs:string"/>
    <xsl:param name="needle" as="xs:string"/>
    <func:result select="substring($haystack, string-length($haystack) - string-length($needle) + 1) = $needle"/>
  </func:function>

  <func:function name="dsa:sfKind">
    <func:result>
      <xsl:choose>
        <xsl:when test="dsa:endsWith(@name, ' I') or dsa:endsWith(@name, ' II') or dsa:endsWith(@name, ' III')">
          <xsl:text>roman</xsl:text>
        </xsl:when>
        <xsl:when test="contains(@name, ': ')">
          <xsl:text>named</xsl:text>
        </xsl:when>
        <xsl:when test="./* and contains(@name, '(')">
          <xsl:text>subsub</xsl:text>
        </xsl:when>
        <xsl:when test="./*">
          <xsl:text>sub</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>simple</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:sfName">
    <xsl:param name="kind"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$kind = 'roman'">
          <xsl:value-of select="substring(@name, 1, string-length(@name) - 2)"/>
        </xsl:when>
        <xsl:when test="$kind = 'named'">
          <xsl:value-of select="substring-before(@name, ': ')"/>
        </xsl:when>
        <xsl:when test="$kind = 'subsub'">
          <xsl:value-of select="substring-before(@name, *[1]/@name)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="sonderfertigkeit">
    <xsl:param name="art" select="''"/>
    <xsl:variable name="kind" select="dsa:sfKind()"/>
    <xsl:variable name="name" select="dsa:sfName($kind)"/>
    <xsl:variable name="def" select="$sonderfertigkeiten/sf[@name=$name]"/>
    <xsl:if test="$def">
      <xsl:choose>
        <xsl:when test="($kind = 'roman' or $kind = 'ignored') and not($def/@roman)">
          <xsl:message terminate="yes">
            <xsl:text>Fehler bei Sonderfertigkeit im XML: '</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>'
            Endet mit römischer Ziffer, was nicht erwartet wurde.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$kind = 'named' and $def/@named != '1'">
          <xsl:message terminate="yes">
            <xsl:text>Fehler bei Sonderfertigkeit im XML: '</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>'
            Enthält Doppelpunkt-Trenner, was nicht erwartet wurde.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$kind = 'sub' and not($def/@sub)">
          <xsl:message terminate="yes">
            <xsl:text>Fehler bei Sonderfertigkeit im XML: '</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>'
            Enthält Unterelement &lt;</xsl:text>
            <xsl:value-of select="local-name(*[1])"/>
            <xsl:text>&gt;, was nicht erwartet wurde.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$kind = 'subsub' and not($def/@subsub)">
          <xsl:message terminate="yes">
            <xsl:text>Fehler bei Sonderfertigkeit im XML: '</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>'
            Name enthält zwei verschiedene Unterelemente, was nicht erwartet wurde.</xsl:text>
          </xsl:message>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="not($def/@id) and not(./preceding-sibling::sonderfertigkeit[starts-with(@name, $name)]) and ((not($def/@art) and $art = '') or ($art = $def/@art))">
      <xsl:choose>
        <xsl:when test="$kind = 'roman'">
          <xsl:text>[[</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' II')]">
            <xsl:text>, II</xsl:text>
          </xsl:if>
          <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' III')]">
            <xsl:text>, III</xsl:text>
          </xsl:if>
          <xsl:text>]],</xsl:text>
        </xsl:when>
        <xsl:when test="$kind = 'named'">
          <xsl:for-each select=".|./following-sibling::sonderfertigkeit[starts-with(@name, $name)]">
            <xsl:value-of select="concat('[[', $name, ' (', substring-after(@name, ': '), ')]], ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$kind = 'sub'">
          <xsl:for-each select="(.|./following-sibling::sonderfertigkeit[starts-with(@name, $name)])/*[local-name() = $def/@sub]">
            <xsl:value-of select="concat('[[', $name, ' (', @name, ')]], ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$kind = 'simple'">
          <xsl:value-of select="concat('[[', $name, ']], ')"/>
        </xsl:when>
        <xsl:when test="$kind = 'subsub'"/>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>Unerwarteter Zustand bei Sonderfertigkeit '</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>'.</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sf" mode="id">
    <xsl:param name="items"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:text>
    </xsl:text>
    <xsl:value-of select="concat(@id, ' = ')"/>
    <xsl:choose>
      <xsl:when test="@roman">
        <xsl:text>{</xsl:text>
        <xsl:value-of select="string(count($items[@name=concat($name, ' I')]) &gt; 0)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="string(count($items[@name=concat($name, ' II')]) &gt; 0)"/>
        <xsl:if test="@roman = '3'">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="string(count($items[@name=concat($name, ' III')]) &gt; 0)"/>
        </xsl:if>
        <xsl:text>},</xsl:text>
      </xsl:when>
      <xsl:when test="@named and @boni">
        <xsl:text>{</xsl:text>
          <xsl:for-each select="$items[starts-with(@name, $name)]">
            <xsl:variable name="stilName" select="substring-after(@name, ': ')"/>
            <xsl:value-of select="concat('[&quot;', $stilName, '&quot;]: ')"/>
            <xsl:variable name="nameKomplett" select="@name"/>
            <xsl:variable name="boniDef" select="../../BoniWaffenlos/boniSF[@sf=$nameKomplett]"/>
            <xsl:choose>
              <xsl:when test="$boniDef">
                <xsl:value-of select="concat('&quot;', $boniDef/@talent, '&quot;,')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('&quot;', $kampfstile/stil[@name=$stilName]/@talent, '&quot;,')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <xsl:text>},</xsl:text>
      </xsl:when>
      <xsl:when test="@named">
        <xsl:text>{</xsl:text>
        <xsl:for-each select="$items[starts-with(@name, $name)]">
          <xsl:value-of select="concat('[[', substring-after(@name, ': '), ']], ')"/>
        </xsl:for-each>
        <xsl:text>},</xsl:text>
      </xsl:when>
      <xsl:when test="@sub">
        <xsl:text>{</xsl:text>
        <xsl:variable name="sub" select="@sub"/>
        <xsl:for-each select="$items[starts-with(@name, $name)]/*[local-name() = $sub]">
          <xsl:value-of select="concat('[[', @value, ']], ')"/>
        </xsl:for-each>
        <xsl:text>},</xsl:text>
      </xsl:when>
      <xsl:when test="@subsub">
        <xsl:text>"tODO",</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(string(count($items[starts-with(@name, $name)]) &gt; 0), ',')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <func:function name="dsa:isRitual">
    <xsl:param name="name"/>
    <func:result select="$sonderfertigkeiten/sf[@name=$name]/@art = 'ritual'"/>
  </func:function>

  <xsl:template match="sf" mode="rituale">
    <xsl:text>
    rituale = {</xsl:text>
    <xsl:variable name="rituale" select="sonderfertigkeit[dsa:isRitual(substring-before(@name, ': '))]"/>
    <xsl:apply-templates select="$rituale" mode="rituale"/>
    <xsl:text>
      </xsl:text>
    <xsl:call-template name="fill">
      <xsl:with-param name="cur" select="count($rituale) + 1"/>
      <xsl:with-param name="max" select="30"/>
    </xsl:call-template>
    <xsl:text>
      kenntnis = {</xsl:text>
      <xsl:variable name="rk" select="../talentliste/talent[starts-with(@name, 'Ritualkenntnis')]"/>
      <xsl:apply-templates select="$rk" mode="ritualkenntnis"/>
      <xsl:call-template name="fill">
        <xsl:with-param name="cur" select="count($rk) + 1"/>
        <xsl:with-param name="max" select="2"/>
      </xsl:call-template>
      <xsl:text>
      }
    },</xsl:text>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="rituale">
    <xsl:text>
      {</xsl:text>
    <xsl:value-of select="concat('[[', substring-after(@name, ': '), ']]')"/>
    <xsl:text>, "", "", "", "", "", ""},</xsl:text>
  </xsl:template>

  <xsl:template name="fill">
    <xsl:param name="cur" as="xs:integer"/>
    <xsl:param name="max" as="xs:integer"/>
    <xsl:if test="not($cur &gt; $max)">
      <xsl:text>{}, </xsl:text>
      <xsl:call-template name="fill">
        <xsl:with-param name="cur" select="$cur + 1"/>
        <xsl:with-param name="max" select="$max"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="talent" mode="ritualkenntnis">
    <xsl:text>
    {</xsl:text>
    <xsl:value-of select="concat('[[', substring-after(@name, ': '), ']], ', @value)"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="sf" mode="repraesentationen">
    <xsl:text>
    repraesentationen = {</xsl:text>
    <xsl:variable name="repr" select="sonderfertigkeit[starts-with(@name, 'Repräsentation: ')]"/>
    <xsl:apply-templates select="$repr" mode="repraesentationen"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <func:function name="dsa:repraesentation">
    <xsl:param name="input"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$input = 'Kristallomant'"><xsl:text>"Ach"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Alhanier'"><xsl:text>"Alh"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Borbaradianer'"><xsl:text>"Bor"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Druide'"><xsl:text>"Dru"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Drache'"><xsl:text>"Dra"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Elf'"><xsl:text>"Elf"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Fee'"><xsl:text>"Fee"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Geode'"><xsl:text>"Geo"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Grolm'"><xsl:text>"Gro"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Güldenländer'"><xsl:text>"Gül"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Kobold'"><xsl:text>"Kob"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Kophtan'"><xsl:text>"Kop"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Hexe'"><xsl:text>"Hex"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Gildenmagier'"><xsl:text>"Mag"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Mudramul'"><xsl:text>"Mud"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Nachtalb'"><xsl:text>"Nac"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Scharlatan'"><xsl:text>"Srl"</xsl:text></xsl:when>
        <xsl:when test="$input = 'Schelm'"><xsl:text>"Sch"</xsl:text></xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:value-of select="concat('Unbekannte Repräsentation: ', $input)"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="sonderfertigkeit" mode="repraesentationen">
    <xsl:value-of select="concat(dsa:repraesentation(substring-after(@name, ': ')), ',')"/>
  </xsl:template>

  <func:function name="dsa:merkmalBase">
    <xsl:param name="item" />
    <xsl:param name="ctx" select="."/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$item = 'sonderfertigkeit'">
          <xsl:value-of select="substring-after($ctx/@name, ': ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ctx/@value"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:merkmalSub">
    <xsl:param name="item"/>
    <xsl:variable name="base" select="dsa:merkmalBase($item)"/>
    <xsl:choose>
      <xsl:when test="contains($base, '(')">
        <func:result select="substring-before(substring-after('(', $base), ')')"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="'gesamt'"/>
      </xsl:otherwise>
    </xsl:choose>

  </func:function>

  <xsl:template match="sf|vt" mode="merkmale">
    <xsl:param name="id" />
    <xsl:param name="item"/>
    <xsl:param name="name"/>
    <xsl:text>
    </xsl:text>
    <xsl:value-of select="$id"/>
    <xsl:text> = {</xsl:text>
    <xsl:variable name="items" select="*[local-name() = $item and starts-with(@name, $name)]"/>
    <xsl:apply-templates select="$items" mode="merkmale"/>
    <xsl:variable name="ele" select="$items[starts-with(dsa:merkmalBase($item, .), 'Elementar')]"/>
    <xsl:if test="count($ele) &gt; 0">
      <xsl:text>
      Elementar = {</xsl:text>
      <xsl:for-each select="$ele">
        <xsl:value-of select="concat('&quot;', dsa:merkmalSub($item), '&quot;,')"/>
      </xsl:for-each>
      <xsl:text>},</xsl:text>
    </xsl:if>
    <xsl:variable name="dae" select="$items[starts-with(dsa:merkmalBase($item, .), 'Dämonisch')]"/>
    <xsl:if test="count($dae) &gt; 0">
      <xsl:text>
      Daemonisch = {</xsl:text>
      <xsl:for-each select="$dae">
        <xsl:value-of select="concat('&quot;', dsa:merkmalSub($item), '&quot;,')"/>
      </xsl:for-each>
      <xsl:text>},</xsl:text>
    </xsl:if>
    <xsl:text>
    },</xsl:text>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="merkmale">
    <xsl:variable name="name" select="substring-after(@name, ': ')"/>
    <xsl:if test="not(starts-with($name, 'Elementar') or starts-with($name, 'Dämonisch'))">
      <xsl:text>
      "</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>", </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vorteil" mode="merkmale">
    <xsl:if test="not(starts-with(@value, 'Elementar') or starts-with(@value, 'Dämonisch'))">
      <xsl:text>
      "</xsl:text>
      <xsl:value-of select="@value"/>
      <xsl:text>", </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="zauberliste">
    <xsl:text>
  zauber = {</xsl:text>
    <xsl:apply-templates select="zauber[@repraesentation != 'Magiedilletant']"/>
    <xsl:text>
  },</xsl:text>
  </xsl:template>

  <xsl:template match="zauber">
    <xsl:text>
    {"", [[</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:if test="@variante != ''">
      <xsl:value-of select="concat(' (', @variante, ')')"/>
    </xsl:if>
    <xsl:text>]], </xsl:text>
    <xsl:value-of select="concat(dsa:probe(@probe), ', ', @value, ', &quot;', @k, '&quot;, {}, ')"/>
    <xsl:value-of select="dsa:repraesentation(@repraesentation)"/>
    <xsl:if test="@hauszauber = 'true'">
      <xsl:text>, haus=true</xsl:text>
    </xsl:if>
    <xsl:text>},</xsl:text>
  </xsl:template>

</xsl:stylesheet>
