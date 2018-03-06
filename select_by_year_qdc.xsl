<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
    
    <!-- Identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Copy only records with specified year in date.dateSubmitted-->
    <xsl:template match="oai:OAI-PMH/oai:ListRecords/oai:record">
        <xsl:choose>
            <xsl:when test="oai:metadata/oai_dc:dc/dc:date.dateSubmitted[not(starts-with(., '2017'))]"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Copy only records without specified date in date.dateSubmitted-->
    <!--
    <xsl:template match="oai:OAI-PMH/oai:ListRecords/oai:record">
        <xsl:choose>
            <xsl:when test="oai:metadata/oai_dc:dc/dc:date.dateSubmitted[starts-with(.,'2014-01')]"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->
    
    <!-- Remove blank lines created by deleted elements -->   
    <xsl:template match="*/text()[not(normalize-space())]" />
</xsl:stylesheet>