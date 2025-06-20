<?xml version="1.0"?>
<!-- Processes ArcGIS metadata to remove existing unique identifiers, if present, and add a new unique identifier. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:esri="http://www.esri.com/metadata/">
	<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" omit-xml-declaration="no"/>
	
	<!-- start processing all nodes and attributes in the XML document -->
	<!-- any CDATA blocks in the original XML will be lost because they can't be handled by XSLT -->
	<xsl:template match="/">
		<xsl:apply-templates select="node() | @*" />
	</xsl:template>

	<!-- copy all nodes and attributes in the XML document but re-order by priority -->
  <xsl:variable name="vOrdered" select="'|mdFileID|dataIdInfo|mdContact|distInfo|dqInfo|'"/>
  <xsl:template match="metadata" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="*[(self::mdFileID | self::dataIdInfo | self::mdContact | self::distInfo | self::dqInfo)]">
        <xsl:sort select="substring-before($vOrdered, concat('|',name(),'|'))"/>
      </xsl:apply-templates>
	  <xsl:apply-templates select="*[not(self::mdFileID | self::dataIdInfo | self::mdContact | self::distInfo | self::dqInfo)]"/>
    </xsl:copy>
  </xsl:template>

	<!-- templates below override the default template above that copies all nodes and attributes -->
	
	<!-- Move legacy "Purpose" value to "Supplemental Information" -->
	<xsl:template match="metadata/dataIdInfo/idPurp" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
            <xsl:if test="count (../suppInfo) = 0">
				<suppInfo><xsl:value-of select="."/></suppInfo>
			</xsl:if>
		</xsl:copy>
	</xsl:template> 
	<xsl:template match="metadata/dataIdInfo/suppInfo" priority="1">
		<xsl:copy>
            <xsl:if test="count (../idPurp) > 0">
				<xsl:value-of select="concat(../idPurp, ' ')"/>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>     
    <xsl:template match="metadata/dataIdInfo/idPurp" priority="1"></xsl:template>  
    
    <!-- Convert TimeInstant to TimeExtent -->
    <!-- If we had access to XSLT 2.0, we'd increment tmEnd by 1 day using this expression: xs:date(./TM_Instant/tmPosition) + xs:dayTimeDuration('P1D'), but ArcGIS is stuck at xslt 1.0, so we're setting tmBegin = tmEnd to keep it simple. -->
    <xsl:template match="exTemp" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="count (./TM_Instant) > 0">
				<TM_Period>
                    <tmBegin><xsl:value-of select="./TM_Instant/tmPosition"/></tmBegin>
                    <tmEnd><xsl:value-of select="./TM_Instant/tmPosition"/></tmEnd>
                </TM_Period>
			</xsl:if>
		</xsl:copy>
	</xsl:template>  
    <xsl:template match="TM_Instant" priority="1"></xsl:template>  
    
    <!-- Designate Publisher as Publisher - default is "point of contact" -->
    <xsl:template match="metadata/dataIdInfo/idPoC[1]/role/RoleCd" priority="1">
    	<xsl:copy>
			<!--<xsl:apply-templates select="node() | @*" />-->
    		<xsl:attribute name="value">010</xsl:attribute>
    		<xsl:text>Publisher</xsl:text>
		</xsl:copy>
    </xsl:template> 

    <!-- Assign License code if EPA default license - licenseUnrestricted -->
    <xsl:template match="LegConsts" priority="1">
    	<xsl:copy>
			<xsl:choose>
				<xsl:when test="contains(./useLimit,'edg.epa.gov/EPA_Data_License')">
					<useLimit>EPA Public Domain License</useLimit>
					<xsl:choose>
						<xsl:when test="count (./accessConsts) = 0">
							<accessConsts>
								<RestrictCd value="009">licenceUnrestricted</RestrictCd>
							</accessConsts>
							<othConsts>https://edg.epa.gov/EPA_Data_License.html</othConsts>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="node() | @*" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node() | @*" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
    </xsl:template> 
    
    <!-- Map "No Confidentiality" to "Unclassified" as security constraint -->
    <xsl:template match="/metadata/dataIdInfo/resConst/SecConsts/class" priority="1">
		<xsl:copy>
			<xsl:choose>     
				<xsl:when test="./ClasscationCd/@value = 'no confidentiality'">
					<ClasscationCd value="001">unclassified</ClasscationCd>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node() | @*" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>   

    <!-- exclude Legacy elements from the output -->
	<xsl:template match="Binary | idinfo | dataqual | spdoinfo/indspref | spdoinfo/direct | spdoinfo/ptvctinf/sdtsterm | spdoinfo/ptvctinf/vpfterm | spdoinfo/rastinfo | spref | distinfo | metainfo | Esri/MetaID | Esri/Sync | seqId | MemberName | catFetTyps/*[not(name() = 'genericName')] | scaleDist/uom | dimResol/uom | valUnit/*[not(name() = 'UOM')] | quanValUnit/*[not(name() = 'UOM')] | coordinates | usrDefFreq/*[not(name() = 'duration')] | exTemp/TM_GeometricPrimitive | citId/text() | citIdType | geoBox | geoDesc | MdIdent | RS_Identifier | searchKeys" priority="1" >
	</xsl:template>

  <xsl:template match="node() | @*" priority="0">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>