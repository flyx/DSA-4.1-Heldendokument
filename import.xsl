<?xml version="1.0"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
  <xsl:param name="min_natur" as="xs:integer" select="10"/>
  <xsl:param name="min_wissen" as="xs:integer" select="16"/>
  <xsl:param name="min_sprachen" as="xs:integer" select="10"/>
  <xsl:param name="min_handwerk" as="xs:integer" select="13"/>
  <xsl:param name="min_waffen_nk" as="xs:integer" select="5"/>
  <xsl:param name="min_waffen_fk" as="xs:integer" select="3"/>
  <xsl:param name="min_schilde" as="xs:integer" select="2"/>
  <xsl:param name="min_ruestungen" as="xs:integer" select="6"/>

  <xsl:output method="text"/>

  <xsl:variable name="meta" select="document('heldensoftware-meta.xml')/meta"/>
  <xsl:variable name="kulturen" select="$meta/kulturen"/>
  <xsl:variable name="vorUndNachteile" select="$meta/vorUndNachteile"/>
  <xsl:variable name="kampfTalente" select="$meta/talente/kampf"/>
  <xsl:variable name="naturTalente" select="$meta/talente/natur"/>
  <xsl:variable name="sprachen" select="$meta/talente/sprachen"/>
  <xsl:variable name="sonderfertigkeiten" select="$meta/sonderfertigkeiten"/>
  <xsl:variable name="kampfstile" select="$meta/kampfstile"/>
  <xsl:variable name="ausruestung" select="$meta/ausruestung"/>
  <xsl:variable name="zauber" select="$meta/zauber"/>
  <xsl:variable name="mirakel" select="$meta/mirakel"/>
  <xsl:variable name="liturgien" select="$meta/liturgien"/>

  <xsl:template match="/">
    <xsl:apply-templates select="helden/held[1]"/>
  </xsl:template>

  <func:function name="dsa:page">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <func:result>
      <xsl:text>
    </xsl:text><xsl:value-of select="concat($name, '(', $value, '),')"/>
    </func:result>
  </func:function>

  <xsl:template match="held">
    <xsl:text>Layout {
  Front {},
  Talentliste {</xsl:text>
    <xsl:value-of select="dsa:page('Sonderfertigkeiten', $sf_zeilen)"/>
    <xsl:variable name="actGaben">
      <xsl:choose>
        <xsl:when test="$min_begabungen = 0 and zauberliste/zauber[@repraesentation='Magiedilletant']">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$min_gaben"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="actBegabungen">
      <xsl:choose>
        <xsl:when test="$min_begabungen = 0 and zauberliste/zauber[@repraesentation='Magiedilletant']">
          <xsl:value-of select="$min_gaben"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$min_begabungen"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="dsa:page('Gaben', $actGaben)"/>
    <xsl:value-of select="dsa:page('Begabungen', $actBegabungen)"/>
    <xsl:value-of select="dsa:page('Kampf', $min_kampf)"/>
    <xsl:value-of select="dsa:page('Koerper', $min_koerper)"/>
    <xsl:value-of select="dsa:page('Gesellschaft', $min_gesellschaft)"/>
    <xsl:value-of select="dsa:page('Natur', $min_natur)"/>
    <xsl:value-of select="dsa:page('Wissen', $min_wissen)"/>
    <xsl:value-of select="dsa:page('SprachenUndSchriften', $min_sprachen)"/>
    <xsl:value-of select="dsa:page('Handwerk', $min_handwerk)"/>
    <xsl:text>
  },
  Kampfbogen {},
  </xsl:text>
    <xsl:choose>
      <xsl:when test="vt/vorteil[starts-with(@name, 'Geweiht')] or sf/sonderfertigkeit[starts-with(@name, 'Spätweihe')]">
        <xsl:text>Liturgiebogen {},</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Ausruestungsbogen {},</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="zauberliste/zauber[@repraesentation != 'Magiedilletant']">
      <xsl:text>
  Zauberliste {},</xsl:text>
    </xsl:if>
    <xsl:if test="talentliste/talent[starts-with(@name, 'Ritualkenntnis')]">
      <xsl:text>
  Zauberdokument {},</xsl:text>
    </xsl:if>
    <xsl:text>
}
</xsl:text>
    <xsl:apply-templates select="basis"/>
    <xsl:apply-templates select="vt"/>
    <xsl:apply-templates select="eigenschaften"/>
    <xsl:apply-templates select="basis" mode="ap"/>
    <xsl:apply-templates select="talentliste"/>
    <xsl:apply-templates select="sf"/>
    <xsl:apply-templates select="ausrüstungen" mode="nahkampf"/>
    <xsl:apply-templates select="ausrüstungen" mode="fernkampf"/>
    <xsl:apply-templates select="ausrüstungen" mode="schilde"/>
    <xsl:apply-templates select="ausrüstungen" mode="ruestung"/>
    <xsl:text>
Vermoegen {
  {"Dukaten"},
  {"Silbertaler"},
  {"Heller"},
  {"Kreuzer"},
}
</xsl:text>
  <xsl:if test="vt/vorteil[starts-with(@name, 'Geweiht')] or sf/sonderfertigkeit[starts-with(@name, 'Spätweihe')]">
    <xsl:apply-templates select="talentliste/talent[starts-with(@name, 'Liturgiekenntnis')]" mode="liturgiekenntnis"/>
    <xsl:apply-templates select="sf" mode="liturgien"/>
  </xsl:if>
  <xsl:if test="talentliste/talent[starts-with(@name, 'Ritualkenntnis')] or zauberliste/zauber[@repraesentation != 'Magiedilletant']">
    <xsl:apply-templates select="sf" mode="rituale"/>
    <xsl:apply-templates select="sf" mode="repraesentationen"/>
    <xsl:text>
Magie.Merkmalskenntnis {
  </xsl:text>
    <xsl:apply-templates select="sf" mode="merkmale">
      <xsl:with-param name="item" select="'sonderfertigkeit'"/>
      <xsl:with-param name="name" select="'Merkmalskenntnis'"/>
    </xsl:apply-templates>
    <xsl:text>
}

</xsl:text>
    </xsl:if>
    <xsl:if test="zauberliste/zauber[@repraesentation != 'Magiedilletant']">
      <xsl:apply-templates select="zauberliste"/>
    </xsl:if>
  </xsl:template>

  <func:function name="dsa:stringVal">
    <xsl:param name="value"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="contains($value, '&quot;') or contains($value, '\')">
          <xsl:value-of select="concat('[[', translate($value, '[]', '()'), ']]')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('&quot;', $value, '&quot;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="basis">
    <xsl:variable name="profession" as="xs:string">
      <xsl:value-of select="ausbildungen/ausbildung[@art='Hauptprofession']/@string"/>
      <xsl:apply-templates select="ausbildungen/ausbildung[@art!='Hauptprofession']"/>
    </xsl:variable>
    <xsl:variable name="tsatag" as="xs:string">
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
      <xsl:value-of select="concat(rasse/aussehen/@gbjahr, ' BF')"/>
    </xsl:variable>
    <xsl:text>
