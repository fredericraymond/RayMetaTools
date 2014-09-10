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


<xsl:for-each select="root/geneOntologyTerm">


<xsl:value-of select="identifier"/>
<xsl:text>	"</xsl:text>
     <xsl:value-of select="name"/>
<xsl:text>"	</xsl:text>
     <xsl:value-of select="domain"/>
<xsl:text>	</xsl:text>
     <xsl:value-of select="paths/count"/> 
<xsl:text>	</xsl:text>
     <xsl:value-of select="totalColoredKmerObservations"/> 


<xsl:text>
</xsl:text>

</xsl:for-each>

</xsl:template>

</xsl:stylesheet>

