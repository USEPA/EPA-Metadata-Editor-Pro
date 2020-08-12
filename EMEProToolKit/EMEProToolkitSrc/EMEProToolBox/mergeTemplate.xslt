<?xml version="1.0" encoding="UTF-8"?>
<!-- Processes ArcGIS metadata to merge document metadata with saved template metadata.
     Template metadata will overwrite document metadata
 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

    <xsl:param name="gpparam" />

   <xsl:template match="/">
      <xsl:apply-templates>
         <xsl:with-param name="defaultsDoc" select="document($gpparam)"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="*">
      <xsl:param name="defaultsDoc"/>
      <xsl:variable name="sourcePosition">
          <xsl:number  />
       </xsl:variable>
      <xsl:variable name="defaultNode" select="$defaultsDoc/*[local-name() = local-name(current())][number($sourcePosition)]"/>
      <xsl:copy>
         <xsl:choose>
            <xsl:when test="$defaultNode and not($defaultNode/*)">
               <xsl:copy-of select="@*|$defaultNode/node()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="@*|node()">
                  <xsl:with-param name="defaultsDoc" select="$defaultNode"/>
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="@*|node()[not(self::*)]">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- copy imported content as the target item's new metadata -->
	<!-- add Esri section with ArcGISFormat if this sections doesn't already exist -->
	<xsl:template match="metadata" priority="1" >
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
            <xsl:if test="count (./mdLang) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdLang"/>
            </xsl:if>
            <xsl:if test="count (./mdChar) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdChar"/>
            </xsl:if>
            <xsl:if test="count (./mdParentID) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdParentID"/>
            </xsl:if>
            <xsl:if test="count (./mdHrLv) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdHrLv"/>
            </xsl:if>
            <xsl:if test="count (./mdHrLvName) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdHrLvName"/>
            </xsl:if>
            <xsl:if test="count (./mdContact) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdContact"/>
            </xsl:if>            
            <xsl:if test="count (./mdStanName) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdStanName"/>
            </xsl:if>
            <xsl:if test="count (./mdStanVer) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdStanVer"/>
            </xsl:if>			
            <xsl:if test="count (./dataIdInfo) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/dataIdInfo"/>
            </xsl:if>
            <xsl:if test="count (./appSchInfo) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/appSchInfo"/>
            </xsl:if>
            <xsl:if test="count (./porCatInfo) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/porCatInfo"/>
            </xsl:if>
            <xsl:if test="count (./mdMaint) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdMaint"/>
            </xsl:if>
            <xsl:if test="count (./mdConst) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdConst"/>
            </xsl:if>
            <xsl:if test="count (./contInfo) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/contInfo"/>
            </xsl:if>            
            <xsl:if test="count (./mdExtInfo) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/mdExtInfo"/>
            </xsl:if>
            <xsl:if test="count (./dataSetFn) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/dataSetFn"/>
            </xsl:if>
            <xsl:if test="count (./loc) = 0">
                <xsl:copy-of select="document($gpparam)/metadata/loc"/>
            </xsl:if>
		</xsl:copy>
	</xsl:template>
   
</xsl:stylesheet>