Held {
  Name       = </xsl:text><xsl:value-of select="dsa:stringVal(parent::held/@name)"/><xsl:text>,
  GP         = </xsl:text><xsl:value-of select="rasse/aussehen/@gpstart"/><xsl:text>,
  Rasse      = </xsl:text><xsl:value-of select="dsa:stringVal(rasse/@string)"/><xsl:text>,
  Kultur     = </xsl:text><xsl:value-of select="dsa:stringVal(kultur/@string)"/><xsl:text>,
  Profession = </xsl:text><xsl:value-of select="dsa:stringVal($profession)"/><xsl:text>,
  Geschlecht = </xsl:text><xsl:value-of select="dsa:stringVal(geschlecht/@name)"/><xsl:text>,
  Tsatag     = </xsl:text><xsl:value-of select="dsa:stringVal($tsatag)"/><xsl:text>,
  Groesse    = </xsl:text><xsl:value-of select="dsa:stringVal(concat(rasse/groesse/@value, ' Schritt'))"/><xsl:text>,
  Gewicht    = </xsl:text><xsl:value-of select="dsa:stringVal(concat(rasse/groesse/@gewicht, ' Stein'))"/><xsl:text>,
  Haarfarbe  = </xsl:text><xsl:value-of select="dsa:stringVal(rasse/aussehen/@haarfarbe)"/><xsl:text>,
  Augenfarbe = </xsl:text><xsl:value-of select="dsa:stringVal(rasse/aussehen/@augenfarbe)"/><xsl:text>,
  Stand      = </xsl:text><xsl:value-of select="dsa:stringVal(rasse/aussehen/@stand)"/><xsl:text>,
  Sozialstatus = </xsl:text><xsl:value-of select="parent::held/eigenschaften/eigenschaft[@name='Sozialstatus']/@value"/><xsl:text>,
  Titel      = </xsl:text><xsl:value-of select="dsa:stringVal(rasse/aussehen/@titel)"/><xsl:text>,
  Aussehen   = {</xsl:text>
    <xsl:value-of select="concat(dsa:stringVal(rasse/aussehen/@aussehentext0), ', ', dsa:stringVal(rasse/aussehen/@aussehentext1), ', ', dsa:stringVal(rasse/aussehen/@aussehentext2))"/><xsl:text>},
}
</xsl:text>
  </xsl:template>

  <xsl:template match="ausbildung">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@art"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@string"/>
  </xsl:template>

  <xsl:template match="vt">
    <xsl:text>
Vorteile {
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter"/><xsl:text>
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter-id"/><xsl:text>
}

Vorteile.Magisch {
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter">
    <xsl:with-param name="magisch" select="true()"/>
  </xsl:apply-templates><xsl:text>
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter-id">
    <xsl:with-param name="magisch" select="true()"/>
  </xsl:apply-templates><xsl:text>
}

Nachteile {
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter">
    <xsl:with-param name="nachteil" select="true()"/>
  </xsl:apply-templates><xsl:text>
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter-id">
    <xsl:with-param name="nachteil" select="true()"/>
  </xsl:apply-templates><xsl:text>
}

Nachteile.Eigenschaften {
  </xsl:text><xsl:apply-templates select="vorteil" mode="schlechteEigenschaft"/><xsl:text>
}

Nachteile.Magisch {
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter">
    <xsl:with-param name="nachteil" select="true()"/>
    <xsl:with-param name="magisch" select="true()"/>
  </xsl:apply-templates><xsl:text>
  </xsl:text><xsl:apply-templates select="vorteil" mode="filter-id">
    <xsl:with-param name="nachteil" select="true()"/>
    <xsl:with-param name="magisch" select="true()"/>
  </xsl:apply-templates><xsl:text>
}
</xsl:text>
  </xsl:template>

  <xsl:template match="vorteil">
    <xsl:variable name="text" as="xs:string">
      <xsl:value-of select="@name"/>
      <xsl:if test="@value != ''">
        <xsl:value-of select="concat(' ', @value)"/>
      </xsl:if>
      <xsl:for-each select="auswahl">
        <xsl:sort select="@position" data-type="number" order="descending"/>
        <xsl:value-of select="concat(' ', @value)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat(dsa:stringVal($text), ', ')"/>
  </xsl:template>

  <xsl:template match="vorteil" mode="filter">
    <xsl:param name="magisch" as="xs:boolean" select="false()"/>
    <xsl:param name="nachteil" as="xs:boolean" select="false()"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$vorUndNachteile/vn[@name=$name]"/>
    <xsl:if test="($def/@nachteil = '1') = $nachteil and ($def/@magisch = '1') = $magisch and not($def/@id) and not($def/@schlechteEigenschaft)">
      <xsl:apply-templates select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vorteil" mode="filter-id">
    <xsl:param name="magisch" as="xs:boolean" select="false()"/>
    <xsl:param name="nachteil" as="xs:boolean" select="false()"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$vorUndNachteile/vn[@name=$name]"/>
    <xsl:if test="($def/@nachteil = '1') = $nachteil and ($def/@magisch = '1') = $magisch and $def/@id and not($def/@liste and ./preceding-sibling::vorteil[starts-with(@name, $name)]) and not($def/@schlechteEigenschaft)">
      <xsl:choose>
        <xsl:when test="$def/@numbered">
          <xsl:value-of select="concat($def/@id, '(', @value, '), ')"/>
        </xsl:when>
        <xsl:when test="$def/@liste">
          <xsl:value-of select="concat($def/@id, ' {')"/>
          <xsl:for-each select=".|./following-sibling::vorteil[starts-with(@name, $name)]">
            <xsl:if test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="dsa:stringVal(@value)"/>
          </xsl:for-each>
          <xsl:text>}, </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($def/@id, '(', dsa:stringVal(@value), '), ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="vorteil" mode="schlechteEigenschaft">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$vorUndNachteile/vn[@name=$name]"/>
    <xsl:choose>
      <xsl:when test="not($def/@schlechteEigenschaft)"/>
      <xsl:when test="auswahl">
        <xsl:text>{</xsl:text>
        <xsl:value-of select="concat('&quot;', $name, ' ', auswahl[@position=1]/@value, '&quot;, ', $def/@schlechteEigenschaft, ', ', auswahl[@position=0]/@value)"/>
        <xsl:text>}, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="concat('&quot;', $name, '&quot;, ', $def/@schlechteEigenschaft, ', ', @value)"/>
        <xsl:text>}, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <func:function name="dsa:basisEig">
    <xsl:param name="label"/>
    <xsl:variable name="mod" as="xs:integer" select="eigenschaft[@name=$label]/@mod"/>
    <func:result select="concat('{', eigenschaft[@name=$label]/@mod, ', ', eigenschaft[@name=$label]/@startwert + $mod, ', ', eigenschaft[@name=$label]/@value + $mod, '}')"/>
  </func:function>

  <func:function name="dsa:abglEig">
    <xsl:param name="label"/>
    <func:result select="concat('{', eigenschaft[@name=$label]/@mod, ', ', eigenschaft[@name=$label]/@value, ', 0}')"/>
  </func:function>

  <xsl:template match="eigenschaften">
    <xsl:text>
