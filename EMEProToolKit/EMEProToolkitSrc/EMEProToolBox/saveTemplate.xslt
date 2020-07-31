<?xml version="1.0" encoding="UTF-8"?>
<!-- Processes ArcGIS metadata to generate a metadata template that contains information common to many items. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" >
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />
	
	<xsl:variable name="docElements">
		<xsl:apply-templates select="node() | @*" />
	</xsl:variable>
	
	<!-- start processing all nodes and attributes in the XML document -->
	<!-- any CDATA blocks in the original XML will be lost because they can't be handled by XSLT -->
	<xsl:template match="/">
		<xsl:apply-templates select="msxsl:node-set($docElements)" mode="removeEmpty" />
  </xsl:template>

	<!-- copy all nodes and attributes in the XML document -->
	<xsl:template match="node() | @*" priority="0">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<!-- templates below override the default template above that copies all nodes and attributes -->
	
	<!-- exclude no-longer-used FGDC elements from the output -->
	<!-- exclude elements containing unique identifiers -->
	<!-- exclude elements containing synchronized content -->
	<xsl:template match="idinfo | dataqual | spdoinfo/indspref | spdoinfo/direct | spdoinfo/ptvctinf/sdtsterm | spdoinfo/ptvctinf/vpfterm | spdoinfo/rastinfo | spref | distinfo | metainfo | MetaID | Sync | PublishedDocID | PublishStatus | Identifier | mdFileID | seqId | MemberName | catFetTyps/*[not(name() = 'genericName')] | scaleDist/uom | dimResol/uom | valUnit/*[not(name() = 'UOM')] | quanValUnit/*[not(name() = 'UOM')] | coordinates | usrDefFreq/*[not(name() = 'duration')] | exTemp/TM_GeometricPrimitive | citId/text() | citIdType | geoBox | geoDesc | MdIdent | RS_Identifier | Esri | *[@Sync = 'TRUE']" priority="1" >
	</xsl:template>
    
    <!-- Extend excluded elements for EPA Template-->
    <xsl:template match="eainfo | mdDateSt | idCitation | idAbs | suppInfo | distInfo | dqInfo | contInfo | spatRepInfo | refSysInfo" priority="1" >
	</xsl:template>
	
	<!-- match elements only; run after above processing has stripped out unwanted elements -->
	<!-- copy all elements that have text; exclude elements with no content from the output -->
	<!-- some ESRI-ISO elements store content in a value attribute; exclude elements with no content in that attribute -->
	<xsl:template match="node() | @*" mode="removeEmpty">
		<xsl:if test="(normalize-space() != '')">
			<xsl:copy>
				<xsl:apply-templates select="node() | @*" mode="removeEmpty" />
			</xsl:copy>
		</xsl:if>
		<xsl:if test="(normalize-space() = '') and (.//@*[not(name() = 'Sync') and not(name() = 'Name') and not(name() = 'esriExtentType')] != '')">
			<xsl:copy>
				<xsl:apply-templates select="node() | @*" mode="removeEmpty" />
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
