<?xml version="1.0" encoding="ISO-8859-1"?>

<!---
Use with GeneDB XML files

Extracts coordinates from genes in XML chromosome description from geneDB
Frederic Raymond 2007-12-21

Process your XML file with xsltproc

-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method='text'/>

<xsl:template match="/">


<xsl:for-each select="root/ranks/entry">


<xsl:value-of select="rank"/>
<xsl:text>	</xsl:text>
     <xsl:value-of select="recursive/kmerObservations"/>
<xsl:text>	</xsl:text>
     <xsl:value-of select="self/kmerObservations"/>
<xsl:text>	</xsl:text>


<xsl:text>
</xsl:text>

</xsl:for-each>

</xsl:template>

</xsl:stylesheet>