Eigenschaften {
  MU = </xsl:text><xsl:value-of select="dsa:basisEig('Mut')"/><xsl:text>,
  KL = </xsl:text><xsl:value-of select="dsa:basisEig('Klugheit')"/><xsl:text>,
  IN = </xsl:text><xsl:value-of select="dsa:basisEig('Intuition')"/><xsl:text>,
  CH = </xsl:text><xsl:value-of select="dsa:basisEig('Charisma')"/><xsl:text>,
  FF = </xsl:text><xsl:value-of select="dsa:basisEig('Fingerfertigkeit')"/><xsl:text>,
  GE = </xsl:text><xsl:value-of select="dsa:basisEig('Gewandtheit')"/><xsl:text>,
  KO = </xsl:text><xsl:value-of select="dsa:basisEig('Konstitution')"/><xsl:text>,
  KK = </xsl:text><xsl:value-of select="dsa:basisEig('Körperkraft')"/><xsl:text>,
  LE = </xsl:text><xsl:value-of select="dsa:abglEig('Lebensenergie')"/><xsl:text>,
  AU = </xsl:text><xsl:value-of select="dsa:abglEig('Ausdauer')"/><xsl:text>,
  AE = </xsl:text><xsl:value-of select="dsa:abglEig('Astralenergie')"/><xsl:text>,
  MR = </xsl:text><xsl:value-of select="dsa:abglEig('Magieresistenz')"/><xsl:text>,
  KE = </xsl:text><xsl:value-of select="dsa:abglEig('Karmaenergie')"/><xsl:text>,
  INI = </xsl:text><xsl:value-of select="eigenschaft[@name='ini']/@mod"/><xsl:text>,
}
</xsl:text>
  </xsl:template>

  <xsl:template match="basis" mode="ap">
    <xsl:variable name="gesamt" as="xs:integer" select="abenteuerpunkte/@value"/>
    <xsl:variable name="frei" as="xs:integer" select="freieabenteuerpunkte/@value"/>
    <xsl:variable name="eingesetzt" select="$gesamt - $frei"/>
    <xsl:text>
AP {
  Gesamt = </xsl:text><xsl:value-of select="$gesamt"/><xsl:text>,
  Eingesetzt = </xsl:text><xsl:value-of select="$eingesetzt"/><xsl:text>
}
</xsl:text>
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
Talente.Gaben {</xsl:text><xsl:apply-templates select="$gaben"/><xsl:text>
}

Talente.Begabungen {</xsl:text><xsl:apply-templates select="$begabungen" mode="begabungen"/><xsl:text>
}

Talente.Kampf {</xsl:text><xsl:apply-templates select="$kampf" mode="kampf"/><xsl:text>
}

Talente.Koerper {</xsl:text><xsl:apply-templates select="$koerper" mode="koerper"/><xsl:text>
}

Talente.Gesellschaft {</xsl:text><xsl:apply-templates select="$gesellschaft"/><xsl:text>
}

Talente.Natur {</xsl:text>
  <xsl:apply-templates select="$natur"/>
  <xsl:apply-templates select="../ausrüstungen" mode="meta"/>
<xsl:text>
}

Talente.Wissen {</xsl:text><xsl:apply-templates select="$wissen"/><xsl:text>
}

Talente.SprachenUndSchriften {</xsl:text>
    <xsl:variable name="kultur" select="../basis/kultur"/>
    <xsl:apply-templates select="$sprachenSchriften[@name = dsa:muttersprache($kultur)]" mode="sprachen-schriften">
      <xsl:with-param name="kind" select="'Muttersprache'"/>
    </xsl:apply-templates>
    <xsl:if test="dsa:zweitsprache(../basis/kultur) != ''">
      <xsl:apply-templates select="$sprachenSchriften[@name = dsa:zweitsprache($kultur)]" mode="sprachen-schriften">
        <xsl:with-param name="kind" select="'Zweitsprache'"/>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:apply-templates select="$sprachenSchriften[@name != dsa:muttersprache($kultur) and @name != dsa:zweitsprache($kultur)]" mode="sprachen-schriften">
      <xsl:with-param name="kind" select="'Sprache'"/>
    </xsl:apply-templates><xsl:text>
}

