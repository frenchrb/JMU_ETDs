<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:html="http://www.w3.org/TR/REC-html40"
    xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:etdms="http://www.ndltd.org/standards/metadata/etdms/1.0/">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- Script designed to create RDA person authority records from JMU ETD submission dissertant metadata 
    Gender is supposed to be determined on the basis of the name and inserted in a 375, but omit the field if unclear or troubling 
    First pass made at Staunton Open Source coding night, 3/3/2015 
    Created by Steven W. Holloway, Head of Metadata Services  at James Madison University
    Modified 05/06/2016 by Rebecca B. French and Steven W. Holloway
    This software is distributed under a Creative Commons Attribution Non-Commercial License -->
    <xsl:template match="/">
        <xsl:comment>Transformed by OAIPMH2MARC_AUTHORITY.xsl
    Script designed to create RDA person authority records from JMU ETD submission metadata
    Created by Steven W. Holloway, Head of Metadata Services  at James Madison University
    Modified 05/06/2016 by Rebecca B. French and Steven W. Holloway
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
		<xsl:for-each select="etdms:creator.name.full">
			<marc:record>
				<!-- leader authority record boilerplate for new records -->
				<marc:leader><xsl:text>     nz  a22     n  4500</xsl:text></marc:leader>
				<marc:controlfield tag="005">
                <!-- date/time stamp in MARC format -->
                <xsl:value-of
                    select="format-dateTime(current-dateTime(),'[Y][M01][D01][H][m][s].[f,1-1]')"/>
            </marc:controlfield>
            <!-- inserts date stamp; the rest of the 008 is static -->
            <marc:controlfield tag="008"><xsl:value-of
                    select="format-date(current-date(),'[Y,2-2][M01][D01]')"/><xsl:text>n| azannaabn           a aaa     c</xsl:text></marc:controlfield>
			
			<xsl:choose>
                <!-- selects and inserts orcid in 024 if available, otherwise skips this step -->
                <xsl:when test="../etdms:identifier.orcid/text()">
                    <marc:datafield tag="024" ind1="7" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="../etdms:identifier.orcid"/>
                        </marc:subfield>
                        <marc:subfield code="2">orcid</marc:subfield>
                    </marc:datafield>
                </xsl:when>
            </xsl:choose>
			
			<marc:datafield tag="040" ind1=" " ind2=" ">
                <!-- inserts 040 JMU boilerplate -->
                <marc:subfield code="a">ViHarT</marc:subfield>
                <marc:subfield code="b">eng</marc:subfield>
                <marc:subfield code="e">rda</marc:subfield>
                <marc:subfield code="c">ViHarT</marc:subfield>
            </marc:datafield>	
				
			<marc:datafield tag="100" ind1="1" ind2=" ">
                <!-- Main entry: chooses preferred name if available, otherwise, selects full name -->
                <marc:subfield code="a">
                    <xsl:choose>
                        <xsl:when test="../etdms:creator.name.preferred1/text()">
                            <xsl:value-of select="replace(../etdms:creator.name.preferred1, '^(.*) ([''A-z-]+)$', '$2, $1')"/>
                            <!-- if name ends in initial without period, insert period -->
                            <xsl:if test="matches(replace(../etdms:creator.name.preferred1, '^(.*) ([''A-z-]+)$', '$2, $1'), ' [A-Z]( |$)')">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="replace(., '( [A-Z])( |$)', '$1.$2')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
            </marc:datafield>
			
			<marc:datafield tag="370" ind1=" " ind2=" ">
                <!-- inserts associated place boilerplate -->
                <marc:subfield code="e">Harrisonburg (Va.)</marc:subfield>
                <marc:subfield code="2">naf</marc:subfield>
            </marc:datafield>
			
            <marc:datafield tag="373" ind1=" " ind2=" ">
                <!-- inserts associated group (James Madison University), with value of "department" -->
                <!-- Until ETD submission form supports a dropdown menu for the names, the value will need to be checked against JMU department authority records-->
                <marc:subfield code="a">James Madison University. <xsl:value-of
                        select="../etdms:publisher.degree.grantor.department"
                    /></marc:subfield>
                <marc:subfield code="2">naf</marc:subfield>
            </marc:datafield>
			
            <!-- commented out 02/03/2016 -->
            <!--            <marc:datafield tag="375" ind1=" " ind2=" ">
                <!-\- inserts empty 375, male or female value, to be guessed at by the cataloger -\->
                <marc:subfield code="a">[DELETE IF UNSURE]</marc:subfield>
            </marc:datafield>-->
			
            <marc:datafield tag="377" ind1=" " ind2=" ">
                <!-- inserts language of expression with set value "eng" -->
                <!-- if thesis in not in English, cataloger should insert another subfield a with appropriate MARC language code -->
                <marc:subfield code="a">eng</marc:subfield>
            </marc:datafield>
			
			<xsl:choose>
                <xsl:when
                    test="(../etdms:creator.name.preferred1/text()) and (./text())">
                    <marc:datafield tag="400" ind1="1" ind2=" ">
                        <!-- creates 400 using fuller form of author name if both preferred name & full name are present -->
                        <marc:subfield code="a">
                            <xsl:value-of select="replace(., '( [A-Z])( |$)', '$1.$2')"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:when>
            </xsl:choose>
			
			<marc:datafield tag="510" ind1="2" ind2=" ">
                <!-- 510 boilerplate establishing student's relationship with JMU -->
                <marc:subfield code="i">Corporate body: </marc:subfield>
                <marc:subfield code="a">James Madison University</marc:subfield>
                <marc:subfield code="w">r</marc:subfield>
            </marc:datafield>
			
			<marc:datafield tag="670" ind1=" " ind2=" ">
                <!-- converts "degree" string into abbreviation for subfield "a" -->
                <marc:subfield code="a">
                    <!-- insert title, changing curly single and double quotes to straight quotes -->
                    <xsl:analyze-string select="../etdms:title" regex="&#8216;">
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
                    <xsl:text>, James Madison University </xsl:text>
                    <!-- inserts degree abbreviation -->
                    <xsl:choose>
                        <xsl:when test="../etdms:thesis.degree.name='Master of Science (MS)'">M.S.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Doctor of Musical Arts (DMA)'">D.M.A.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Educational Specialist (EdS)'">Ed.S.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Doctor of Philosophy (PhD)'">Ph.D.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Master of Arts (MA)'">M.A.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Master of Science in Education (MSEd)'">M.S.Ed.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Master of Fine Arts (MFA)'">M.F.A.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Doctor of Audiology (AuD)'">Au.D.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Doctor of Psychology (PsyD)'">Psy.D.</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Science in Nursing (BSN)'">B.S.N. Honors</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Science (BS)'">B.S. Honors</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Arts (BA)'">B.A. Honors</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Business Administration (BBA)'">B.B.A. Honors</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Fine Arts (BFA)'">B.F.A. Honors</xsl:when>
                        <xsl:when test="../etdms:thesis.degree.name='Bachelor of Music (BM)'">B.M. Honors</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="../etdms:thesis.degree.name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> thesis, </xsl:text>
                    <!-- inserts publication date into subfield "a"-->
                    <xsl:analyze-string select="../etdms:date.created" regex="(^\d{{4}})">
                        <xsl:matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:matching-substring>
                    </xsl:analyze-string><xsl:text>:</xsl:text>
                </marc:subfield>
                <!-- inserts preferred name (if available) and full form of name in direct order into 670 subfield "b" -->
                <marc:subfield code="b"><xsl:text>ETD online submission form (</xsl:text>
                    <xsl:if test="(../etdms:creator.name.preferred1/text()) and (./text())">
                        <xsl:value-of select="replace(../etdms:creator.name.preferred1, '(( |^)[A-Z])( |$)', '$1.$3')"/><xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="replace(replace(., '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')"/>
                    <!-- inserts "co-dissertant" if applicable -->
                    <xsl:if test="../etdms:creator.name.full[last()] != ../etdms:creator.name.full[1]">
                        <xsl:text>, co-dissertant</xsl:text>
                    </xsl:if>               
                    <xsl:text>)</xsl:text>
                </marc:subfield> 
            </marc:datafield>
			</marc:record>
		</xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
