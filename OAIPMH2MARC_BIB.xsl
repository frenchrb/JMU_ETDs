<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:html="http://www.w3.org/TR/REC-html40"
    xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:etdms="http://www.ndltd.org/standards/metadata/etdms/1.0/">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- Script is designed to create RDA bibliographic records from JMU ETD metadata 
    Created by Steven W. Holloway, Head of Metadata Services at James Madison University
    Modified 05/20/2016 by Rebecca B. French and Steven W. Holloway
    This software is distributed under a Creative Commons Attribution Non-Commercial License -->
    <xsl:template match="/">
        <xsl:comment>Transformed by OAIPMH2MARC_BIB.xsl
    Script is designed to create RDA bibliographic records from JMU ETD metadata
    Created by Steven W. Holloway, Head of Metadata Services at James Madison University
    Modified 02/23/2017 by Rebecca B. French and Steven W. Holloway
    This software is distributed under a Creative Commons Attribution Non-Commercial License</xsl:comment>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oai:OAI-PMH">
        <marc:collection
            xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">

            <xsl:apply-templates select="oai:ListRecords/oai:record/oai:metadata/etdms:thesis"/>

        </marc:collection>
    </xsl:template>
    <xsl:template match="oai:ListRecords/oai:record/oai:metadata/etdms:thesis">
        <!-- inserts leader boilerplate -->
        <marc:record>
            <marc:leader><xsl:text>     nam a22     Ii 4500</xsl:text></marc:leader>
            <marc:controlfield tag="005">
                <!-- date/time stamp in MARC format -->
                <xsl:value-of
                    select="format-dateTime(current-dateTime(),'[Y][M01][D01][H][m][s].[f,1-1]')"/>
            </marc:controlfield>
            <!-- 007 boilerplate -->
            <marc:controlfield tag="007">cr</marc:controlfield>
            <!-- creates date stamp in YYMMDD format, with "t" dates derived from date.available (embargo date) and date.created -->
            <marc:controlfield tag="008"><xsl:value-of
                    select="format-date(current-date(),'[Y,2-2][M01][D01]')"/>t<xsl:analyze-string
                        select="etdms:date.copyright" regex="(^\d{{4}})">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <xsl:analyze-string select="etdms:date.created" regex="(^\d{{4}})">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                    <!-- 008 boilerplate with "vau" MARC geographic code and "bm" (bibliography, thesis) posiition 24-25 -->
                </xsl:analyze-string><xsl:text>vau      bm   000 0 eng d</xsl:text></marc:controlfield>
            <xsl:choose>
                <!-- selects and inserts ARK identifier in 024 if available, strips out .pdf extension,otherwise skips this step -->
                <xsl:when test="etdms:identifier.ark/text()">
                    <marc:datafield tag="024" ind1="8" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:analyze-string select="etdms:identifier.ark" regex="\.pdf$"><xsl:non-matching-substring><xsl:value-of select="."></xsl:value-of></xsl:non-matching-substring></xsl:analyze-string> 
                        </marc:subfield>
                    </marc:datafield>
                </xsl:when>
            </xsl:choose>
            <marc:datafield tag="040" ind1=" " ind2=" ">
                <!-- 040 JMU boilerplate -->
                <marc:subfield code="a">VMC</marc:subfield>
                <marc:subfield code="b">eng</marc:subfield>
                <marc:subfield code="e">rda</marc:subfield>
                <marc:subfield code="c">VMC</marc:subfield>
            </marc:datafield>
            <!-- 049 boilerplate -->
            <marc:datafield tag="049" ind1=" " ind2=" ">
                <marc:subfield code="a">VMCI</marc:subfield>
            </marc:datafield>
            <marc:datafield tag="090" ind1=" " ind2=" ">
                <!-- 090 Local Call number must be added manually -->
                <marc:subfield code="a">[TODO]</marc:subfield>
            </marc:datafield>
            <marc:datafield tag="100" ind1="1" ind2=" ">
                <!-- selects preferred name in inverted form if available, otherwise inserts full name, with "dissertant" relator -->
                <marc:subfield code="a">
                    <xsl:choose>
                        <xsl:when test="etdms:creator.name.preferred1/text()">
                            <xsl:value-of select="replace(etdms:creator.name.preferred1, '^(.*) ([''A-z-]+)$', '$2, $1')"/>
                            <!-- if name ends in initial without period, insert period -->
                            <xsl:if test="matches(replace(etdms:creator.name.preferred1, '^(.*) ([''A-z-]+)$', '$2, $1'), ' [A-Z]( |$)')">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                            <xsl:text>,</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="etdms:creator.name.full[1]"/>
                            <!-- if name ends in initial without period, insert period -->
                            <xsl:if test="matches(etdms:creator.name.full[1], ' [A-Z]( |$)')">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                            <xsl:text>,</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
                <marc:subfield code="e">dissertant.</marc:subfield>
            </marc:datafield>
            <!-- generates 245 from "title" with 2nd indicator set by "the" "an" or "a" -->
            <xsl:variable name="indicator2" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="etdms:title[starts-with(.,'The ')]">4</xsl:when>
                    <xsl:when test="etdms:title[starts-with(.,'An ')]">3</xsl:when>
                    <xsl:when test="etdms:title[starts-with(.,'A ')]">2</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <marc:datafield tag="245" ind1="1" ind2="{$indicator2}">
                <!-- creates subfield "b" upon encountering a colon; otherwise generates subfield "a"-->
                <xsl:choose>
                <xsl:when test="etdms:title[contains(.,':')]">
                    <marc:subfield code="a">
                        <xsl:analyze-string select="etdms:title" regex=":.*$">
                            <xsl:non-matching-substring>
                                <!-- change curly single and double quotes to straight quotes -->
                                <xsl:analyze-string select="." regex="&#8216;">
                                    <xsl:matching-substring>
                                        <xsl:value-of select='replace(., "&#8216;", "&apos;")'/>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="&#8217;">
                                            <xsl:matching-substring>
                                                <xsl:value-of select='replace(., "&#8217;", "&apos;")'/>
                                            </xsl:matching-substring>
                                            <xsl:non-matching-substring>
                                                <xsl:analyze-string select="." regex="&#8220;">
                                                    <xsl:matching-substring>
                                                        <xsl:value-of select="replace(., '&#8220;', '&quot;')"/>
                                                    </xsl:matching-substring>
                                                    <xsl:non-matching-substring>
                                                        <xsl:analyze-string select="." regex="&#8221;">
                                                            <xsl:matching-substring>
                                                                <xsl:value-of select="replace(., '&#8221;', '&quot;')"/>
                                                            </xsl:matching-substring>
                                                            <xsl:non-matching-substring>
                                                                <xsl:value-of select="."/>
                                                            </xsl:non-matching-substring>
                                                        </xsl:analyze-string>
                                                    </xsl:non-matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                                <xsl:text> :</xsl:text>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </marc:subfield>
                    <marc:subfield code="b">
                        <xsl:analyze-string select="etdms:title" regex="^.*:\s">
                            <xsl:non-matching-substring>
                                <!-- change curly single and double quotes to straight quotes -->
                                <xsl:analyze-string select="." regex="&#8216;">
                                    <xsl:matching-substring>
                                        <xsl:value-of select='replace(., "&#8216;", "&apos;")'/>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="&#8217;">
                                            <xsl:matching-substring>
                                                <xsl:value-of select='replace(., "&#8217;", "&apos;")'/>
                                            </xsl:matching-substring>
                                            <xsl:non-matching-substring>
                                                <xsl:analyze-string select="." regex="&#8220;">
                                                    <xsl:matching-substring>
                                                        <xsl:value-of select="replace(., '&#8220;', '&quot;')"/>
                                                    </xsl:matching-substring>
                                                    <xsl:non-matching-substring>
                                                        <xsl:analyze-string select="." regex="&#8221;">
                                                            <xsl:matching-substring>
                                                                <xsl:value-of select="replace(., '&#8221;', '&quot;')"/>
                                                            </xsl:matching-substring>
                                                            <xsl:non-matching-substring>
                                                                <xsl:value-of select="."/>
                                                            </xsl:non-matching-substring>
                                                        </xsl:analyze-string>
                                                    </xsl:non-matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                                <xsl:text> /</xsl:text>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </marc:subfield>
                </xsl:when>
                <xsl:otherwise>
                    <marc:subfield code="a">
                        <!-- change curly single and double quotes to straight quotes -->
                        <xsl:analyze-string select="etdms:title" regex="&#8216;">
                            <xsl:matching-substring>
                                <xsl:value-of select='replace(., "&#8216;", "&apos;")'/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="&#8217;">
                                    <xsl:matching-substring>
                                        <xsl:value-of select='replace(., "&#8217;", "&apos;")'/>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="&#8220;">
                                            <xsl:matching-substring>
                                                <xsl:value-of select="replace(., '&#8220;', '&quot;')"/>
                                            </xsl:matching-substring>
                                            <xsl:non-matching-substring>
                                                <xsl:analyze-string select="." regex="&#8221;">
                                                    <xsl:matching-substring>
                                                        <xsl:value-of select="replace(., '&#8221;', '&quot;')"/>
                                                    </xsl:matching-substring>
                                                    <xsl:non-matching-substring>
                                                        <xsl:value-of select="."/>
                                                    </xsl:non-matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                        <xsl:text> /</xsl:text>
                    </marc:subfield>
                </xsl:otherwise>
            </xsl:choose>
                <!-- use preferred name for statement of responsibility or full name in uninverted order -->
                <marc:subfield code="c">
                    <xsl:choose>
                        <xsl:when test="etdms:creator.name.preferred1/text()">
                            <xsl:value-of select="replace(etdms:creator.name.preferred1, '(( |^)[A-Z])( |$)', '$1.$3')"/><xsl:text>.</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- add period after initial and put name in direct order -->
                            <xsl:for-each select="etdms:creator.name.full">
								<xsl:value-of select="replace(replace(., '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')"/>
								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
                            <xsl:text>.</xsl:text>
                        </xsl:otherwise>
                </xsl:choose>
                </marc:subfield>
            </marc:datafield>
            <marc:datafield tag="264" ind1=" " ind2="1">
                <!-- 264 boilerplate, with subfield c date derived from date.created -->
                <marc:subfield code="a"><xsl:text>[Harrisonburg, Virginia] :</xsl:text></marc:subfield>
                <marc:subfield code="b">James Madison University,</marc:subfield>
                <marc:subfield code="c">
                    <xsl:analyze-string select="etdms:date.created" regex="(^\d{{4}})">
                        <xsl:matching-substring><xsl:value-of select="."/>.</xsl:matching-substring>
                    </xsl:analyze-string>
                </marc:subfield>
            </marc:datafield>
            <marc:datafield tag="264" ind1=" " ind2="4">
                <!-- 264 copyright derived from date.copyright (embargo date), with copyright symbol -->
                <marc:subfield code="c">&#xa9;<xsl:analyze-string select="etdms:date.copyright"
                        regex="(^\d{{4}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </marc:subfield>
            </marc:datafield>
            <marc:datafield tag="300" ind1=" " ind2=" ">
                <!-- 300 template; complete when thesis is available -->
                <marc:subfield code="a">1 online resource [TODO]</marc:subfield>
                <marc:subfield code="b"></marc:subfield>
                <marc:subfield code="c"></marc:subfield>
            </marc:datafield>
            <!-- RDA content, media and carrier boilerplate -->
            <marc:datafield tag="336" ind1=" " ind2=" ">
                <marc:subfield code="a">text</marc:subfield>
                <marc:subfield code="b">txt</marc:subfield>
                <marc:subfield code="2">rdacontent</marc:subfield>
            </marc:datafield>
            <marc:datafield tag="337" ind1=" " ind2=" ">
                <marc:subfield code="a">computer</marc:subfield>
                <marc:subfield code="b">c</marc:subfield>
                <marc:subfield code="2">rdamedia</marc:subfield>
            </marc:datafield>
            <marc:datafield tag="338" ind1=" " ind2=" ">
                <marc:subfield code="a">online resource</marc:subfield>
                <marc:subfield code="b">cr</marc:subfield>
                <marc:subfield code="2">rdacarrier</marc:subfield>
            </marc:datafield>
            <!-- RDA digital file boilerplate for PDF -->
            <marc:datafield tag="347" ind1=" " ind2=" ">
                <marc:subfield code="a">text file</marc:subfield>
                <marc:subfield code="b">pdf</marc:subfield>
                <marc:subfield code="2">rda</marc:subfield>
            </marc:datafield>
            <!-- language of expression - default "eng" needs to be changed if thesis is not in English -->
            <marc:datafield tag="377" ind1=" " ind2=" ">
                <marc:subfield code="a">eng</marc:subfield>
            </marc:datafield>
            <!-- genre boilerplate -->
            <marc:datafield tag="380" ind1=" " ind2=" ">
                <marc:subfield code="a">Dissertations, Academic</marc:subfield>
                <marc:subfield code="2">fast</marc:subfield>
            </marc:datafield>
            <!-- insert note for honors projects -->
            <xsl:if test="../../oai:header/oai:setSpec[starts-with(., 'publication:honors')]">
                <marc:datafield tag="500" ind1=" " ind2=" ">
                    <marc:subfield code="a">Senior Honors Project.</marc:subfield>
                </marc:datafield>
            </xsl:if>
            <!-- converts "degree" string into abbreviation for subfield b -->
            <marc:datafield tag="502" ind1=" " ind2=" ">
                <marc:subfield code="b">
                    <xsl:choose>
                        <xsl:when test="etdms:thesis.degree.name='Master of Science (MS)'">M.S.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Doctor of Musical Arts (DMA)'">D.M.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Educational Specialist (EdS)'">Ed.S.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Doctor of Philosophy (PhD)'">Ph.D.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Master of Arts (MA)'">M.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Master of Science in Education (MSEd)'">M.S.Ed.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Master of Fine Arts (MFA)'">M.F.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Doctor of Audiology (AuD)'">Au.D.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Doctor of Psychology (PsyD)'">Psy.D.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Science in Nursing (BSN)'">B.S.N.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Science (BS)'">B.S.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Arts (BA)'">B.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Business Administration (BBA)'">B.B.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Fine Arts (BFA)'">B.F.A.</xsl:when>
                        <xsl:when test="etdms:thesis.degree.name='Bachelor of Music (BM)'">B.M.</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="etdms:thesis.degree.name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
                <marc:subfield code="c">James Madison University</marc:subfield>
                <!-- publication_date -->
                <marc:subfield code="d">
                    <xsl:analyze-string select="etdms:date.created" regex="(^\d{{4}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="."/>.</xsl:matching-substring></xsl:analyze-string></marc:subfield>
            </marc:datafield>
            <!-- bibliographic boilerplate - should be removed if no bibliography present -->
            <marc:datafield tag="504" ind1=" " ind2=" ">
                <marc:subfield code="a">Includes bibliographic references.</marc:subfield>
            </marc:datafield>
            <!-- embargo date inserted in YYYY-MM-DD format -->
            <marc:datafield tag="506" ind1="1" ind2=" ">
                <marc:subfield code="a">Embargo date: <xsl:analyze-string select="etdms:date.copyright"
                        regex="(^\d{{4}}-\d{{2}}-\d{{2}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="."/>.</xsl:matching-substring></xsl:analyze-string></marc:subfield>
            </marc:datafield>
            <marc:datafield tag="516" ind1=" " ind2=" ">
                <marc:subfield code="a">Electronic text.</marc:subfield>
            </marc:datafield>
            <!-- inserts abstract, catches strings of HTML coding -->
            <marc:datafield tag="520" ind1=" " ind2=" ">
                <marc:subfield code="a"><xsl:analyze-string select="etdms:description.abstract" regex="&lt;p&gt;">
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="&lt;/p&gt;">
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="&lt;em&gt;">
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="&lt;/em&gt;">
                                            <xsl:non-matching-substring>
                                                <xsl:analyze-string select="." regex="&lt;strong&gt;">
                                                    <xsl:non-matching-substring>
                                                        <xsl:analyze-string select="." regex="&lt;/strong&gt;">
                                                            <xsl:non-matching-substring>
                                                                <xsl:analyze-string select="." regex="&#xD;">
                                                                    <xsl:non-matching-substring>
                                                                        <xsl:analyze-string select="." regex="&lt;br /&gt;">
                                                                            <xsl:non-matching-substring>
                                                                                <!-- change curly single and double quotes to straight quotes -->
                                                                                <xsl:analyze-string select="." regex="&#8216;">
                                                                                    <xsl:matching-substring>
                                                                                        <xsl:value-of select='replace(., "&#8216;", "&apos;")'/>
                                                                                    </xsl:matching-substring>
                                                                                    <xsl:non-matching-substring>
                                                                                        <xsl:analyze-string select="." regex="&#8217;">
                                                                                            <xsl:matching-substring>
                                                                                                <xsl:value-of select='replace(., "&#8217;", "&apos;")'/>
                                                                                            </xsl:matching-substring>
                                                                                            <xsl:non-matching-substring>
                                                                                                <xsl:analyze-string select="." regex="&#8220;">
                                                                                                    <xsl:matching-substring>
                                                                                                        <xsl:value-of select="replace(., '&#8220;', '&quot;')"/>
                                                                                                    </xsl:matching-substring>
                                                                                                    <xsl:non-matching-substring>
                                                                                                        <xsl:analyze-string select="." regex="&#8221;">
                                                                                                            <xsl:matching-substring>
                                                                                                                <xsl:value-of select="replace(., '&#8221;', '&quot;')"/>
                                                                                                            </xsl:matching-substring>
                                                                                                            <xsl:non-matching-substring>
                                                                                                                <!-- en dash and em dash -->
                                                                                                                <xsl:analyze-string select="." regex="&#x2013;">
                                                                                                                    <xsl:matching-substring>
                                                                                                                        <xsl:value-of select="replace(., '&#x2013;', '-')"/>
                                                                                                                    </xsl:matching-substring>
                                                                                                                    <xsl:non-matching-substring>
                                                                                                                        <xsl:analyze-string select="." regex="&#x2014;">
                                                                                                                            <xsl:matching-substring>
                                                                                                                                <xsl:value-of select="replace(., '&#x2014;', '--')"/>
                                                                                                                            </xsl:matching-substring>
                                                                                                                            <xsl:non-matching-substring>
                                                                                                                                <xsl:value-of select="."/>
                                                                                                                            </xsl:non-matching-substring>
                                                                                                                        </xsl:analyze-string>
                                                                                                                    </xsl:non-matching-substring>
                                                                                                                </xsl:analyze-string>
                                                                                                            </xsl:non-matching-substring>
                                                                                                        </xsl:analyze-string>
                                                                                                    </xsl:non-matching-substring>
                                                                                                </xsl:analyze-string>
                                                                                            </xsl:non-matching-substring>
                                                                                        </xsl:analyze-string>
                                                                                    </xsl:non-matching-substring>
                                                                                </xsl:analyze-string> 
                                                                            </xsl:non-matching-substring>
                                                                        </xsl:analyze-string>
                                                                    </xsl:non-matching-substring>
                                                                </xsl:analyze-string>
                                                            </xsl:non-matching-substring>
                                                        </xsl:analyze-string>
                                                    </xsl:non-matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                </marc:subfield>
            </marc:datafield>
            <marc:datafield tag="538" ind1=" " ind2=" ">
                <marc:subfield code="a">System requirements: PDF reader.</marc:subfield>
            </marc:datafield>
            <!-- inserts dissertant-supplied keywords into 653 uncontrolled subject heading -->
            <xsl:for-each select="etdms:subject.keywords">
                <marc:datafield tag="653" ind1=" " ind2=" ">
                    <marc:subfield code="a"><xsl:value-of select="."/></marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- inserts dissertant-supplied disciplines (required by bepress) into 590 local note -->
            <marc:datafield tag="590" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:text>Dissertant-supplied disciplines: </xsl:text>
                    <xsl:for-each select="etdms:subject.disciplines">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </marc:subfield>
            </marc:datafield>
            <!-- genre boilerplate -->
            <marc:datafield tag="655" ind1=" " ind2="4">
                <marc:subfield code="a">E-theses.</marc:subfield>
            </marc:datafield>
            <!-- format boilerplate -->
            <marc:datafield tag="655" ind1=" " ind2="7">
                <marc:subfield code="a">E-books.</marc:subfield>
                <marc:subfield code="2">aat</marc:subfield>
            </marc:datafield>
            <!-- genre boilerplate -->
            <marc:datafield tag="655" ind1=" " ind2="7">
                <marc:subfield code="a">Dissertations, Academic.</marc:subfield>
                <marc:subfield code="2">fast</marc:subfield>
            </marc:datafield>
			<!-- inserts 700s for each author after the first -->
			<xsl:for-each select="etdms:creator.name.full">
					<xsl:if test="position()!=1">
						<marc:datafield tag="700" ind1="1" ind2=" ">
							<marc:subfield code="a">
								<xsl:value-of select="."/>
								<!-- if name ends in initial without period, insert period -->
                                <xsl:if test="matches(., ' [A-Z]( |$)')">
                                    <xsl:text>.</xsl:text>
								</xsl:if>
								<xsl:text>,</xsl:text>
							</marc:subfield>
							<marc:subfield code="e">dissertant.</marc:subfield>
						</marc:datafield>
					</xsl:if>
			</xsl:for-each>
            <!-- inserts 700 with inverted name of advisors with honorifics stripped out -->
            <xsl:for-each select="etdms:contributor.advisor">
                <marc:datafield tag="700" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:if test="./text()">
                            <xsl:analyze-string select="." regex="((^Dr\.\s)|(^Dr\s)|(^Prof\.\s)|(,\sPhD))">
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="replace(., '^(.*) ([''A-z-]+)$', '$2, $1')"/>
                                    <!-- if name ends in initial without period, insert period -->
                                    <xsl:if test="matches(replace(., '^(.*) ([''A-z-]+)$', '$2, $1'), ' [A-Z]( |$)')">
                                        <xsl:text>.</xsl:text>
                                    </xsl:if>
                                    <xsl:text>,</xsl:text>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:if> 
                    </marc:subfield>
                    <marc:subfield code="e">thesis advisor.</marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- 710 boilerplate with degree-granting institution MARC relator term -->
            <marc:datafield tag="710" ind1="2" ind2=" ">
                <marc:subfield code="a">James Madison University,</marc:subfield>
                <marc:subfield code="e">degree granting institution.</marc:subfield>
            </marc:datafield>
            <marc:datafield tag="710" ind1="2" ind2=" ">
                <marc:subfield code="a">James Madison University.</marc:subfield>
                <!-- department name, which will need to be checked against JMU authority files -->
                <marc:subfield code="b">
                    <xsl:value-of select="etdms:publisher.degree.grantor.department"/>.</marc:subfield>
            </marc:datafield>
            <xsl:choose>
                <xsl:when test="etdms:identifier.url/text()">
            <marc:datafield tag="856" ind1="4" ind2="0">
                <!-- inserts JMU Scholarly Commons URL, with boilerplate message, when identifier.url is present -->
                <marc:subfield code="z">Full-text of dissertation on the Internet (JMU users only)</marc:subfield>
                <marc:subfield code="u">
                    <xsl:value-of select="etdms:identifier.url"/>
                </marc:subfield>
            </marc:datafield>
                </xsl:when>
            </xsl:choose>
        </marc:record>
    </xsl:template>
</xsl:stylesheet>
