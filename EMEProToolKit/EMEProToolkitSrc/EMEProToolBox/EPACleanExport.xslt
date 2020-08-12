<?xml version="1.0"?>
<!-- Processes ArcGIS metadata to remove existing unique identifiers, if present, and add a new unique identifier. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:esri="http://www.esri.com/metadata/">
	<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" omit-xml-declaration="no"/>
	
	<!-- start processing all nodes and attributes in the XML document -->
	<!-- any CDATA blocks in the original XML will be lost because they can't be handled by XSLT -->
	<xsl:template match="/">
		<xsl:apply-templates select="node() | @*" />
	</xsl:template>

	<!-- copy all nodes and attributes in the XML document -->
	<xsl:template match="node() | @*" priority="0">    
		<xsl:copy>      
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>