Talente.Handwerk {</xsl:text><xsl:apply-templates select="$handwerk"/><xsl:text>
}
</xsl:text>
  </xsl:template>

  <xsl:template match="talent|zauber" mode="spezialisierungen">
    <xsl:param name="maxPerLine" select="28"/>
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="sfname">
      <xsl:choose>
        <xsl:when test="local-name() = 'talent'">
          <xsl:text>Talentspezialisierung</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Zauberspezialisierung</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>, {</xsl:text>
    <xsl:apply-templates select="../../sf/sonderfertigkeit[starts-with(@name, $sfname) and *[1]/@name = $name][1]" mode="spezialisierung">
      <xsl:with-param name="sfname" select="$sfname"/>
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="maxPerLine" select="$maxPerLine"/>
      <xsl:with-param name="lettersInLine" select="string-length($name) + 1"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="spezialisierung">
    <xsl:param name="sfname"/>
    <xsl:param name="name"/>
    <xsl:param name="maxPerLine"/>
    <xsl:param name="lettersInLine"/>
    <xsl:variable name="output" select="spezialisierung/@name"/>
    <xsl:variable name="newLineLen" select="$lettersInLine + string-length($output) + 1"/>
    <xsl:variable name="next" select="following-sibling::sonderfertigkeit[starts-with(@name, $sfname) and *[1]/@name = $name][1]"/>
    <xsl:if test="$newLineLen &gt; $maxPerLine">
      <xsl:text>{}, </xsl:text>
    </xsl:if>
    <xsl:value-of select="dsa:stringVal($output)"/>
    <xsl:if test="$next">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="$next" mode="spezialisierung">
        <xsl:with-param name="sfname" select="$sfname"/>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="maxPerLine" select="$maxPerLine"/>
        <xsl:with-param name="lettersInLine">
          <xsl:choose>
            <xsl:when test="$newLineLen &gt; $maxPerLine">
              <xsl:value-of select="string-length($output) + 3"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$newLineLen"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <func:function name="dsa:talentname">
    <xsl:param name="talent"/>
    <xsl:variable name="sub" select="$meta/talente/namen/sub[@von = $talent/@name]"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$sub"><xsl:value-of select="dsa:stringVal($sub/@zu)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="dsa:stringVal($talent/@name)"/></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="talent" mode="kampf">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$kampfTalente/t[@name=$name]"/>
    <xsl:if test="not($def)">
      <xsl:message terminate="yes">
        <xsl:value-of select="concat('Unbekanntes Kampftalent: ', $name)"/>
      </xsl:message>
    </xsl:if>

    <xsl:text>
  </xsl:text><xsl:value-of select="concat($def/@typ, ' {', dsa:talentname(.), ', ', dsa:stringVal($def/@steigern), ', ', dsa:stringVal($def/@be), ', ')"/>
    <xsl:if test="$def/@typ = 'Nah'">
      <xsl:variable name="kampfwerte" select="../../kampf/kampfwerte[@name=$name]"/>
      <xsl:value-of select="number($kampfwerte/attacke/@value) - number(//eigenschaft[@name='at']/@value)"/>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="@value"/>
    <xsl:apply-templates select="." mode="spezialisierungen"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <func:function name="dsa:probe">
    <xsl:param name="input"/>
    <xsl:variable name="sub1" select="substring-after($input, '(')"/>
    <xsl:variable name="sub2" select="substring-after($sub1, '/')"/>
    <xsl:variable name="sub3" select="substring-after($sub2, '/')"/>
    <func:result select="concat(dsa:stringVal(substring($sub1, 1, 2)), ', ', dsa:stringVal(substring($sub2, 1, 2)), ', ', dsa:stringVal(substring($sub3, 1, 2)))"/>
  </func:function>

  <xsl:template match="talent" mode="koerper">
    <xsl:text>
  {</xsl:text>
    <xsl:value-of select="concat(dsa:talentname(.), ', ', dsa:probe(@probe), ', ')"/>
    <xsl:choose>
      <xsl:when test="starts-with(@be, 'BE')">
        <xsl:value-of select="dsa:stringVal(@be)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>""</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(', ', @value)"/>
    <xsl:apply-templates select="." mode="spezialisierungen"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="talent">
    <xsl:text>
  {</xsl:text>
    <xsl:value-of select="concat(dsa:talentname(.), ', ', dsa:probe(@probe), ', ', @value)"/>
    <xsl:apply-templates select="." mode="spezialisierungen"/>
    <xsl:text>},</xsl:text>
  </xsl:template>
  
  <xsl:template match="ausrüstungen" mode="meta">
    <xsl:variable name="jw" select="heldenausruestung[@name='jagtwaffe' and @set='0']"/>
    <xsl:if test="$jw and ../talentliste/talent[@name='Tierkunde'] and ../talentliste/talent[@name='Fährtensuchen']">
      <xsl:text>
  Meta {"Pirschjagd", "MU", "IN", "GE", {"Wildnisleben", "Tierkunde", "Fährtensuchen", "Schleichen", </xsl:text>
      <xsl:variable name="ha" select="heldenausruestung[@name=concat('fkwaffe', $jw/@nummer) and @set='0']"/>
      <xsl:value-of select="concat('&quot;', $ha/@talent, '&quot;')"/>
      <xsl:text>}},</xsl:text>
      <xsl:text>
    Meta {"Ansitzjagd", "MU", "IN", "GE", {"Wildnisleben", "Tierkunde", "Fährtensuchen", "Sich Verstecken", </xsl:text>
      <xsl:value-of select="concat('&quot;', $ha/@talent, '&quot;')"/>
      <xsl:text>}},</xsl:text>
    </xsl:if>
    <xsl:if test="../talentliste/talent[@name='Pflanzenkunde']">
    Meta {"Nahrung Sammeln / Kräuter Suchen", "MU", "IN", "FF", {"Wildnisleben", "Sinnenschärfe", "Pflanzenkunde"}},
    </xsl:if>
  </xsl:template>

  <xsl:template match="talent" mode="sprachen-schriften">
    <xsl:param name="kind" select="'Sprache'"/>
    <xsl:variable name="name" select="substring(@name, 17)"/>
    <xsl:text>
  </xsl:text>
    <xsl:choose>
      <xsl:when test="starts-with(@name, 'Lesen/Schreiben')">
        <xsl:variable name="schrift" select="$sprachen//schrift[text() = $name]"/>
        <xsl:variable name="komp">
          <xsl:choose>
            <xsl:when test="$schrift">
              <xsl:value-of select="$schrift/@komp"/>
            </xsl:when>
            <xsl:otherwise>A</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat('Schrift {', dsa:stringVal($name), ', ', dsa:stringVal($komp), ', ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($kind, ' {', dsa:stringVal(substring(@name, 17)), ', ')"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="concat(@k, ', ', @value)"/>
    <xsl:if test="not(starts-with(@name, 'Lesen/Schreiben'))">
      <xsl:apply-templates select="." mode="spezialisierungen"/>
    </xsl:if>
    <xsl:if test="$kind = 'Muttersprache'">
      <xsl:variable name="familie" select="$sprachen/familie[sprache[text() = $name]]"/>
      <xsl:text>, {</xsl:text>
      <xsl:for-each select="$familie/sprache[text() != $name]">
        <xsl:if test="position() &gt; 1">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:value-of select="dsa:stringVal(text())"/>
      </xsl:for-each>
      <xsl:text>}, {</xsl:text>
      <xsl:for-each select="$familie/schrift">
        <xsl:if test="position() &gt; 1">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:value-of select="dsa:stringVal(text())"/>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="zauber" mode="begabungen">
    <xsl:variable name="text" as="xs:string">
      <xsl:value-of select="@name"/>
      <xsl:if test="@variante != ''">
        <xsl:value-of select="concat(' (', @variante, ')')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:text>
  {</xsl:text>
    <xsl:value-of select="concat(dsa:stringVal($text), ', ', dsa:probe(@probe), ', ', @value, '},')"/>
  </xsl:template>

  <xsl:template match="sf">
    <xsl:text>
SF {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit"/>
    <xsl:text>
}

SF.Nahkampf {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit">
      <xsl:with-param name="art" select="'nahkampf'"/>
    </xsl:apply-templates>
    <xsl:text>
}

SF.Fernkampf {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit">
      <xsl:with-param name="art" select="'fernkampf'"/>
    </xsl:apply-templates>
    <xsl:text>
}

SF.Waffenlos {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit">
      <xsl:with-param name="art" select="'waffenlos'"/>
    </xsl:apply-templates><xsl:text>
  </xsl:text><xsl:apply-templates select="sonderfertigkeit" mode="boni"/>
    <xsl:text>
}

SF.Magisch {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit">
      <xsl:with-param name="art" select="'magisch'"/>
    </xsl:apply-templates>
    <xsl:text>
}
</xsl:text>
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
        <xsl:when test="starts-with(@name, 'Liturgiekenntnis')">
          <xsl:text>liturgiekenntnis</xsl:text>
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
        <xsl:when test="$kind = 'liturgiekenntnis'">
          <xsl:text>Liturgiekenntnis</xsl:text>
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

  <func:function name="dsa:leiteigenschaft">
    <xsl:variable name="ritk" select="substring-after(//sonderfertigkeit[starts-with(@name, 'Ritualkenntnis: ')]/@name, 'Ritualkenntnis: ')"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$ritk = 'Kristallomant' or $ritk = 'Derwisch' or $ritk = 'Durro-Dûn' or $ritk = 'Elf' or $ritk = 'Ferkina' or $ritk = 'Geode' or $ritk = 'Hexe' or $ritk = 'Schamane' or $ritk = 'Schelm' or $ritk = 'Zaubertänzer'">
          <xsl:text>IN</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>KL</xsl:text>
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
    <xsl:if test="not($def/@boni) and not(./preceding-sibling::sonderfertigkeit[starts-with(@name, $name)]) and ((not($def/@art) and $art = '') or ($art = $def/@art))">
      <xsl:choose>
        <xsl:when test="$def/@leit">
          <xsl:value-of select="concat($def/@id, '(', dsa:stringVal(dsa:leiteigenschaft()), '), ')"/>
        </xsl:when>
        <xsl:when test="$kind = 'roman'">
          <xsl:choose>
            <xsl:when test="$def/@id">
              <xsl:value-of select="concat($def/@id, ' {I')"/>
              <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' II')]">
                <xsl:text>, II</xsl:text>
              </xsl:if>
              <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' III')]">
                <xsl:text>, III</xsl:text>
              </xsl:if>
              <xsl:text>}, </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('&quot;', $name, ' I')"/>
              <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' II')]">
                <xsl:text>, II</xsl:text>
              </xsl:if>
              <xsl:if test="./following-sibling::sonderfertigkeit[@name=concat($name, ' III')]">
                <xsl:text>, III</xsl:text>
              </xsl:if>
              <xsl:text>", </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$kind = 'named'">
          <xsl:for-each select=".|./following-sibling::sonderfertigkeit[starts-with(@name, $name)]">
            <xsl:value-of select="concat(dsa:stringVal(concat($name, ' (', substring-after(@name, ': '), ')')), ', ')"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$kind = 'sub' and $def/@container">
          <xsl:value-of select="concat($def/@container, ' {')"/>
          <xsl:for-each select="(.|./following-sibling::sonderfertigkeit[starts-with(@name, $name)])/*[local-name() = $def/@sub]">
            <xsl:if test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="dsa:stringVal(@name)"/>
          </xsl:for-each>
          <xsl:text>}, </xsl:text>
        </xsl:when>
        <xsl:when test="$kind = 'sub'">
          <xsl:variable name="text">
            <xsl:value-of select="concat($name, ' (')"/>
            <xsl:for-each select="(.|./following-sibling::sonderfertigkeit[starts-with(@name, $name)])/*[local-name() = $def/@sub]">
              <xsl:if test="position() &gt; 1">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="@name"/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:variable>
          <xsl:value-of select="concat(dsa:stringVal($text), ', ')"/>
        </xsl:when>
        <xsl:when test="$kind = 'simple'">
          <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
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

  <func:function name="dsa:kampfstilTalent">
    <xsl:param name="name"/>
    <xsl:variable name="def" select="$kampfstile/stil[@name = substring-after($name, ': ')]"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$def/@talent">
          <xsl:value-of select="$def/@talent"/>
        </xsl:when>
        <xsl:when test="../../BoniWaffenlos/boniSF[@sf=$name]/@talent">
          <xsl:value-of select="../../BoniWaffenlos/boniSF[@sf=$name]/@talent"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="sonderfertigkeit" mode="boni">
    <xsl:variable name="kind" select="dsa:sfKind()"/>
    <xsl:variable name="name" select="dsa:sfName($kind)"/>
    <xsl:variable name="def" select="$sonderfertigkeiten/sf[@name=$name]"/>
    <xsl:if test="$def/@boni = '1' and not(./preceding-sibling::sonderfertigkeit[starts-with(@name, $name)])">
      <xsl:for-each select=".|./following-sibling::sonderfertigkeit[starts-with(@name, $name)]">
        <xsl:if test="position() != 1">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:value-of select="concat($def/@id, ' {')"/>
        <xsl:value-of select="concat(dsa:stringVal(substring-after(@name, ': ')), ', ', dsa:stringVal(dsa:kampfstilTalent(@name)), '}')"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <func:function name="dsa:singleval">
    <xsl:param name="input"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="contains($input, '+')">
          <xsl:value-of select="number(substring-after($input, '+'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number($input)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result>
      <xsl:choose>
        <xsl:when test="string($num) = 'NaN'">
          <xsl:value-of select="dsa:stringVal($input)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$num"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:doubleval">
    <xsl:param name="input" />
    <func:result select="concat(dsa:singleval(substring-before($input, '/')), ', ', dsa:singleval(substring-after($input, '/')))"/>
  </func:function>
  
  <func:function name="dsa:tp">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat('&quot;', $explicit/@mul, 'W', $explicit/@w, '+', $explicit/@sum, '&quot;')"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:stringVal($meta/@tp)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>""</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:dk">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:text>"</xsl:text>
          <xsl:if test="$explicit/distanzklasse[@value='Handgemenge']">H</xsl:if>
          <xsl:if test="$explicit/distanzklasse[@value='Nah']">N</xsl:if>
          <xsl:if test="$explicit/distanzklasse[@value='Stangenwaffe']">S</xsl:if>
          <xsl:if test="$explicit/distanzklasse[@value='Pike']">P</xsl:if>
          <xsl:text>"</xsl:text>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:stringVal($meta/@dk)"/>
        </xsl:when>
        <xsl:otherwise><xsl:text>{}</xsl:text></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:tpkk">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat($explicit/@kk, ', ', $explicit/@schrittweite)"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:doubleval($meta/@tpkk)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>{}, {}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:ini">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="$explicit/@ini"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:singleval($meta/@ini)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>{}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:wm">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat($explicit/@at, ', ', $explicit/@pa)"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:doubleval($meta/@wm)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>{}, {}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="ausrüstungen" mode="nahkampf">
    <xsl:text>
