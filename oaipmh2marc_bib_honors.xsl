<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    
    <!-- start functx -->
    <!-- not working because &apos; has to be in double quotes, &quot; has to be in single quotes
    <xsl:variable name="fr" select="('&#8216;', '&#8217;', '&#8220;', '&#8221;', '&lt;p&gt;', '&lt;/p&gt;')"/>
    <xsl:variable name="to" select="('&apos;', '&apos;', '&quot;', '&quot;', '', '')"/>
     -->
    
    <!-- Replacements for curly quotes, html tags, en and em dashes -->
    <xsl:variable name="fr" select="('&#8220;', '&#8221;', '&lt;p&gt;', '&lt;/p&gt;', '&lt;em&gt;', '&lt;/em&gt;', '&lt;strong&gt;', '&lt;/strong&gt;', '&#xD;', '&lt;br /&gt;', '&#x2013;', '&#x2014;')"/>
    <xsl:variable name="to" select="('&quot;', '&quot;', '', '', '', '', '', '', '', '', '-', '--')"/>
    
    <!-- Replacements for degrees, titles, etc. -->
    <xsl:variable name="degFr" select="(', Ph.D.', ', PhD', ', Ph. D.', ', Ph.D', 'Dr. ', ', Associate Professor', ', Assistant Professor', 'RD')"/>
    <xsl:variable name="degTo" select="('', '', '', '', '', '', '', '')"/>
    
    <xsl:function name="functx:replace-multi" as="xs:string?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>
        
        <xsl:sequence select="
            if (count($changeFrom) > 0)
            then functx:replace-multi(
            replace($arg, $changeFrom[1],
            functx:if-absent($changeTo[1],'')),
            $changeFrom[position() > 1],
            $changeTo[position() > 1])
            else $arg
            "/>
    </xsl:function>
    
    <xsl:function name="functx:if-absent" as="item()*"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>
        
        <xsl:sequence select="
            if (exists($arg))
            then $arg
            else $value
            "/>
    </xsl:function>
    <!-- end functx -->
    
    <xsl:template match="/">
        <xsl:comment>comment</xsl:comment>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="oai:OAI-PMH">
        <marc:collection xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
            <xsl:apply-templates select="oai:ListRecords/oai:record/oai:metadata/oai_dc:dc"/>
        </marc:collection>
    </xsl:template>
    
    <xsl:template match="oai:ListRecords/oai:record/oai:metadata/oai_dc:dc">
        <!-- Name order variables -->
        <!-- Full name in direct order -->
        <!-- Rearrange for direct order; add period after initial -->
        <!--<xsl:variable name="fullNameDirect"
            select="replace(replace(dc:creator.name.full, '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')"/>-->
        <xsl:variable name="fullNameDirect" as="node()*">
            <xsl:for-each select="dc:creator.name.full">
                <xsl:value-of select="replace(replace(., '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')"/> <!-- TODO or should there be a . instead of dc:creator.name.full in the replace? -->
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Full name in inverted order; sequence of names if more than one -->
        <!-- In inverted order by default; add period after initial if missing -->
        <xsl:variable name="fullNameInverted" as="node()*">
            <xsl:for-each select="dc:creator.name.full">
                <xsl:choose>
                    <xsl:when test="matches(., ' [A-Z]( |$)')">
                        <xsl:value-of select="concat(., '.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Advisor name(s) in inverted order; sequence of names if more than one -->
        <!-- Rearrange for inverted order if necessary -->
        <xsl:variable name="advisorNameInverted" as="node()*">
            <xsl:for-each select="dc:contributor.advisor">
                <xsl:choose>
                    <xsl:when test="not(contains(functx:replace-multi(., $degFr, $degTo), ','))">
                        <xsl:value-of select="replace(functx:replace-multi(., $degFr, $degTo), '^(.*) ([''A-z-]+)$', '$2, $1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="functx:replace-multi(., $degFr, $degTo)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- End variables -->
        
        
        <marc:record>
            <!-- Insert leader and control fields -->
            <marc:leader><xsl:text>     nam a22     Ii 4500</xsl:text></marc:leader>
            <marc:controlfield tag="005">
                <xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H][m][s].[f01]')"/>
            </marc:controlfield>
            <marc:controlfield tag="007">
                <xsl:text>cr      </xsl:text>
            </marc:controlfield>
            <marc:controlfield tag="008">
                <xsl:value-of select="format-dateTime(current-dateTime(), '[Y01][M01][D01]')"/>
                <xsl:text>t</xsl:text>
                <xsl:value-of select="substring(dc:date.available, 1, 4)"/>
                <xsl:value-of select="substring(dc:date.dateSubmitted, 1, 4)"/>
                <xsl:text>vau     obm   000 0 eng d</xsl:text>
            </marc:controlfield>
            
            <!-- Insert DOI in 024 -->
            <xsl:if test="dc:identifier.doi/text()">
                <marc:datafield tag="024" ind1="7" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="replace(dc:identifier.doi, 'https://doi.org/', '')"/>
                    </marc:subfield>
                    <marc:subfield code="2">
                        <xsl:text>doi</xsl:text>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            
            <!--Insert ARK identifier in 024 if available-->
            <xsl:if test="dc:identifier.ark/text()">
                <marc:datafield tag="024" ind1="8" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="replace(dc:identifier.ark, '\.pdf$', '')"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            
            <!-- Insert 040 -->
            <marc:datafield tag="040" ind1=" " ind2=" ">
                <marc:subfield code="a">VMC</marc:subfield>
                <marc:subfield code="b">eng</marc:subfield>
                <marc:subfield code="e">rda</marc:subfield>
                <marc:subfield code="c">VMC</marc:subfield>
            </marc:datafield>
            
            <!-- Insert 049 -->
            <marc:datafield tag="049" ind1=" " ind2=" ">
                <marc:subfield code="a">VMCI</marc:subfield>
            </marc:datafield>
            
            <!-- Insert local call number in 090 -->
            <marc:datafield tag="090" ind1=" " ind2=" ">
                <marc:subfield code="a">[TODO]</marc:subfield>
            </marc:datafield>
            
            <!-- Insert 100 with full name of first author, followed by "dissertant" relator -->
            <marc:datafield tag="100" ind1="1" ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of select="$fullNameInverted[position()=1]"/>
                    <xsl:text>,</xsl:text>
                </marc:subfield>
                <marc:subfield code="e">
                    <xsl:text>dissertant.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 245 -->
            <xsl:variable name="ind2">
                <xsl:choose>
                    <xsl:when test="starts-with(dc:title, 'A ')">2</xsl:when>
                    <xsl:when test="starts-with(dc:title, 'An ')">3</xsl:when>
                    <xsl:when test="starts-with(dc:title, 'The ')">4</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <marc:datafield tag="245" ind1="1" ind2="{$ind2}">
                <!-- If title contains a colon, split into subfield a and b -->
                <xsl:choose>
                    <xsl:when test="contains(dc:title, ':')">
                        <marc:subfield code="a">
                            <xsl:value-of select='functx:replace-multi(replace(replace(substring-before(dc:title, ": "), "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                            <xsl:text> :</xsl:text>
                        </marc:subfield>
                        <marc:subfield code="b">
                            <xsl:value-of select='functx:replace-multi(replace(replace(substring-after(dc:title, ": "), "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                            <xsl:text> /</xsl:text>
                        </marc:subfield>
                    </xsl:when>
                    <xsl:otherwise>
                        <marc:subfield code="a">
                            <xsl:value-of select='functx:replace-multi(replace(replace(dc:title, "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                            <xsl:text> /</xsl:text>
                        </marc:subfield>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Insert name(s) in direct order -->
                <!-- TODO this must be as it appears on document -->
                <marc:subfield code="c">
                    <xsl:text>[TODO].</xsl:text>

                    <!--<xsl:choose>
                        <xsl:when test="dc:creator.name.preferred/text()">
                            <xsl:value-of select="$prefNameDirect"/>
                            <xsl:if test="not(ends-with($prefNameDirect, '.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-<xsl:value-of select="$fullNameDirect"/>
                            <xsl:if test="not(ends-with($fullNameDirect, '.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>->
                            
                            <!- TODO stuff below not tested; need to revise prefName above too ->
                            <xsl:for-each select="$fullNameDirect">
                                <xsl:value-of select="."/>
                                <xsl:if test="$fullNameDirect[position()!=last()]"> <!- TODO use not() instead of != ->
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:if test="not(ends-with($fullNameDirect[position()=last()], '.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                            <!- TODO rewrite and test for multiple full names ->
                        </xsl:otherwise>
                    </xsl:choose>-->
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 264 with publication (embargo) date -->
            <marc:datafield tag="264" ind1=" " ind2="1">
                <marc:subfield code="a">
                    <xsl:text>[Harrisonburg, Virginia] :</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:text>James Madison University,</xsl:text>
                </marc:subfield>
                <marc:subfield code="c">
                    <xsl:value-of select="substring(dc:date.available, 1, 4)"/>
                    <xsl:text>.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 264 with copyright (submission) date -->
            <marc:datafield tag="264" ind1=" " ind2="4">
                <marc:subfield code="c">
                    <xsl:text>&#xa9;</xsl:text>
                    <xsl:value-of select="substring(dc:date.dateSubmitted, 1, 4)"/>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 300 -->
            <marc:datafield tag="300" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>1 online resource [TODO]</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 336, 337, 338, 347 -->
            <marc:datafield tag="336" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>text</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:text>txt</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>rdacontent</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <marc:datafield tag="337" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>computer</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:text>c</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>rdamedia</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <marc:datafield tag="338" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>online resource</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:text>cr</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>rdacarrier</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <marc:datafield tag="347" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>text file</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:text>pdf</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>rdaft</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 377 with default language English -->
            <marc:datafield tag="377" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>eng</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 380 -->
            <marc:datafield tag="380" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Academic theses.</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>fast</xsl:text>
                </marc:subfield>
                <marc:subfield code="0">
                    <xsl:text>http://id.worldcat.org/fast/1726453</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 500 note for honors projects -->
            <xsl:if test="starts-with('../../oai:header/oai:setSpec', 'publication:honors')">
                <marc:datafield tag="500" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:text>Senior Honors Project.</xsl:text>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            
            <!-- Insert 502 -->
            <marc:datafield tag="502" ind1=" " ind2=" ">
                <marc:subfield code="b">
                    <xsl:choose>
                        <xsl:when test="dc:publisher.degree.name='Master of Science (MS)'">M.S.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Doctor of Musical Arts (DMA)'">D.M.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Educational Specialist (EdS)'">Ed.S.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Doctor of Philosophy (PhD)'">Ph.D.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Master of Arts (MA)'">M.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Master of Science in Education (MSEd)'">M.S.Ed.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Master of Fine Arts (MFA)'">M.F.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Doctor of Audiology (AuD)'">Au.D.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Doctor of Psychology (PsyD)'">Psy.D.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Science in Nursing (BSN)'">B.S.N.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Science (BS)'">B.S.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Arts (BA)'">B.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Business Administration (BBA)'">B.B.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Fine Arts (BFA)'">B.F.A.</xsl:when>
                        <xsl:when test="dc:publisher.degree.name='Bachelor of Music (BM)'">B.M.</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="dc:publisher.degree.name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
                <marc:subfield code="c">
                    <xsl:text>James Madison University</xsl:text>
                </marc:subfield>
                <marc:subfield code="d">
                    <xsl:value-of select="substring(dc:date.dateSubmitted, 1, 4)"/>
                    <xsl:text>.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 504 bibliographic references -->
            <marc:datafield tag="504" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Includes bibliographic references.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 506 embargo date -->
            <marc:datafield tag="506" ind1="1" ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Embargo date: </xsl:text>
                    <xsl:value-of select="substring(dc:date.available, 1, 10)"/>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 506s with use restrictions -->
            <marc:datafield tag="506" ind1="0" ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>James Madison University Libraries is providing a metadata record and hyperlink to this full-text resource.</xsl:text>
                </marc:subfield>
                <marc:subfield code="f">
                    <xsl:text>Unrestricted online access</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>star</xsl:text>
                </marc:subfield>
            </marc:datafield>
            <marc:datafield tag="506" ind1="0" ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Open access content</xsl:text>
                </marc:subfield>
                <marc:subfield code="f">
                    <xsl:text>Unrestricted online access</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>star</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 516 -->
            <marc:datafield tag="516" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Electronic text.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 520 abstract -->
            <marc:datafield tag="520" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of select='functx:replace-multi(replace(replace(dc:description.abstract, "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 538 -->
            <marc:datafield tag="538" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>System requirements: PDF reader.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 540 -->
            <marc:datafield tag="540" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>This work is licensed under a Creative Commons Attribution-NonCommercial-No Derivative Works 4.0 License.</xsl:text>
                </marc:subfield>
                <marc:subfield code="u">
                    <xsl:text>https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 500 with dissertant-supplied bepress disciplines -->
            <marc:datafield tag="500" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Dissertant-supplied disciplines: </xsl:text>
                    <xsl:for-each select="dc:subject.disciplines">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 653 dissertant-supplied keywords as uncontrolled subject headings -->
            <xsl:for-each select="dc:subject.keywords">
                <marc:datafield tag="653" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <!-- Capitalize first letter -->
                        <xsl:value-of select="concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            
            <!-- Insert 655 -->
            <marc:datafield tag="655" ind1=" " ind2="7">
                <marc:subfield code="a">
                    <xsl:text>Academic theses.</xsl:text>
                </marc:subfield>
                <marc:subfield code="2">
                    <xsl:text>fast</xsl:text>
                </marc:subfield>
                <marc:subfield code="0">
                    <xsl:text>http://id.worldcat.org/fast/1726453</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 700 for each author after the first -->
            <xsl:if test="count($fullNameInverted)>1">
                <xsl:for-each select="$fullNameInverted[not(position()=1)]">
                    <marc:datafield tag="700" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="."/>
                            <xsl:text>,</xsl:text>
                        </marc:subfield>
                        <marc:subfield code="e">
                            <xsl:text>dissertant.</xsl:text>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:for-each>
            </xsl:if>
            
            <!-- Insert 700 for advisor -->
            <!--<xsl:for-each select="dc:contributor.advisor">
                <marc:datafield tag="700" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="functx:replace-multi(., $degFr, $degTo)"/>
                    </marc:subfield>
                    <marc:subfield code="e">
                        <xsl:text>thesis advisor.</xsl:text>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>-->
            <xsl:for-each select="$advisorNameInverted">
                <marc:datafield tag="700" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="."/>
                        <xsl:text>,</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="e">
                        <xsl:text>thesis advisor.</xsl:text>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            
            <!-- Insert 710 degree granting institution -->
            <marc:datafield tag="710" ind1="2" ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>James Madison University,</xsl:text>
                </marc:subfield>
                <marc:subfield code="e">
                    <xsl:text>degree granting institution.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 710 JMU department -->
            <marc:datafield tag="710" ind1="2" ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>James Madison University.</xsl:text>
                </marc:subfield>
                <marc:subfield code="b">
                    <xsl:value-of select="dc:publisher.department"/>
                    <xsl:text>.</xsl:text>
                </marc:subfield>
            </marc:datafield>
            
            <!-- Insert 856 with URL, using DOI if available -->
            <xsl:choose>
                <xsl:when test="dc:identifier.doi/text()">
                    <marc:datafield tag="856" ind1="4" ind2="0">
                        <marc:subfield code="z">
                            <xsl:text>Full-text of dissertation on the Internet</xsl:text>
                        </marc:subfield>
                        <marc:subfield code="u">
                            <xsl:value-of select="dc:identifier.doi"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:when>
                <xsl:when test="dc:identifier.url/text()">
                    <marc:datafield tag="856" ind1="4" ind2="0">
                        <marc:subfield code="z">
                            <xsl:text>Full-text of dissertation on the Internet</xsl:text>
                        </marc:subfield>
                        <marc:subfield code="u">
                            <xsl:value-of select="dc:identifier.url"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:when>
            </xsl:choose>
            
            <!-- Testing names 
            <xsl:if test="dc:creator.name.preferred/text()">
                <marc:datafield tag="500" ind1=" " ind2=" ">
                    <marc:subfield code="a"><xsl:text>prefNameDirect: </xsl:text>
                        <xsl:value-of select="$prefNameDirect"/></marc:subfield>
                </marc:datafield>
                <marc:datafield tag="500" ind1=" " ind2=" ">
                    <marc:subfield code="a"><xsl:text>prefNameInverted: </xsl:text>
                        <xsl:value-of select="$prefNameInverted"/></marc:subfield>
                </marc:datafield>
            </xsl:if>
            
            <marc:datafield tag="500" ind1=" " ind2=" ">
                <marc:subfield code="a"><xsl:text>fullNameDirect: </xsl:text>
                    <xsl:value-of select="$fullNameDirect"/></marc:subfield>
            </marc:datafield>
            
            <marc:datafield tag="500" ind1=" " ind2=" ">
                <marc:subfield code="a"><xsl:text>fullNameInverted: </xsl:text>
                    <xsl:value-of select="$fullNameInverted"/></marc:subfield>
            </marc:datafield>-->
            
        </marc:record>
    </xsl:template>
    
</xsl:stylesheet>