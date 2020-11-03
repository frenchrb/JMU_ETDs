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
        <xsl:for-each select="dc:creator.name.full">
            <!-- Name variables -->
            <!-- Preferred name in direct order -->
            <xsl:variable name="prefNameDirect">
                <!-- If preferred name contains comma, rearrange for direct order -->
                <xsl:choose>
                    <xsl:when test="contains(../dc:creator.name.preferred, ',')">
                        <xsl:value-of select="replace(../dc:creator.name.preferred, '(.*), (.*)', '$2 $1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="../dc:creator.name.preferred"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        
            <!-- Preferred name in inverted order -->
            <xsl:variable name="prefNameInverted">
                <!-- If preferred name doesn't contain comma, rearrange for inverted order -->
                <xsl:choose>
                    <xsl:when test="not(contains(../dc:creator.name.preferred, ','))">
                        <xsl:value-of select="replace(../dc:creator.name.preferred, '^(.*) ([''A-z-]+)$', '$2, $1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="../dc:creator.name.preferred"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>  
        
            <!-- Full name in direct order -->
            <!-- Rearrange for direct order; add period after initial -->
            <xsl:variable name="fullNameDirect"
                select="replace(replace(., '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')"/>
        
            <!-- Full name in inverted order -->
            <!-- Already in inverted order; add period after initial if missing -->
            <xsl:variable name="fullNameInverted">
                <xsl:choose>
                    <xsl:when test="matches(., ' [A-Z]( |$)')">
                        <xsl:value-of select="concat(., '.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        
            <marc:record>
                <!-- Insert leader and control fields -->
                <marc:leader><xsl:text>     nz  a22     n  4500</xsl:text></marc:leader>
                <marc:controlfield tag="005">
                    <xsl:value-of select="format-dateTime(current-dateTime(),'[Y][M01][D01][H][m][s].[f,1-1]')"/>
                </marc:controlfield>
                <marc:controlfield tag="008">
                    <xsl:value-of select="format-dateTime(current-dateTime(), '[Y01][M01][D01]')"/>
                    <xsl:text>n| azannaabn           a aaa     c</xsl:text>
                </marc:controlfield>
                
                <!-- Insert 024 ORCiD identifier if available -->
                <xsl:if test="../dc:identifier.orcid/text()">
                    <xsl:variable name="orcid">
                        <xsl:analyze-string select="../dc:identifier.orcid" regex="\d{{4}}-\d{{4}}-\d{{4}}-\d{{3}}[\dX]">
                            <xsl:matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>     
                    </xsl:variable>
                    
                    <marc:datafield tag="024" ind1="7" ind2=" ">
                        <marc:subfield code="a">
                                <xsl:value-of select="$orcid"/>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:text>orcid</xsl:text>
                            </marc:subfield>
                        </marc:datafield>
                        <marc:datafield tag="024" ind1="7" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="concat('http://orcid.org/', $orcid)"/>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:text>uri</xsl:text>
                            </marc:subfield>
                        </marc:datafield>
                </xsl:if>
                
                <!-- Insert 040 -->
                <marc:datafield tag="040" ind1=" " ind2=" ">
                    <marc:subfield code="a">ViHarT</marc:subfield>
                    <marc:subfield code="b">eng</marc:subfield>
                    <marc:subfield code="e">rda</marc:subfield>
                    <marc:subfield code="c">ViHarT</marc:subfield>
                </marc:datafield>
                
                <!-- Insert 100 with preferred name if available, otherwise full name -->
                <marc:datafield tag="100" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:choose>
                            <xsl:when test="../dc:creator.name.preferred/text()">
                                <xsl:value-of select="$prefNameInverted"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$fullNameInverted"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </marc:subfield>
                </marc:datafield>
                
                <!-- Insert 370 -->
                <marc:datafield tag="370" ind1=" " ind2=" ">
                    <marc:subfield code="e">
                        <xsl:text>Harrisonburg (Va.)</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="2">
                        <xsl:text>naf</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="v">
                        <xsl:text>JMU ETD online submission form</xsl:text>
                    </marc:subfield>
                </marc:datafield>
                
                <!-- Insert 373 department name -->
                <marc:datafield tag="373" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:text>James Madison University. </xsl:text>
                        <xsl:value-of select="../dc:publisher.department"/>
                    </marc:subfield>
                    <marc:subfield code="2">
                        <xsl:text>naf</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="v">
                        <xsl:text>JMU ETD online submission form</xsl:text>
                    </marc:subfield>
                </marc:datafield>
                
                <!-- Insert 377 with default language English -->
                <marc:datafield tag="377" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:text>eng</xsl:text>
                    </marc:subfield>
                </marc:datafield>
                
                <!-- Insert 400 with other form of name if available -->
                <xsl:if test="(../dc:creator.name.preferred/text()) and (./text())">
                    <marc:datafield tag="400" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="$fullNameInverted"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
                
                <!-- Insert 510 -->
                <marc:datafield tag="510" ind1="2" ind2=" ">
                    <marc:subfield code="i">
                        <xsl:text>Corporate body: </xsl:text>
                    </marc:subfield>
                    <marc:subfield code="a">
                        <xsl:text>James Madison University</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="w">
                        <xsl:text>r</xsl:text>
                    </marc:subfield>
                </marc:datafield>
                
                <!-- Insert 670 -->
                <marc:datafield tag="670" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <!-- Insert title proper -->
                        <xsl:choose>
                            <xsl:when test="contains(../dc:title, ':')">
                                <xsl:value-of select='functx:replace-multi(replace(replace(substring-before(../dc:title, ": "), "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select='functx:replace-multi(replace(replace(../dc:title, "&#8216;", "&apos;"), "&#8217;", "&apos;"),$fr,$to)'/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>, James Madison University </xsl:text>
                        <xsl:choose>
                            <xsl:when test="../dc:publisher.degree.name='Master of Science (MS)'">M.S.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Doctor of Musical Arts (DMA)'">D.M.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Educational Specialist (EdS)'">Ed.S.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Doctor of Philosophy (PhD)'">Ph.D.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Master of Arts (MA)'">M.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Master of Science in Education (MSEd)'">M.S.Ed.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Master of Fine Arts (MFA)'">M.F.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Doctor of Audiology (AuD)'">Au.D.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Doctor of Psychology (PsyD)'">Psy.D.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Science in Nursing (BSN)'">B.S.N.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Science (BS)'">B.S.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Arts (BA)'">B.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Business Administration (BBA)'">B.B.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Fine Arts (BFA)'">B.F.A.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Bachelor of Music (BM)'">B.M.</xsl:when>
                            <xsl:when test="../dc:publisher.degree.name='Doctor of Nursing Practice (DNP)'">D.N.P.</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="../dc:publisher.degree.name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> thesis, </xsl:text>
                        <xsl:value-of select="substring(../dc:date.available, 1, 4)"/>
                        <xsl:text>:</xsl:text>
                    </marc:subfield>
                    
                    <marc:subfield code="b">
                        <xsl:text>JMU ETD online submission form (</xsl:text>
                        <xsl:if test="(../dc:creator.name.preferred/text()) and (./text())">
                            <xsl:value-of select="$prefNameDirect"/>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$fullNameDirect"/>
                        <!-- Insert "co-dissertant" if applicable -->
                        <!--<xsl:if test="../dc:creator.name.full[last()] != ../dc:creator.name.full[1]">
                            <xsl:text>, co-dissertant</xsl:text>
                        </xsl:if>-->
                        <xsl:text>)</xsl:text>
                    </marc:subfield>
                </marc:datafield>

                <!-- Testing names 
                <xsl:if test="../dc:creator.name.preferred/text()">
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
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>