Waffen.Nahkampf {</xsl:text>
    <xsl:apply-templates select="heldenausruestung[@set = 0 and starts-with(@name, 'nkwaffe')]" mode="nahkampf"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <xsl:template match="heldenausruestung" mode="nahkampf">
    <xsl:variable name="name" select="@waffenname"/>
    <xsl:variable name="talent" select="@talent"/>
    <xsl:variable name="slot" select="@slot"/>
    <xsl:variable name="nkwaffe" select="../../gegenstände/gegenstand[@name = $name and @slot = $slot]/Nahkampfwaffe"/>
    <xsl:variable name="def" select="$ausruestung/nahkampf[@typ=$talent]/w[@name=$name]"/>
    <xsl:variable name="modName" select="$nkwaffe/../modallgemein/name"/>
    <xsl:text>
  {</xsl:text>
    
    <xsl:choose>
      <xsl:when test="$modName">
        <xsl:value-of select="concat(dsa:stringVal($modName/@value), ', ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(dsa:stringVal($talent), ', ')"/>
    <xsl:value-of select="concat(dsa:dk($nkwaffe/distanzklassen, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:tp($nkwaffe/trefferpunkte, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:tpkk($nkwaffe/tpkk, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:ini($nkwaffe/inimod, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:wm($nkwaffe/wm, $def), ', ')"/>
    <xsl:value-of select="@bfmin"/>
    <xsl:if test="$modName">
      <xsl:value-of select="concat(', Art=', dsa:stringVal($name))"/>
    </xsl:if>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="ausrüstungen" mode="fernkampf">
    <xsl:text>
Waffen.Fernkampf {</xsl:text>
    <xsl:apply-templates select="heldenausruestung[@set= 0 and starts-with(@name, 'fkwaffe')]" mode="fernkampf"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:partition">
    <xsl:param name="input"/>
    <xsl:variable name="cur">
      <xsl:choose>
        <xsl:when test="contains($input, '/')">
          <xsl:value-of select="substring-before($input, '/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$input"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result>
      <xsl:value-of select="dsa:singleval($cur)"/>
      <xsl:if test="contains($input, '/')">
        <xsl:value-of select="concat(', ', dsa:partition(substring-after($input, '/')))"/>
      </xsl:if>
    </func:result>
  </func:function>
  
  <func:function name="dsa:entfernungen">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat($explicit/@E0, ', ', $explicit/@E1, ', ', $explicit/@E2, ', ', $explicit/@E3, ', ', $explicit/@E4)"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:partition($meta/@rw)"/>
        </xsl:when>
        <xsl:otherwise><xsl:text>{},{},{},{},{}</xsl:text></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:tpmod">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat($explicit/@M0, ', ', $explicit/@M1, ', ', $explicit/@M2, ', ', $explicit/@M3, ', ', $explicit/@M4)"/>
        </xsl:when>
        <xsl:when test="$meta">
          <xsl:value-of select="dsa:partition($meta/@tprw)"/>
        </xsl:when>
        <xsl:otherwise><xsl:text>{},{},{},{},{}</xsl:text></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
  
  <func:function name="dsa:laden">
    <xsl:param name="explicit"/>
    <xsl:param name="meta"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="$explicit/@aktionen"/>
        </xsl:when>
        <xsl:when test="$meta/@laden">
          <xsl:value-of select="$meta/@laden"/>
        </xsl:when>
        <xsl:otherwise><xsl:text>{}</xsl:text></xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="heldenausruestung" mode="fernkampf">
    <xsl:variable name="name" select="@waffenname" />
    <xsl:variable name="talent" select="@talent" />
    <xsl:variable name="slot" select="@slot"/>
    <xsl:variable name="fkwaffe" select="../../gegenstände/gegenstand[@name = $name and @slot = $slot]/Fernkampfwaffe"/>
    <xsl:variable name="modName" select="$fkwaffe/../modallgemein/name"/>
    <xsl:variable name="def" select="$ausruestung/fernkampf[@typ=$talent]/w[@name=$name]"/>
    <xsl:text>
  {</xsl:text>
    <xsl:choose>
      <xsl:when test="$modName">
        <xsl:value-of select="concat(dsa:stringVal($modName/@value), ', ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(dsa:stringVal($talent), ', ')"/>
    
    <xsl:value-of select="concat(dsa:tp($fkwaffe/trefferpunkte, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:entfernungen($fkwaffe/entfernung, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:tpmod($fkwaffe/tpmod, $def), ', ')"/>
    <xsl:value-of select="dsa:laden($fkwaffe/laden, $def)"/>
    <xsl:if test="$def/@verminderteWS"><xsl:text>, VerminderteWS=true</xsl:text></xsl:if>
    <xsl:if test="$modName">
      <xsl:value-of select="concat(', Art=', dsa:stringVal($name))"/>
    </xsl:if>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="ausrüstungen" mode="schilde">
    <xsl:text>
Waffen.SchildeUndParierwaffen {</xsl:text>
    <xsl:apply-templates select="heldenausruestung[@set = 0 and starts-with(@name, 'schild')]" mode="schilde"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <xsl:template match="heldenausruestung" mode="schilde">
    <xsl:variable name="name" select="@schildname" />
    <xsl:variable name="slot" select="@slot"/>
    <xsl:variable name="schild" select="../../gegenstände/gegenstand[@name = $name and @slot = $slot]/Schild"/>
    <xsl:text>
  </xsl:text>
    <xsl:choose>
      <xsl:when test="@verwendungsArt = 'Schild'">
        <xsl:text>Schild {</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Parierwaffe {</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
    <xsl:variable name="def" select="$ausruestung/schildeParier/s[@name=$name]"/>
    <xsl:value-of select="concat(dsa:ini($schild/inimod, $def), ', ')"/>
    <xsl:value-of select="concat(dsa:wm($schild/wm, $def), ', ')"/>
    <xsl:choose>
      <xsl:when test="$schild"><xsl:value-of select="$schild/bf/@min"/></xsl:when>
      <xsl:when test="$def"><xsl:value-of select="$def/@bf"/></xsl:when>
      <xsl:otherwise><xsl:text>{}</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="@bfmin"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="ausrüstungen" mode="ruestung">
    <xsl:text>
Waffen.Ruestung {</xsl:text>
    <xsl:apply-templates select="heldenausruestung[@set = 0 and starts-with(@name, 'ruestung')]" mode="ruestung"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:zrs">
    <xsl:param name="def"/>
    <xsl:param name="explicit"/>
    <xsl:param name="dn"/>
    <xsl:param name="tn"/>
    <xsl:variable name="attr" select="$def/@*[local-name() = $dn]"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$explicit">
          <xsl:value-of select="concat($tn, '=', $explicit/@value, ', ')"/>
        </xsl:when>
        <xsl:when test="$attr">
          <xsl:value-of select="concat($tn, '=', $attr, ', ')"/>
        </xsl:when>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="heldenausruestung" mode="ruestung">
    <xsl:variable name="name" select="@ruestungsname"/>
    <xsl:variable name="slot" select="@slot"/>
    <xsl:variable name="ruestung" select="../../gegenstände/gegenstand[@name = $name and @slot = $slot]/Rüstung"/>
    <xsl:text>
  {</xsl:text>
    <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
    <xsl:variable name="def" select="$ausruestung/ruestung/r[@name=$name]"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/kopf, 'ko', 'Kopf')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/brust, 'br', 'Brust')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/ruecken, 'ru', 'Ruecken')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/bauch, 'ba', 'Bauch')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/linkerarm, 'la', 'LArm')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/rechterarm, 'ra', 'RArm')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/linkesbein, 'lb', 'LBein')"/>
    <xsl:value-of select="dsa:zrs($def, $ruestung/rechtesbein, 'rb', 'RBein')"/>
    <xsl:if test="$def/@z"><xsl:text>Z=true, </xsl:text></xsl:if>
    <xsl:value-of select="dsa:zrs($def, $ruestung/sterne, 'sterne', 'Sterne')"/>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <xsl:template match="talent" mode="liturgiekenntnis">
    <xsl:text>
Mirakel.Liturgiekenntnis {</xsl:text>
    <xsl:variable name="gott" select="substring-before(substring-after(@name, '('), ')')"/>
    <xsl:value-of select="dsa:stringVal($gott)"/>
    <xsl:value-of select="concat(', ', @value, '}')"/>
    <xsl:text>

Mirakel.Plus {</xsl:text>
    <xsl:call-template name="list-mirakel">
      <xsl:with-param name="input" select="$mirakel/plus[@gott = $gott]/text()"/>
    </xsl:call-template>
    <xsl:text>}

Mirakel.Minus {</xsl:text>
    <xsl:call-template name="list-mirakel">
      <xsl:with-param name="input" select="$mirakel/minus[@gott = $gott]/text()"/>
    </xsl:call-template>
    <xsl:text>}
</xsl:text>
  </xsl:template>

  <xsl:template name="list-mirakel">
    <xsl:param name="input"/>
    <xsl:choose>
      <xsl:when test="contains($input, '|')">
        <xsl:value-of select="concat(dsa:stringVal(substring-before($input, '|')), ', ')"/>
        <xsl:call-template name="list-mirakel">
          <xsl:with-param name="input" select="substring-after($input, '|')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="dsa:stringVal($input)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sf" mode="liturgien">
    <xsl:text>
Mirakel.Liturgien {</xsl:text>
    <xsl:apply-templates select="sonderfertigkeit[starts-with(@name, 'Liturgie: ')]" mode="liturgien-klseg"/>
    <xsl:apply-templates select="sonderfertigkeit[starts-with(@name, 'Liturgie: ')]" mode="liturgien-sonst"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:litname">
    <xsl:param name="base"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="contains($base, ' (')">
          <xsl:value-of select="substring-before($base, ' (')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$base"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:litorigname">
    <xsl:param name="base"/>
    <xsl:variable name="tmp">
      <xsl:for-each select="$liturgien/g">
        <xsl:variable name="suffix" select="concat(' (', text(), ')')"/>
        <xsl:if test="contains($base, $suffix)">
          <xsl:value-of select="substring-before($base, $suffix)"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ohneGrad">
      <xsl:choose>
        <xsl:when test="string-length($tmp) = 0">
          <xsl:value-of select="$base"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <func:result>
      <xsl:choose>
        <xsl:when test="contains($ohneGrad, ' (')">
          <xsl:value-of select="substring-before(substring-after($ohneGrad, '('), ')')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ohneGrad"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <func:function name="dsa:litgrad">
    <xsl:param name="base"/>
    <func:result>
      <xsl:for-each select="$liturgien/g">
        <xsl:variable name="suffix" select="concat(' (', text(), ')')"/>
        <xsl:if test="contains($base, $suffix)">
          <xsl:value-of select="text()"/>
        </xsl:if>
      </xsl:for-each>
    </func:result>
  </func:function>

  <xsl:template match="sonderfertigkeit" mode="liturgien-klseg">
    <xsl:variable name="base" select="substring(@name, string-length('Liturgie: ') + 1)"/>
    <xsl:variable name="name" select="dsa:litname($base)"/>
    <xsl:variable name="def" select="$liturgien/l[@n=dsa:litorigname($base)]"/>
    <xsl:variable name="grad" select="dsa:litgrad($base)"/>
    <xsl:if test="$def/@zw and string-length($grad) = 0">
      <xsl:apply-templates select="." mode="liturgien">
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="def" select="$def"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="liturgien-sonst">
    <xsl:variable name="base" select="substring(@name, string-length('Liturgie: ') + 1)"/>
    <xsl:variable name="name" select="dsa:litname($base)"/>
    <xsl:variable name="def" select="$liturgien/l[@n=dsa:litorigname($base)]"/>
    <xsl:variable name="grad" select="dsa:litgrad($base)"/>
    <xsl:if test="not($def/@zw) and string-length($grad) = 0">
      <xsl:apply-templates select="." mode="liturgien">
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="def" select="$def"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="liturgien">
    <xsl:param name="name"/>
    <xsl:param name="def"/>
    <xsl:variable name="full" select="@name"/>
    <xsl:choose>
      <xsl:when test="$def/@zw">
        <xsl:text>
  Segnung {</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
  Liturgie {</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$def">
        <xsl:value-of select="$def/@s"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>""</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$def/@orig">
        <xsl:value-of select="concat(', ', dsa:stringVal($def/@orig))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(', ', dsa:stringVal($name))"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="not($def/@zw)">
      <xsl:text>, {</xsl:text>
      <xsl:choose>
        <xsl:when test="$def">
          <xsl:value-of select="$def/@g"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>I</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="following-sibling::*[starts-with(@name, $full)]">
        <xsl:value-of select="concat(', ', dsa:litgrad(@name))"/>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
     </xsl:if>
    <xsl:text>},</xsl:text>
  </xsl:template>

  <func:function name="dsa:isRitual">
    <xsl:param name="name"/>
    <func:result select="$sonderfertigkeiten/sf[@name=$name]/@art = 'ritual'"/>
  </func:function>

  <xsl:template match="sf" mode="rituale">
    <xsl:text>
Magie.Rituale {</xsl:text>
    <xsl:apply-templates select="sonderfertigkeit[dsa:isRitual(substring-before(@name, ': '))]" mode="rituale"/>
    <xsl:text>
}

Magie.Ritualkenntnis {</xsl:text>
      <xsl:apply-templates select="../talentliste/talent[starts-with(@name, 'Ritualkenntnis')]" mode="ritualkenntnis"/>
      <xsl:text>
}
</xsl:text>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="rituale">
    <xsl:text>
  {</xsl:text>
    <xsl:value-of select="dsa:stringVal(substring-after(@name, ': '))"/>
    <xsl:text>, "", "", "", "", "", ""},</xsl:text>
  </xsl:template>

  <xsl:template match="talent" mode="ritualkenntnis">
    <xsl:text>
  {</xsl:text>
    <xsl:variable name="steiger">
      <xsl:choose>
        <xsl:when test="@value = 'Alchimist' or @value = 'Scharlatan'">
          <xsl:text>D</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>E</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(dsa:stringVal(substring-after(@name, ': ')), ', ', dsa:stringVal($steiger), ', ', @value, '},')"/>
  </xsl:template>

  <xsl:template match="sf" mode="repraesentationen">
    <xsl:text>
Magie.Repraesentationen {
  </xsl:text>
    <xsl:apply-templates select="sonderfertigkeit[starts-with(@name, 'Repräsentation: ')]" mode="repraesentationen"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:repraesentation">
    <xsl:param name="input"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="$input = 'Achaz'"><xsl:text>"Ach"</xsl:text></xsl:when>
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
        <xsl:when test="$input = 'Magier'"><xsl:text>"Mag"</xsl:text></xsl:when>
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
        <func:result select="substring-before(substring-after($base, '('), ')')"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="'gesamt'"/>
      </xsl:otherwise>
    </xsl:choose>

  </func:function>

  <xsl:template match="sf|vt" mode="merkmale">
    <xsl:param name="item"/>
    <xsl:param name="name"/>
    <xsl:variable name="items" select="*[local-name() = $item and starts-with(@name, $name)]"/>
    <xsl:apply-templates select="$items" mode="merkmale"/>
    <xsl:variable name="ele" select="$items[starts-with(dsa:merkmalBase($item, .), 'Elementar')]"/>
    <xsl:if test="count($ele) &gt; 0">
      <xsl:text>
  Elementar {</xsl:text>
      <xsl:for-each select="$ele">
        <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
        <xsl:value-of select="dsa:stringVal(dsa:merkmalSub($item))"/>
      </xsl:for-each>
      <xsl:text>},</xsl:text>
    </xsl:if>
    <xsl:variable name="dae" select="$items[starts-with(dsa:merkmalBase($item, .), 'Dämonisch')]"/>
    <xsl:if test="count($dae) &gt; 0">
      <xsl:text>
  Daemonisch {</xsl:text>
      <xsl:for-each select="$dae">
        <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
        <xsl:value-of select="dsa:stringVal(dsa:merkmalSub($item))"/>
      </xsl:for-each>
      <xsl:text>},</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sonderfertigkeit" mode="merkmale">
    <xsl:variable name="name" select="substring-after(@name, ': ')"/>
    <xsl:if test="not(starts-with($name, 'Elementar') or starts-with($name, 'Dämonisch'))">
      <xsl:value-of select="concat(dsa:stringVal($name), ', ')"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vorteil" mode="merkmale">
    <xsl:if test="not(starts-with(@value, 'Elementar') or starts-with(@value, 'Dämonisch'))">
      <xsl:value-of select="concat(dsa:stringVal(@value), ', ')"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="vt" mode="single">
    <xsl:param name="item"/>
    <xsl:param name="name"/>
    <xsl:for-each select="*[local-name() = $item and starts-with(@name, $name)]">
      <xsl:value-of select="concat(dsa:stringVal(@value), ', ')"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="zauberliste">
    <xsl:text>
Magie.Zauber {</xsl:text>
    <xsl:apply-templates select="zauber[@repraesentation != 'Magiedilletant']"/>
    <xsl:text>
}
</xsl:text>
  </xsl:template>

  <func:function name="dsa:commasep">
    <xsl:param name="input"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="contains($input, ',')">
          <xsl:value-of select="concat(dsa:stringVal(substring-before($input, ',')), ', ', dsa:commasep(substring-after($input, ',')))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="dsa:stringVal($input)"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="zauber">
    <xsl:variable name="name" select="@name"/>
    <xsl:variable name="def" select="$zauber/z[starts-with($name, @n)]"/>
    <xsl:text>
  {</xsl:text>
    <xsl:choose>
      <xsl:when test="$def and $def/@s">
        <xsl:value-of select="$def/@s"/>
      </xsl:when>
      <xsl:when test="$def">
        <xsl:variable name="last" select="($def/preceding-sibling::z[@s])[last()]"/>
        <xsl:variable name="between" select="$last/following-sibling::z[following-sibling::z[@n=$def/@n]]"/>
        <xsl:value-of select="number($last/@s) + count($between) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>{}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>, </xsl:text>
    <xsl:variable name="text" as="xs:string">
      <xsl:choose>
        <xsl:when test="$def">
          <xsl:value-of select="$def/@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@variante != ''">
        <xsl:value-of select="concat(' (', @variante, ')')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat(dsa:stringVal($text), ', ', dsa:probe(@probe), ', ', @value, ', &quot;', @k, '&quot;, {')"/>

    <xsl:if test="$def">
      <xsl:if test="$def/@m">
        <xsl:value-of select="dsa:commasep($def/@m)"/>
        <xsl:if test="$def/@d or $def/@e">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$def/@d">
        <xsl:text>Daemonisch {</xsl:text>
        <xsl:if test="$def/@d != ''">
          <xsl:value-of select="dsa:commasep($def/@d)"/>
        </xsl:if>
        <xsl:text>}</xsl:text>
        <xsl:if test="$def/@e">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$def/@e">
        <xsl:text>Elementar {</xsl:text>
        <xsl:if test="$def/@e != ''">
          <xsl:value-of select="dsa:commasep($def/@e)"/>
        </xsl:if>
        <xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:value-of select="concat('}, ', dsa:repraesentation(@repraesentation))"/>
    <xsl:choose>
      <xsl:when test="@hauszauber = 'true'">
        <xsl:text>, true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>, false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="." mode="spezialisierungen"/>
    <xsl:text>},</xsl:text>
  </xsl:template>
</xsl:transform>
