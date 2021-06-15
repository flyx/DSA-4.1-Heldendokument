<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:dsa="https://flyx.org/dsa-4.1-heldendokument"
    extension-element-prefixes="exslt func">
  <xsl:output method="text"/>

  <xsl:variable name="kulturen_raw">
    <k name="helden.model.kultur.Garetien" muttersprache="Garethi"/>
    <k name="helden.model.kultur.AndergastNostria" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Bornland" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Svellttal"/>
    <k name="helden.model.kultur.Almada" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Horasreich" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Zyklopeninseln"/>
    <k name="helden.model.kultur.Amazonenburg" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Aranien"/>
    <k name="helden.model.kultur.Mhanadistan" muttersprache="Tulamidya" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.TulamidischeStadtstaaten" muttersprache="Tulamidya" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.Novadi" muttersprache="Tulamidya"/>
    <k name="helden.model.kultur.Ferkina" muttersprache="Ferkina" zweitsprache="Tulamidya"/>
    <k name="helden.model.kultur.Zahori" muttersprache="Tulamidya" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.Thorwal" muttersprache="Thorwalsch" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.Gjalskerland" muttersprache="Thorwalsch"/>
    <k name="helden.model.kultur.Fjarninger" muttersprache="Thorwalsch"/>
    <k name="helden.model.kultur.Dschungelstaemme" muttersprache="Mohisch"/>
    <k name="helden.model.kultur.VerloreneStaemme" muttersprache="Mohisch"/>
    <k name="helden.model.kultur.WaldinselUtulus" muttersprache="Mohisch"/>
    <k name="helden.model.kultur.Miniwatu" muttersprache="Mohisch"/>
    <k name="helden.model.kultur.Tocamuyac" muttersprache="Mohisch"/>
    <k name="helden.model.kultur.Maraskan"/>
    <k name="helden.model.kultur.Suedaventurien" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Bukanier" muttersprache="Garethi"/>
    <k name="helden.model.kultur.Nivesenstaemme" muttersprache="Nujuka"/>
    <k name="helden.model.kultur.NuanaaeLie" muttersprache="Nujuka"/>
    <k name="helden.model.kultur.Norbardensippe" muttersprache="Alaani"/>
    <k name="helden.model.kultur.Trollzacken" muttersprache="Zulchammaqra"/>
    <k name="helden.model.kultur.AuelfischeSippe" muttersprache="Isdira"/>
    <k name="helden.model.kultur.ElfischeSiedlung" muttersprache="Isdira"/>
    <k name="helden.model.kultur.SteppenelfischeSippe" muttersprache="Isdira"/>
    <k name="helden.model.kultur.WaldelfischeSippe" muttersprache="Isdira"/>
    <k name="helden.model.kultur.FirnelfischeSippe" muttersprache="Isdira"/>
    <k name="helden.model.kultur.Ambosszwerge" muttersprache="Rogolan"/>
    <k name="helden.model.kultur.Erzzwerge" muttersprache="Rogolan"/>
    <k name="helden.model.kultur.Huegelzwerge" muttersprache="Rogolan" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.Brillantzwerge" muttersprache="Rogolan"/>
    <k name="helden.model.kultur.Brobim" muttersprache="Rogolan"/>
    <k name="helden.model.kultur.Orkland" muttersprache="Ologhaijan"/>
    <k name="helden.model.kultur.Yurach" muttersprache="Oloarkh"/>
    <k name="helden.model.kultur.SvellttalBesatzer" muttersprache="Ologhaijan" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.Goblinstamm" muttersprache="Goblinisch"/>
    <k name="helden.model.kultur.Goblinbande" muttersprache="Goblinisch" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.FestumerGhetto" muttersprache="Goblinisch" zweitsprache="Garethi"/>
    <k name="helden.model.kultur.ArchaischeAchaz" muttersprache="Rssahh"/>
    <k name="helden.model.kultur.StammesAchaz" muttersprache="Rssahh"/>
  </xsl:variable>

  <xsl:variable name="kulturen" select="exslt:node-set($kulturen_raw)"/>

  <xsl:variable name="vun_raw">
    <vn name="Aberglaube" nachteil="1"/>
    <vn name="Affinität zu" magisch="1"/>
    <vn name="Akademische Ausbildung (Magier)" magisch="1"/>
    <vn name="Albino" nachteil="1"/>
    <vn name="Angst vor" nachteil="1"/>
    <vn name="Animalische Magie" nachteil="1" magisch="1"/>
    <vn name="Arroganz" nachteil="1"/>
    <vn name="Artefaktgebunden" nachteil="1" magisch="1"/>
    <vn name="Astrale Regeneration" magisch="1"/>
    <vn name="Astraler Block" nachteil="1" magisch="1"/>
    <vn name="Astralmacht" magisch="1"/>
    <vn name="Ausdauernder Zauberer" magisch="1"/>
    <vn name="Autoritätsgläubig" nachteil="1"/>
    <vn name="Begabung für [Merkmal]" magisch="1" id="begabung_merkmal" liste="1"/>
    <vn name="Begabung für [Ritual]" magisch="1"/>
    <vn name="Begabung für [Zauber]" magisch="1" id="begabung_zauber" liste="1"/>
    <vn name="Behäbig" nachteil="1" id="behaebig"/>
    <vn name="Blutdurst" nachteil="1"/>
    <vn name="Blutrausch" nachteil="1"/>
    <vn name="Brünstigkeit" nachteil="1"/>
    <vn name="Dunkelangst" nachteil="1"/>
    <vn name="Eigeboren" magisch="1"/>
    <vn name="Einarmig" nachteil="1"/>
    <vn name="Einäugig" nachteil="1"/>
    <vn name="Einbeinig" nachteil="1"/>
    <vn name="Einbildungen" nachteil="1"/>
    <vn name="Eingeschränkter Sinn" nachteil="1"/>
    <vn name="Einhändig" nachteil="1"/>
    <vn name="Eisenaffine Aura" magisch="1"/>
    <vn name="Eitelkeit" nachteil="1"/>
    <vn name="Elfische Weltsicht" nachteil="1"/>
    <vn name="Ererbte Knochenkeule" magisch="1"/>
    <vn name="Farbenblind" nachteil="1"/>
    <vn name="Feind" nachteil="1"/>
    <vn name="Feste Gewohnheit" nachteil="1" magisch="1"/>
    <vn name="Feste Matrix" magisch="1"/>
    <vn name="Festgefügtes Denken" nachteil="1" magisch="1"/>
    <vn name="Fettleibig" nachteil="1"/>
    <vn name="Fluch der Finsternis" nachteil="1" magisch="1"/>
    <vn name="Geiz" nachteil="1"/>
    <vn name="Gerechtigkeitswahn" nachteil="1"/>
    <vn name="Gesucht" nachteil="1"/>
    <vn name="Glasknochen" nachteil="1" id="glasknochen"/>
    <vn name="Goldgier" nachteil="1"/>
    <vn name="Größenwahn" nachteil="1"/>
    <vn name="Halbzauberer" magisch="1"/>
    <vn name="Heimwehkrank" nachteil="1"/>
    <vn name="Hitzeempfindlichkeit" nachteil="1"/>
    <vn name="Höhenangst" nachteil="1"/>
    <vn name="Impulsiv" nachteil="1"/>
    <vn name="Jähzorn" nachteil="1"/>
    <vn name="Kälteempfindlichkeit" nachteil="1"/>
    <vn name="Kältestarre" nachteil="1"/>
    <vn name="Kein Vertrauter" nachteil="1" magisch="1"/>
    <vn name="Kleinwüchsig" nachteil="1" id="kleinwuechsig"/>
    <vn name="Körpergebundene Kraft" nachteil="1" magisch="1"/>
    <vn name="Krankhafte Reinlichkeit" nachteil="1"/>
    <vn name="Krankheitsanfällig" nachteil="1"/>
    <vn name="Kristallgebunden" nachteil="1" magisch="1"/>
    <vn name="Kurzatmig" nachteil="1"/>
    <vn name="Lahm" nachteil="1"/>
    <vn name="Lästige Mindergeister" nachteil="1" magisch="1"/>
    <vn name="Lichtempfindlich" nachteil="1"/>
    <vn name="Lichtscheu" nachteil="1"/>
    <vn name="Machtvoller Vertrauter" magisch="1"/>
    <vn name="Madas Fluch" nachteil="1" magisch="1"/>
    <vn name="Medium" nachteil="1"/>
    <vn name="Meeresangst" nachteil="1"/>
    <vn name="Meisterhandwerk" magisch="1"/>
    <vn name="Miserable Eigenschaft" nachteil="1"/>
    <vn name="Mondsüchtig" nachteil="1"/>
    <vn name="Moralkodex" nachteil="1"/>
    <vn name="Nachtblind" nachteil="1"/>
    <vn name="Nahrungsrestriktion" nachteil="1"/>
    <vn name="Neid" nachteil="1"/>
    <vn name="Neugier" nachteil="1"/>
    <vn name="Niedrige Astralkraft" nachteil="1" magisch="1"/>
    <vn name="Niedrige Lebenskraft" nachteil="1"/>
    <vn name="Niedrige Magieresistenz" nachteil="1"/>
    <vn name="Pechmagnet" nachteil="1"/>
    <vn name="Platzangst" nachteil="1"/>
    <vn name="Prinzipientreue" nachteil="1"/>
    <vn name="Rachsucht" nachteil="1"/>
    <vn name="Randgruppe" nachteil="1"/>
    <vn name="Raubtiergeruch" nachteil="1"/>
    <vn name="Raumangst" nachteil="1"/>
    <vn name="Rückschlag" nachteil="1" magisch="1"/>
    <vn name="Schlafstörungen" nachteil="1"/>
    <vn name="Schlafwandler" nachteil="1"/>
    <vn name="Schlechte Regeneration" nachteil="1"/>
    <vn name="Schlechter Ruf" nachteil="1"/>
    <vn name="Schneller Alternd" nachteil="1"/>
    <vn name="Schulden" nachteil="1"/>
    <vn name="Schutzgeist" magisch="1"/>
    <vn name="Schwache Ausstrahlung" nachteil="1" magisch="1"/>
    <vn name="Schwacher Astralkörper" nachteil="1" magisch="1"/>
    <vn name="Schwanzlos" nachteil="1"/>
    <vn name="Seffer Manich" nachteil="1"/>
    <vn name="Selbstgespräche" nachteil="1"/>
    <vn name="Sensibler Geruchssinn" nachteil="1"/>
    <vn name="Sippenlosigkeit" nachteil="1"/>
    <vn name="Sonnensucht" nachteil="1"/>
    <vn name="Speisegebote" nachteil="1"/>
    <vn name="Spielsucht" nachteil="1"/>
    <vn name="Sprachfehler" nachteil="1"/>
    <vn name="Spruchhemmung" nachteil="1"/>
    <vn name="Stigma" nachteil="1"/>
    <vn name="Streitsucht" nachteil="1"/>
    <vn name="Stubenhocker" nachteil="1"/>
    <vn name="Sucht" nachteil="1"/>
    <vn name="Thesisgebunden" nachteil="1" magisch="1"/>
    <vn name="Tollpatsch" nachteil="1"/>
    <vn name="Totenangst" nachteil="1"/>
    <vn name="Übernatürliche Begabung" magisch="1"/>
    <vn name="Übler Geruch" nachteil="1"/>
    <vn name="Unangenehme Stimme" nachteil="1"/>
    <vn name="Unansehnlich" nachteil="1"/>
    <vn name="Unbeschwertes Zaubern" magisch="1"/>
    <vn name="Unfähigkeit für [Merkmal]" nachteil="1" magisch="1"/>
    <vn name="Unfähigkeit für [Talentgruppe]" nachteil="1"/>
    <vn name="Unfähigkeit für [Talent]" nachteil="1"/>
    <vn name="Unfrei" nachteil="1"/>
    <vn name="Ungebildet" nachteil="1"/>
    <vn name="Unstet" nachteil="1"/>
    <vn name="Unverträglichkeit mit verarbeitetem Metall" nachteil="1"/>
    <vn name="Vergesslichkeit" nachteil="1"/>
    <vn name="Verhüllte Aura" magisch="1"/>
    <vn name="Verpflichtungen" nachteil="1"/>
    <vn name="Verschwendungssucht" nachteil="1"/>
    <vn name="Verwöhnt" nachteil="1"/>
    <vn name="Viertelzauberer" magisch="1"/>
    <vn name="Vollzauberer" magisch="1"/>
    <vn name="Vorurteile gegen" nachteil="1"/>
    <vn name="Wahnvorstellungen" nachteil="1"/>
    <vn name="Wahrer Name" nachteil="1"/>
    <vn name="Weltfremd" nachteil="1"/>
    <vn name="Wesen der Nacht" magisch="1"/>
    <vn name="Widerwärtiges Aussehen" nachteil="1"/>
    <vn name="Wilde Magie" nachteil="1" magisch="1"/>
    <vn name="Wolfskind" magisch="1"/>
    <vn name="Zauberhaar" magisch="1"/>
    <vn name="Zielschwierigkeiten" nachteil="1" magisch="1"/>
    <vn name="Zögerlicher Zauberer" nachteil="1" magisch="1"/>
    <vn name="Zweistimmiger Gesang" magisch="1"/>
    <vn name="Zwergenwuchs" nachteil="1" id="zwergenwuchs"/>
  </xsl:variable>

  <xsl:variable name="vorUndNachteile" select="exslt:node-set($vun_raw)"/>

  <xsl:variable name="kampf_raw">
    <t name="Anderthalbhänder" steigern="E" be="BE-2"/>
    <t name="Armbrust" steigern="C" be="BE-5"/>
    <t name="Belagerungswaffen" steigern="D" be="-"/>
    <t name="Blasrohr" steigern="D" be="BE-5"/>
    <t name="Bogen" steigern="E" be="BE-3"/>
    <t name="Diskus" steigern="D" be="BE-2"/>
    <t name="Dolche" steigern="D" be="BE-1"/>
    <t name="Fechtwaffen" steigern="E" be="BE-1"/>
    <t name="Hiebwaffen" steigern="D" be="BE-4"/>
    <t name="Infanteriewaffen" steigern="D" be="BE-3"/>
    <t name="Kettenstäbe" steigern="E" be="BE-1"/>
    <t name="Kettenwaffen" steigern="D" be="BE-3"/>
    <t name="Lanzenreiten" steigern="E" be="-"/>
    <t name="Peitsche" steigern="E" be="BE-1"/>
    <t name="Raufen" steigern="C" be="BE"/>
    <t name="Ringen" steigern="D" be="BE"/>
    <t name="Säbel" steigern="D" be="BE-2"/>
    <t name="Schleuder" steigern="E" be="BE-2"/>
    <t name="Schwerter" steigern="E" be="BE-2"/>
    <t name="Speere" steigern="D" be="BE-3"/>
    <t name="Stäbe" steigern="D" be="BE-3"/>
    <t name="Wurfbeile" steigern="D" be="BE-2"/>
    <t name="Wurfmesser" steigern="C" be="BE-3"/>
    <t name="Wurfspeere" steigern="C" be="BE-2"/>
    <t name="Zweihandflegel" steigern="D" be="BE-3"/>
    <t name="Zweihand-Hiebwaffen" steigern="D" be="BE-3"/>
    <t name="Zweihandschwerter/-säbel" steigern="E" be="BE-2"/>
  </xsl:variable>

  <xsl:variable name="kampfTalente" select="exslt:node-set($kampf_raw)"/>

  <xsl:variable name="natur_raw">
    <t name="Fährtensuchen"/>
    <t name="Fallenstellen"/>
    <t name="Fesseln/Entfesseln"/>
    <t name="Fischen/Angeln"/>
    <t name="Orientierung"/>
    <t name="Wettervorhersage"/>
    <t name="Wildnisleben"/>
  </xsl:variable>

  <xsl:variable name="naturTalente" select="exslt:node-set($natur_raw)"/>

  <xsl:variable name="sf_raw">
    <sf name="Astrale Meditation" art="magisch"/>
    <sf name="Aufmerksamkeit" art="nahkampf"/>
    <sf name="Aura verhüllen" art="magisch"/>
    <sf name="Ausfall" art="nahkampf"/>
    <sf name="Auspendeln" art="waffenlos"/>
    <sf name="Ausweichen" art="nahkampf" id="ausweichen" roman="3"/>
    <sf name="Befreiungsschlag" art="nahkampf"/>
    <sf name="Beidhändiger Kampf" art="nahkampf" roman="2"/>
    <sf name="Beinarbeit" art="waffenlos"/>
    <sf name="Berittener Schütze" art="fernkampf"/>
    <sf name="Betäubungsschlag" art="nahkampf"/>
    <sf name="Binden" art="nahkampf"/>
    <sf name="Biss" art="waffenlos"/>
    <sf name="Blindkampf" art="nahkampf"/>
    <sf name="Blutmagie" art="magisch"/>
    <sf name="Block" art="waffenlos"/>
    <sf name="Defensiver Kampfstil" art="nahkampf"/>
    <sf name="Doppelangriff" art="nahkampf"/>
    <sf name="Doppelschlag" art="waffenlos"/>
    <sf name="Eisenarm" art="waffenlos"/>
    <sf name="Eisenhagel" art="fernkampf"/>
    <sf name="Entwaffnen" art="nahkampf"/>
    <sf name="Festnageln" art="nahkampf"/>
    <sf name="Finte" art="nahkampf"/>
    <sf name="Formation" art="nahkampf"/>
    <sf name="Fußfeger" art="waffenlos"/>
    <sf name="Gefäß der Sterne" art="magisch" id="gefaess_der_sterne"/>
    <sf name="Gegenhalten" art="nahkampf"/>
    <sf name="Gerade" art="waffenlos"/>
    <sf name="Gezielter Stich" art="nahkampf"/>
    <sf name="Griff" art="waffenlos"/>
    <sf name="Große Meditation" art="magisch"/>
    <sf name="Halbschwert" art="nahkampf"/>
    <sf name="Halten" art="waffenlos"/>
    <sf name="Hammerschlag" art="nahkampf"/>
    <sf name="Handkante" art="waffenlos"/>
    <sf name="Hexenfluch" art="ritual" named="1"/>
    <sf name="Hexenritual" art="ritual" named="1"/>
    <sf name="Hoher Tritt" art="waffenlos"/>
    <sf name="Hypervehemenz" art="magisch"/>
    <sf name="Improvisierte Waffen" art="nahkampf"/>
    <sf name="Kampf im Wasser" art="nahkampf"/>
    <sf name="Kampfgespür" art="nahkampf" id="kampfgespuer"/>
    <sf name="Kampfreflexe" art="nahkampf" id="kampfreflexe"/>
    <sf name="Klammer" art="waffenlos"/>
    <sf name="Klingensturm" art="nahkampf"/>
    <sf name="Klingentänzer" art="nahkampf"/>
    <sf name="Klingenwand" art="nahkampf"/>
    <sf name="Knaufschlag" art="waffenlos"/>
    <sf name="Knie" art="waffenlos"/>
    <sf name="Konzentrationsstärke" art="magisch"/>
    <sf name="Kopfstoß" art="waffenlos"/>
    <sf name="Kraftkontrolle" art="magisch"/>
    <sf name="Kraftlinienmagie" art="magisch" roman="2"/>
    <sf name="Kraftspeicher" art="magisch"/>
    <sf name="Kreuzblock" art="waffenlos"/>
    <sf name="Kriegsreiterei" art="nahkampf"/>
    <sf name="Linkhand" art="nahkampf" id="linkhand"/>
    <sf name="Lockeres Zaubern" art="magisch"/>
    <sf name="Matrixgeber" art="magisch"/>
    <sf name="Matrixkontrolle" art="magisch"/>
    <sf name="Matrixregeneration" art="magisch" roman="2"/>
    <sf name="Meisterliche Regeneration" art="magisch"/>
    <sf name="Meisterliche Zauberkontrolle" art="magisch" roman="2"/>
    <sf name="Meisterliches Entwaffnen" art="nahkampf"/>
    <sf name="Meisterparade" art="nahkampf"/>
    <sf name="Meisterschütze" art="fernkampf"/>
    <sf name="Merkmalskenntnis" art="ignore" named="1"/>
    <sf name="Niederringen" art="waffenlos"/>
    <sf name="Niederwerfen" art="nahkampf"/>
    <sf name="Ottagaldr" art="magisch"/>
    <sf name="Parierwaffen" art="nahkampf" id="parierwaffen" roman="2"/>
    <sf name="Regeneration" art="magisch" roman="2"/>
    <sf name="Reiterkampf" art="nahkampf"/>
    <sf name="Repräsentation" art="ignore" named="1"/>
    <sf name="Ritualkenntnis" art="ignore" named="1"/>
    <sf name="Runenkunde" art="magisch"/>
    <sf name="Rüstungsgewöhnung" art="nahkampf" id="ruestungsgewoehnung" roman="3"/>
    <sf name="Scharfschütze" art="fernkampf" sub="talent"/>
    <sf name="Schildkampf" art="nahkampf" id="schildkampf" roman="2"/>
    <sf name="Schildspalter" art="nahkampf"/>
    <sf name="Schmetterschlag" art="waffenlos"/>
    <sf name="Schmutzige Tricks" art="waffenlos"/>
    <sf name="Schnellladen" art="fernkampf" sub="talent"/>
    <sf name="Schnellziehen" art="nahkampf"/>
    <sf name="Schwanzfeger" art="waffenlos"/>
    <sf name="Schwanzschlag" art="waffenlos"/>
    <sf name="Schwinger" art="waffenlos"/>
    <sf name="Schwitzkasten" art="waffenlos"/>
    <sf name="Semiperminanz" art="magisch" roman="2"/>
    <sf name="Signaturkenntnis" art="magisch"/>
    <sf name="Simultanzaubern" art="magisch"/>
    <sf name="Spießgespann" art="nahkampf"/>
    <sf name="Sprung" art="waffenlos"/>
    <sf name="Sprungtritt" art="waffenlos"/>
    <sf name="Stapeleffekt" art="magisch"/>
    <sf name="Sturmangriff" art="nahkampf"/>
    <sf name="Tanz der Mada" art="magisch"/>
    <sf name="Tierischer Begleiter" art="magisch"/>
    <sf name="Tod von Links" art="nahkampf"/>
    <sf name="Todesstoß" art="nahkampf"/>
    <sf name="Traumgänger" art="magisch"/>
    <sf name="Tritt" art="waffenlos"/>
    <sf name="Turnierreiterei" art="nahkampf"/>
    <sf name="Umreißen" art="nahkampf"/>
    <sf name="Unterwasserkampf" art="nahkampf"/>
    <sf name="Verbotene Pforten" art="magisch"/>
    <sf name="Versteckte Klinge" art="waffenlos"/>
    <sf name="Vertrautenbindung" art="magisch"/>
    <sf name="Vielfache Ladungen" art="magisch"/>
    <sf name="Würgegriff" art="waffenlos"/>
    <sf name="Waffe zerbrechen" art="nahkampf"/>
    <sf name="Waffenloser Kampfstil" art="waffenlos" named="1" id="kampfstil" boni="1"/>
    <sf name="Waffenmeister" art="nahkampf"/>
    <sf name="Waffenspezialisierung" art="nahkampf" id="waffenspezialisierung" sub="talent" subsub="spezialisierung"/>
    <sf name="Windmühle" art="nahkampf"/>
    <sf name="Wuchtschlag" art="nahkampf"/>
    <sf name="Wurf" art="waffenlos"/>
    <sf name="Zauber bereithalten" art="magisch"/>
    <sf name="Zauber unterbrechen" art="magisch"/>
    <sf name="Zauber vereinigen" art="magisch"/>
    <sf name="Zauberkontrolle" art="magisch"/>
    <sf name="Zauberroutine" art="magisch"/>
    <sf name="Zauberspezialisierung" art="magisch" id="zauberspezialisierung" sub="zauber" subsub="spezialisierung"/>
    <sf name="Zauberzeichen" art="magisch"/>
  </xsl:variable>

  <xsl:variable name="sonderfertigkeiten" select="exslt:node-set($sf_raw)"/>

  <xsl:variable name="kstil_raw">
    <stil name="Bornländisch" talent="Ringen"/>
    <stil name="Gladiatorenstil"/>
    <stil name="Hammerfaust" talent="Raufen"/>
    <stil name="Hruruzat" talent="Raufen"/>
    <stil name="Mercenario" talent="Raufen"/>
    <stil name="Unauer Schule" talent="Ringen"/>
  </xsl:variable>

  <xsl:variable name="kampfstile" select="exslt:node-set($kstil_raw)"/>

  <xsl:template match="/">
    <xsl:apply-templates select="helden/held[1]"/>
  </xsl:template>

  <xsl:template match="held">
    <xsl:text>return {
  dokument = {
    seiten = {"front", "talente", "kampf", "ausruestung"},
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
    <xsl:if test="vt/vorteil[@name = 'Vollzauberer' or @name = 'Halbzauberer']">
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
    <xsl:if test="vt/vorteil[@name = 'Vollzauberer']">
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
    INI = {</xsl:text><xsl:value-of select="eigenschaft[@name='ini']/@value"/><xsl:text>}
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

  <xsl:template match="talentliste">
    <xsl:text>
  talente = {</xsl:text>
    <xsl:variable name="koerper" select="talent[@be]"/>
    <xsl:variable name="kampf" select="$koerper[1]/preceding-sibling::talent"/>
    <xsl:variable name="natur" select="talent[dsa:isNatur(@name)]"/>
    <xsl:variable name="gesellschaft" select="$koerper[last()]/following-sibling::talent[following-sibling::talent[@name=$natur[1]/@name]]"/>
    <xsl:variable name="sprachenSchriften" select="talent[@k]"/>
    <xsl:variable name="wissen" select="$natur[last()]/following-sibling::talent[following-sibling::talent[@name=$sprachenSchriften[1]/@name]]"/>
    <xsl:variable name="handwerk" select="$sprachenSchriften[last()]/following-sibling::talent[not(starts-with(@name, 'Ritualkenntnis') or starts-with(@name, 'Liturgiekenntnis'))]"/>
    <xsl:text>
    kampf = {</xsl:text><xsl:apply-templates select="$kampf" mode="kampf"/><xsl:text>
    },
    koerper = {</xsl:text><xsl:apply-templates select="$koerper" mode="koerper"/><xsl:text>
    },
    gesellschaft = {</xsl:text><xsl:apply-templates select="$gesellschaft"/><xsl:text>
    },
    natur = {</xsl:text><xsl:apply-templates select="$natur"/><xsl:text>
    },
    wissen = {</xsl:text><xsl:apply-templates select="$wissen"/><xsl:text>
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
      <xsl:apply-templates select="$sprachenSchriften[@name != dsa:muttersprache($kultur) and @name != dsa:zweitsprache($kultur)]" mode="sprachen-schriften"/><xsl:text>
    },
    handwerk = {</xsl:text><xsl:apply-templates select="$handwerk"/><xsl:text>
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
        <xsl:value-of select="$kampfwerte/attacke/@value"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$kampfwerte/parade/@value"/>
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

  <xsl:template match="sf">
    <xsl:text>
  sf = {
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
      <xsl:apply-templates select="$sonderfertigkeiten/sf[@art='nahkampf' and @id]" mode="id">
        <xsl:with-param name="items" select="sonderfertigkeit"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    fernkampf = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'fernkampf'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="$sonderfertigkeiten/sf[@art='fernkampf' and @id]" mode="id">
        <xsl:with-param name="items" select="sonderfertigkeit"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    waffenlos = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'waffenlos'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="$sonderfertigkeiten/sf[@art='waffenlos' and @id]" mode="id">
        <xsl:with-param name="items" select="sonderfertigkeit"/>
      </xsl:apply-templates>
      <xsl:text>
    },
    magisch = {
      </xsl:text>
      <xsl:apply-templates select="sonderfertigkeit">
        <xsl:with-param name="art" select="'magisch'"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="$sonderfertigkeiten/sf[@art='magisch' and @id]" mode="id">
        <xsl:with-param name="items" select="sonderfertigkeit"/>
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
    <xsl:if test="$cur &lt; $max">
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
