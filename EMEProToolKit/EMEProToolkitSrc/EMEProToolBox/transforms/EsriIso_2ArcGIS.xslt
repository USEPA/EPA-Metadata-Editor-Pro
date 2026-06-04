<?xml version="1.0" encoding="UTF-8"?>
<!-- Processes ArcGIS metadata to upgrade ESRI-ISO metadata created with previous releases to ArcGIS metadata. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:esri="http://www.esri.com/metadata/" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="esri msxsl" >
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />
	
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
	
	<!-- templates below override the default template above that copies all noes and attributes -->
	
	<!-- add Esri section if it doesn't already exist -->
	<xsl:template match="metadata" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="count (./Esri) = 0">
				<Esri>
					<xsl:if test="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')]">
						<DataProperties>
							<itemProps>
								<imsContentType><xsl:value-of select="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')][1]"/></imsContentType>
							</itemProps>
						</DataProperties>
					</xsl:if>
					<xsl:call-template name="scaleRange" />
				</Esri>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<!-- copy existing Esri section, add contentType if one doesn't exist, add scale range if one doesn't exist -->
	<xsl:template match="Esri" priority="1" >
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="(count (DataProperties) = 0) and /metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')]">
				<DataProperties>
					<itemProps>
						<imsContentType><xsl:value-of select="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')][1]"/></imsContentType>
					</itemProps>
				</DataProperties>
			</xsl:if>
			<xsl:if test="not(scaleRange) and (../dataIdInfo/dataScale/equScale/rfDenom != '')">
				<xsl:call-template name="scaleRange" />
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<!-- copy existing DataProperties section, add itemProps section if one doesn't exist -->
	<xsl:template match="DataProperties" priority="1" >
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="(count (itemProps) = 0) and /metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')]">
				<itemProps>
					<imsContentType><xsl:value-of select="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')][1]"/></imsContentType>
				</itemProps>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- copy existing itemProps section, add imsContentType if one doesn't exist -->
	<xsl:template match="itemProps" priority="1" >
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="(count (imsContentType) = 0) and /metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')]">
				<imsContentType><xsl:value-of select="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')][1]"/></imsContentType>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- remove existing imsContentType -->
	<xsl:template match="imsContentType" priority="1" >
		<xsl:choose>
			<xsl:when test="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')]">
				<imsContentType><xsl:value-of select="/metadata/distInfo/distributor/distorTran/onLineSrc/orDesc[(. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010')][1]"/></imsContentType>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="node() | @*" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- remove mdStanName and mdStanVer to reflect ArcGISFormat -->
	<xsl:template match="mdStanName | mdStanVer" priority="1" >
	</xsl:template>
	
	<!-- seqId template follows this one, which will match both seqID and seqId, because it must have priority -->
	<xsl:template match="*[MemberName]" priority="1">
		<xsl:copy>
			<xsl:if test="(MemberName//text()) and not(aName or attributeType)">
				<xsl:variable name="name" select="MemberName/aName" />
				<xsl:variable name="type" select="MemberName/attributeType/aName" />
				<xsl:variable name="newMemberName">
					<xsl:if test="($name != '')">
						<aName><xsl:value-of select="$name" /></aName>
					</xsl:if>
					<xsl:if test="($type != '')">
						<attributeType>
							<aName><xsl:value-of select="$type" /></aName>
						</attributeType>
					</xsl:if>
				</xsl:variable>
				<xsl:copy-of select="$newMemberName" />
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="seqId" priority="1">
		<xsl:if test="(.//aName != '') and not(../seqID)">
			<xsl:variable name="name" select="aName | MemberName/aName" />
			<xsl:variable name="type" select="attributeType/aName | MemberName/attributeType/aName" />
			<xsl:variable name="newSequenceID">
				<seqID>
					<xsl:if test="($name != '')">
						<aName><xsl:value-of select="$name" /></aName>
					</xsl:if>
					<xsl:if test="($type != '')">
						<attributeType>
							<aName><xsl:value-of select="$type" /></aName>
						</attributeType>
					</xsl:if>
				</seqID>
			</xsl:variable>
			<xsl:copy-of select="$newSequenceID" />
		</xsl:if>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="catFetTyps" priority="1">
		<xsl:copy>
			<xsl:if test="not(genericName) and ((.//aName != '') or (.//scope != ''))">
				<xsl:variable name="value" select=".//aName" />
				<xsl:variable name="type" select=".//scope" />
				<xsl:variable name="newFeatCatType">
					<genericName>
						<xsl:if test="($type != '')">
							<xsl:attribute name="codeSpace"><xsl:value-of select="$type" /></xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$value" />
					</genericName>
				</xsl:variable>
				<xsl:copy-of select="$newFeatCatType" />
				<xsl:apply-templates select="node() | @*" />
			</xsl:if>
			<xsl:if test="not(genericName) and not((.//aName != '') or (.//scope != '')) and ((text() != '') or (@codeSpace != ''))">
				<xsl:variable name="value" select="." />
				<xsl:variable name="type" select="@codeSpace" />
				<xsl:variable name="newFeatCatType">
					<catFetTyps>
						<genericName>
							<xsl:if test="($type != '')">
								<xsl:attribute name="codeSpace"><xsl:value-of select="$type" /></xsl:attribute>
							</xsl:if>
							<xsl:value-of select="$value" />
						</genericName>
					</catFetTyps>
				</xsl:variable>
				<xsl:copy-of select="$newFeatCatType" />
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="scaleDist/value | dimResol/value" priority="1">
		<xsl:copy>
			<xsl:if test="not(@uom) and (../uom/*/uomName != '')">
				<xsl:attribute name="uom"><xsl:value-of select="../uom/*/uomName" /></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dataScale[contains(equScale/rfDenom, '/')]" priority="1">
		<dataScale>
			<equScale>
				<rfDenom><xsl:value-of select="substring-before(., '/')" /></rfDenom>
			</equScale>
		</dataScale>
		<dataScale>
			<equScale>
				<rfDenom><xsl:value-of select="substring-after(., '/')" /></rfDenom>
			</equScale>
		</dataScale>
	</xsl:template>

	<xsl:template match="valUnit | quanValUnit" priority="1">
		<xsl:copy>
			<xsl:if test="not(UOM) and (.//uomName != '')">
				<UOM>
					<unitSymbol><xsl:value-of select=".//uomName" /></unitSymbol>
				</UOM>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="usrDefFreq" priority="1">
		<xsl:copy>
			<xsl:if test="(text() != '') and not(duration)">
				<duration><xsl:value-of select="text()" /></duration>
			</xsl:if>
			<xsl:if test="not(text()) and (./* != '') and not(duration)">
				<xsl:variable name="duration">P<xsl:if test="(years != '')"><xsl:value-of select="years" />Y</xsl:if><xsl:if test="(months != '')"><xsl:value-of select="months" />M</xsl:if><xsl:if test="(days != '')"><xsl:value-of select="days" />D</xsl:if><xsl:if test="(hours != '') or (minutes != '') or (seconds != '')">T</xsl:if><xsl:if test="(hours != '')"><xsl:value-of select="hours" />H</xsl:if><xsl:if test="(minutes != '')"><xsl:value-of select="minutes" />M</xsl:if><xsl:if test="(seconds != '')"><xsl:value-of select="seconds" />S</xsl:if></xsl:variable>
				<duration><xsl:value-of select="$duration" /></duration>
			</xsl:if>
			<xsl:apply-templates select="* | comment() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="exTemp[TM_GeometricPrimitive/TM_Period]" priority="1">
		<xsl:copy>
			<xsl:variable name="oldBegin" select="TM_GeometricPrimitive/TM_Period/begin" />
			<xsl:variable name="oldEnd" select="TM_GeometricPrimitive/TM_Period/end" />
			<xsl:if test="not(TM_Period/tmBegin or TM_Period/tmEnd) and (($oldBegin != '') or ($oldEnd != ''))">
				<xsl:variable name="newTimePeriod">
					<TM_Period>
						<tmBegin><xsl:value-of select="$oldBegin" /></tmBegin>
						<tmEnd><xsl:value-of select="$oldEnd" /></tmEnd>
					</TM_Period>
				</xsl:variable>
				<xsl:copy-of select="$newTimePeriod" />
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="exTemp[TM_GeometricPrimitive/TM_Instant]" priority="1">
		<xsl:copy>
			<xsl:variable name="oldDate" select="TM_GeometricPrimitive/TM_Instant/tmPosition/*/calDate" />
			<xsl:variable name="oldTime" select="TM_GeometricPrimitive/TM_Instant/tmPosition/*/clkTime" />
			<xsl:variable name="oldTimeInstant">
				<xsl:choose>
					<xsl:when test="($oldDate != '') and ($oldTime != '')">
						<xsl:value-of select="$oldDate" />T<xsl:value-of select="$oldTime" />
					</xsl:when>
					<xsl:when test="($oldDate != '') and not($oldTime != '')">
						<xsl:value-of select="$oldDate" />
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not(TM_Instant/tmPosition) and ($oldTimeInstant != '')">
				<xsl:variable name="newTimeInstant">
					<TM_Instant>
						<tmPosition><xsl:value-of select="$oldTimeInstant" /></tmPosition>
					</TM_Instant>
				</xsl:variable>
				<xsl:copy-of select="$newTimeInstant" />
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="geoBox[@esriExtentType = 'decdegrees']" priority="1">
		<xsl:if test="not(../dataExt/geoEle/GeoBndBox/@esriExtentType = 'search')">
			<xsl:variable name="newGeoBox">
				<dataExt>
					<geoEle>
						<GeoBndBox esriExtentType="search">
							<xsl:apply-templates select="node() | @*[not(name() = 'esriExtentType')]" />
						</GeoBndBox>
					</geoEle>
				</dataExt>
			</xsl:variable>
			<xsl:variable name="newGeoBox2">
				<xsl:apply-templates select="msxsl:node-set($newGeoBox)/node() | msxsl:node-set($newGeoBox)/@*" mode="trim" />
			</xsl:variable>
			<xsl:copy-of select="$newGeoBox2" />
		</xsl:if>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="geoBox[@esriExtentType = 'native']" priority="1">
		<xsl:if test="not(../dataExt/geoEle/GeoBndBox/@esriExtentType = 'native')">
			<xsl:variable name="newGeoBox">
				<dataExt>
					<geoEle>
						<GeoBndBox esriExtentType="native">
							<xsl:apply-templates select="node() | @*" />
						</GeoBndBox>
					</geoEle>
				</dataExt>
			</xsl:variable>
			<xsl:variable name="newGeoBox2">
				<xsl:apply-templates select="msxsl:node-set($newGeoBox)/node() | msxsl:node-set($newGeoBox)/@*" mode="trim" />
			</xsl:variable>
			<xsl:copy-of select="$newGeoBox2" />
		</xsl:if>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="geoBox[not(@esriExtentType)]" priority="1">
		<xsl:if test="not((westBL = ../dataExt/geoEle/GeoBndBox/westBL) and (eastBL = ../dataExt/geoEle/GeoBndBox/eastBL) and (northBL = ../dataExt/geoEle/GeoBndBox/northBL) and (southBL = ../dataExt/geoEle/GeoBndBox/southBL))">
			<xsl:variable name="newGeoBox">
				<dataExt>
					<geoEle>
						<GeoBndBox>
							<xsl:apply-templates select="node() | @*" />
						</GeoBndBox>
					</geoEle>
				</dataExt>
			</xsl:variable>
			<xsl:variable name="newGeoBox2">
				<xsl:apply-templates select="msxsl:node-set($newGeoBox)/node() | msxsl:node-set($newGeoBox)/@*" mode="trim" />
			</xsl:variable>
			<xsl:copy-of select="$newGeoBox2" />
		</xsl:if>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="geoDesc" priority="1">
		<xsl:if test="not(.//identCode = ../dataExt/geoEle/GeoDesc/geoId/identCode)">
			<xsl:variable name="newGeoID">
				<dataExt>
					<geoEle>
						<GeoDesc>
							<xsl:apply-templates select="node() | @*" />
						</GeoDesc>
					</geoEle>
				</dataExt>
			</xsl:variable>
			<xsl:variable name="newGeoID2">
				<xsl:apply-templates select="msxsl:node-set($newGeoID)/node() | msxsl:node-set($newGeoID)/@*" mode="trim" />
			</xsl:variable>
			<xsl:copy-of select="$newGeoID2" />
		</xsl:if>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="geoId | measId | imagQuCode | prcTypCde | refSysInfo/RefSystem/refSysID" priority="1">
		<xsl:copy>
			<xsl:if test="(MdIdent or RS_Identifier) and not(identCode or identAuth)">
				<xsl:variable name="newIdentifier">
					<xsl:apply-templates select="MdIdent/node() | MdIdent/@*" />
					<xsl:apply-templates select="RS_Identifier/node() | RS_Identifier/@*" />
				</xsl:variable>
				<xsl:variable name="newIdentifier2">
					<xsl:apply-templates select="msxsl:node-set($newIdentifier)/node() | msxsl:node-set($newIdentifier)/@*" mode="trim" />
				</xsl:variable>
				<xsl:copy-of select="$newIdentifier2" />
			</xsl:if>
			<xsl:apply-templates select="node()[not(name(.) = 'MdIdent') and not(name(.) = 'RS_Identifier')] | @*" />
			<xsl:copy-of select="MdIdent" />
			<xsl:copy-of select="RS_Identifier" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="srcRefSys" priority="1">
		<xsl:copy>
			<xsl:if test="(RefSystem) and not(identCode or identAuth)">
				<xsl:variable name="newRefSys">
					<xsl:apply-templates select="RefSystem/refSysID/identCode" />
					<xsl:apply-templates select="RefSystem/refSysID/node()[not(name() = 'identCode')] | RefSystem/refSysID/@*" />
				</xsl:variable>
				<xsl:variable name="newRefSys2">
					<xsl:apply-templates select="msxsl:node-set($newRefSys)/node() | msxsl:node-set($newRefSys)/@*" mode="trim" />
				</xsl:variable>
				<xsl:variable name="newRefSys3">
					<xsl:for-each select="msxsl:node-set($newRefSys)/identCode">
						<xsl:copy>
							<xsl:if test="(. != '') and not(@code)">
								<xsl:attribute name="code"><xsl:value-of select="." /></xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="node() | @*" />
						</xsl:copy>
					</xsl:for-each>
					<xsl:apply-templates select="msxsl:node-set($newRefSys)/node()[not(name() = 'identCode')] | msxsl:node-set($newRefSys)/@*" />
				</xsl:variable>
				<xsl:copy-of select="$newRefSys3" />
			</xsl:if>
			<xsl:apply-templates select="node()[not(name(.) = 'RefSystem')] | @*" />
			<xsl:copy-of select="RefSystem" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="citId[not(name(../../..) = 'vertDatum') and not(name(../../..) = 'MdCoRefSys')]"  priority="1">
		<xsl:copy>
			<xsl:if test="not(./*)">
				<identCode><xsl:value-of select="." /></identCode>
			</xsl:if>
			<xsl:if test="../citIdType and not(identAuth)">
				<identAuth>
					<resTitle><xsl:value-of select="../citIdType" /></resTitle>
				</identAuth>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[(resRefDate/refDateType/DateTypCd/@value != '') and not(name(../..) = 'vertDatum') and not(name(../..) = 'MdCoRefSys')]" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="not(date)">
				<date>
					<xsl:for-each select="resRefDate[refDateType/DateTypCd/@value != '']">
						<xsl:variable name="dateType" select="refDateType/DateTypCd/@value" />
						<xsl:variable name="date" select="refDate" />
						<xsl:choose>
							<xsl:when test="($dateType = '001')">
								<createDate><xsl:value-of select="$date" /></createDate>
							</xsl:when>
							<xsl:when test="($dateType = '002')">
								<pubDate><xsl:value-of select="$date" /></pubDate>
							</xsl:when>
							<xsl:when test="($dateType = '003')">
								<reviseDate><xsl:value-of select="$date" /></reviseDate>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</date>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- make sure none of the templates will operate in sequential upgrade operations -->
	<xsl:template match="descKeys[not(thesaName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]" priority="1">
		<xsl:variable name="code">
			<xsl:choose>
				<xsl:when test="(./keyTyp/KeyTypCd/@value != '')"><xsl:value-of select="./keyTyp/KeyTypCd/@value"/></xsl:when>
				<xsl:when test="(./@KeyTypCd != '')"><xsl:value-of select="./@KeyTypCd"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="newCitation">
			<xsl:apply-templates select="node()[not(name() = 'keyTyp')] | @*[not(name() = 'KeyTypCd')]" />
		</xsl:variable>
		<xsl:variable name="newCitation2">
			<xsl:apply-templates select="msxsl:node-set($newCitation)/node() | msxsl:node-set($newCitation)/@*" mode="trim" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="($code = '001')">
				<xsl:if test="(count(../discKeys) != count(../descKeys[(./keyTyp/KeyTypCd/@value = '001') or (./@KeyTypCd = '001')]))">
					<discKeys>
						<xsl:copy-of select="$newCitation2" />
					</discKeys>
				</xsl:if>
			</xsl:when>
			<xsl:when test="($code = '002')">
				<xsl:if test="(count(../placeKeys) != count(../descKeys[(./keyTyp/KeyTypCd/@value = '002') or (./@KeyTypCd = '002')]))">
					<placeKeys>
						<xsl:copy-of select="$newCitation2" />
					</placeKeys>
				</xsl:if>
			</xsl:when>
			<xsl:when test="($code = '003')">
				<xsl:if test="(count(../stratKeys) != count(../descKeys[(./keyTyp/KeyTypCd/@value = '003') or (./@KeyTypCd = '003')]))">
					<stratKeys>
						<xsl:copy-of select="$newCitation2" />
					</stratKeys>
				</xsl:if>
			</xsl:when>
			<xsl:when test="($code = '004')">
				<xsl:if test="(count(../tempKeys) != count(../descKeys[(./keyTyp/KeyTypCd/@value = '004') or (./@KeyTypCd = '004')]))">
					<tempKeys>
						<xsl:copy-of select="$newCitation2" />
					</tempKeys>
				</xsl:if>
			</xsl:when>
			<xsl:when test="($code = '005')">
				<xsl:if test="(count(../themeKeys) != count(../descKeys[(./keyTyp/KeyTypCd/@value = '005') or (./@KeyTypCd = '005')]))">
					<themeKeys>
						<xsl:copy-of select="$newCitation2" />
					</themeKeys>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="(count(../otherKeys) != count(../descKeys[not(./keyTyp) and not(./@KeyTypCd)]))">
					<otherKeys>
						<xsl:copy-of select="$newCitation2" />
					</otherKeys>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="descKeys[(keyword = '001') or (keyword = '002') or (keyword = '003') or (keyword = '004') or (keyword = '005') or (keyword = '006') or (keyword = '007') or (keyword = '008') or (keyword = '009') or (keyword = '010')]" priority="1">
	</xsl:template>

	<xsl:template match="dataIdInfo" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" />
			<xsl:if test="not(searchKeys) and descKeys[not(thesaName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]">
				<searchKeys>
					<xsl:for-each select="descKeys[not(thesaName/@uuidref = '723f6998-058e-11dc-8314-0800200c9a66')]/keyword[text()]">
						<xsl:copy>
							<xsl:apply-templates select="node() | @*" />
						</xsl:copy>
					</xsl:for-each>
				</searchKeys>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dqReport" priority="1">
		<xsl:if test="DQCompComm or DQCompOm or DQConcConsis or DQDomConsis or DQFormConsis or DQTopConsis or DQAbsExtPosAcc or DQGridDataPosAcc or DQRelIntPosAcc or DQThemClassCor or DQNonQuanAttAcc or DQQuanAttAcc or DQAccTimeMeas or DQTempConsis or DQTempValid or QeUsability">
			<xsl:copy>
				<xsl:copy-of select="DQCompComm | DQCompOm | DQConcConsis | DQDomConsis | DQFormConsis | DQTopConsis | DQAbsExtPosAcc | DQGridDataPosAcc | DQRelIntPosAcc | DQThemClassCor | DQNonQuanAttAcc | DQQuanAttAcc | DQAccTimeMeas | DQTempConsis | DQTempValid | QeUsability" />
			</xsl:copy>
		</xsl:if>
		<xsl:if test="@type">
			<report>
				<xsl:attribute name="type"><xsl:value-of select="@type" /></xsl:attribute>
				<xsl:for-each select="*[not(name(.) = 'DQCompComm') and not(name(.) = 'DQCompOm') and not(name(.) = 'DQConcConsis') and not(name(.) = 'DQDomConsis') and not(name(.) = 'DQFormConsis') and not(name(.) = 'DQTopConsis') and not(name(.) = 'DQAbsExtPosAcc') and not(name(.) = 'DQGridDataPosAcc') and not(name(.) = 'DQRelIntPosAcc') and not(name(.) = 'DQThemClassCor') and not(name(.) = 'DQNonQuanAttAcc') and not(name(.) = 'DQQuanAttAcc') and not(name(.) = 'DQAccTimeMeas') and not(name(.) = 'DQTempConsis') and not(name(.) = 'DQTempValid') and not(name(.) = 'QeUsability')]">
					<xsl:copy>
						<xsl:apply-templates select="node() | @*" />
					</xsl:copy>
				</xsl:for-each>
			</report>
		</xsl:if>
		<xsl:if test="not(@type) and (DQCompComm or DQCompOm or DQConcConsis or DQDomConsis or DQFormConsis or DQTopConsis or DQAbsExtPosAcc or DQGridDataPosAcc or DQRelIntPosAcc or DQThemClassCor or DQNonQuanAttAcc or DQQuanAttAcc or DQAccTimeMeas or DQTempConsis or DQTempValid or QeUsability)">
			<xsl:if test="not(/metadata/dqInfo/report/@type = name(*))">
				<xsl:variable name="newReport">
					<report>
						<xsl:attribute name="type"><xsl:value-of select="name(*)" /></xsl:attribute>
						<xsl:apply-templates select="*/node() | */@*" />
					</report>
				</xsl:variable>
				<xsl:variable name="newReport2">
					<xsl:apply-templates select="msxsl:node-set($newReport)/node() | msxsl:node-set($newReport)/@*" mode="trim" />
				</xsl:variable>
				<xsl:copy-of select="$newReport2" />
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="axDimProps" priority="1">
		<xsl:for-each select="Dimen[not(.//@Sync)]">
			<xsl:if test="not(../../axisDimension/@type = dimName/DimNameTypCd/@value)">
				<xsl:variable name="newDimension">
					<axisDimension>
						<xsl:attribute name="type"><xsl:value-of select ="dimName/DimNameTypCd/@value" /></xsl:attribute>
						<xsl:apply-templates select="node()[not(name() = 'dimName')] | @*" />
					</axisDimension>
				</xsl:variable>
				<xsl:variable name="newDimension2">
					<xsl:apply-templates select="msxsl:node-set($newDimension)/node() | msxsl:node-set($newDimension)/@*" mode="trim" />
				</xsl:variable>
				<xsl:copy-of select="$newDimension2" />
			</xsl:if>
		</xsl:for-each>
		<xsl:copy-of select="." />
	</xsl:template>

	<!-- cornerPts, centerPt, and bounding polygon must split series of coordinates into point elements -->
	<xsl:template match="centerPt[(.//coordinates  != '')]" priority="1">
		<xsl:copy>
			<xsl:if test="not(pos)">
				<pos><xsl:value-of select="translate(.//coordinates, ',', ' ')" /></pos>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
	</xsl:template>

  <xsl:template match="cornerPts[(.//coordinates  != '')]" priority="1">
		<xsl:if test="not(../cornerPts/pos)">
			<xsl:for-each select="coordinates">
				<xsl:variable name="newPoints">
					<xsl:call-template name="parseString">
						<xsl:with-param name="text" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:for-each select="msxsl:node-set($newPoints)/pos">
					<cornerPts>
						<pos><xsl:copy-of select="normalize-space(.)" /></pos>
					</cornerPts>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if>
		<xsl:copy-of select="." />
  </xsl:template>

    <xsl:template match="polygon[(.//coordinates  != '')]" priority="1">
		<xsl:copy>
			<xsl:if test="not(exterior)">
				<xsl:for-each select="GM_Polygon/coordinates">
					<exterior>
						<xsl:call-template name="parseString">
							<xsl:with-param name="text" select="." />
						</xsl:call-template>
					</exterior>
				</xsl:for-each>
			</xsl:if>
			<xsl:apply-templates select="node() | @*" />
		</xsl:copy>
    </xsl:template>

  <xsl:template name="parseString">
    <xsl:param name="text" />

    <xsl:choose>
      <xsl:when test="contains($text, ' ')">
        <xsl:variable name="before" select="substring-before($text, ' ')" />
        <xsl:variable name="after" select="substring-after($text, ' ')" />

        <xsl:choose>
          <xsl:when test='$after'>
            <xsl:for-each select='esri:splitcoords($before)'>
              <pos>
                <xsl:for-each select='coord'>
                  <xsl:value-of select='.'/>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </pos>
            </xsl:for-each>
            <xsl:call-template name="parseString">
              <xsl:with-param name="text" select="$after" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select='esri:splitcoords($text)'>
              <pos>
                <xsl:for-each select='coord'>
                  <xsl:value-of select='.'/>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </pos>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select='esri:splitcoords($text)'>
          <pos>
            <xsl:for-each select='coord'>
              <xsl:value-of select='.'/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </pos>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose> 
  </xsl:template>

	<!-- copy all nodes and attributes in the XML document -->
	<xsl:template match="node() | @*" priority="2" mode="trim">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="trim" />
		</xsl:copy>
	</xsl:template>
	
	<!-- exclude ESRI-ISO elements from the output from new ArcGIS sections that have been upgraded -->
	<xsl:template match="seqId | MemberName | scope | catFetTyps/*[not(name() = 'genericName')] | uom | valUnit/*[not(name() = 'UOM')] | quanValUnit/*[not(name() = 'UOM')] | coordinates | usrDefFreq/*[not(name() = 'duration')] | TM_GeometricPrimitive | citId/text() | citIdType | geoBox | geoDesc | MdIdent | RS_Identifier | resRefDate | Result" priority="2" mode="trim">
	</xsl:template>

	<!-- create default ArcGIS scale range from ISO scale information, if present; min is biggest denominator and max is smallest denominator -->
	<xsl:template name="scaleRange">
		<xsl:choose>
			<xsl:when test="(count(/metadata/dataIdInfo/dataScale/equScale/rfDenom[contains(., '/')]) &gt; 0)">
				<xsl:variable name="value" select="/metadata/dataIdInfo/dataScale/equScale/rfDenom[contains(., '/')][1]" />
				<xsl:variable name="max" select="substring-before($value, '/')" />
				<xsl:variable name="min" select="substring-after($value, '/')" />
				<scaleRange>
					<minScale><xsl:value-of select="$min" /></minScale>
					<maxScale><xsl:value-of select="$max" /></maxScale>
				</scaleRange>
			</xsl:when>
			<xsl:when test="(count(/metadata/dataIdInfo/dataScale/equScale/rfDenom[. &gt; 0]) &gt; 1)">
				<xsl:variable name="max" select="/metadata/dataIdInfo/dataScale/equScale/rfDenom[not(../../../dataScale/equScale/rfDenom &lt; .)]" />
				<xsl:variable name="min" select="/metadata/dataIdInfo/dataScale/equScale/rfDenom[not(../../../dataScale/equScale/rfDenom &gt; .)]" />
				<scaleRange>
					<minScale><xsl:value-of select="$min" /></minScale>
					<maxScale><xsl:value-of select="$max" /></maxScale>
				</scaleRange>
			</xsl:when>
			<xsl:when test="(count(/metadata/dataIdInfo/dataScale/equScale/rfDenom[. &gt; 0]) = 1)">
				<xsl:variable name="value" select="/metadata/dataIdInfo/dataScale/equScale/rfDenom" />
				<scaleRange>
					<xsl:choose>
						<!-- Buildings 5,000 -->
						<xsl:when test="($value &lt; 38750) or ($value = 38750)">
							<minScale>50000</minScale>
							<maxScale>5000</maxScale>
						</xsl:when>
						<!-- City 50,000 -->
						<xsl:when test="($value &lt; 162500) or ($value = 162500)">
							<minScale>500000</minScale>
							<maxScale>5000</maxScale>
						</xsl:when>
						<xsl:when test="($value &lt; 387500) or ($value = 387500)">
							<minScale>500000</minScale>
							<maxScale>50000</maxScale>
						</xsl:when>
						<!-- County 500,000 -->
						<xsl:when test="($value &lt; 1625000) or ($value = 1625000)">
							<minScale>5000000</minScale>
							<maxScale>50000</maxScale>
						</xsl:when>
						<xsl:when test="($value &lt; 3875000) or ($value = 3875000)">
							<minScale>5000000</minScale>
							<maxScale>500000</maxScale>
						</xsl:when>
						<!-- State 5,000,000 -->
						<xsl:when test="($value &lt; 8750000) and ($value = 8750000)">
							<minScale>20000000</minScale>
							<maxScale>500000</maxScale>
						</xsl:when>
						<xsl:when test="($value &lt; 16250000) and ($value = 16250000)">
							<minScale>20000000</minScale>
							<maxScale>5000000</maxScale>
						</xsl:when>
						<!-- Country 20,000,000 -->
						<xsl:when test="($value &lt; 27500000) and ($value = 27500000)">
							<minScale>50000000</minScale>
							<maxScale>5000000</maxScale>
						</xsl:when>
						<xsl:when test="($value &lt; 42500000) and ($value = 42500000)">
							<minScale>50000000</minScale>
							<maxScale>20000000</maxScale>
						</xsl:when>
						<!-- Continent 50,000,000 -->
						<xsl:when test="($value &lt; 75000000) and ($value = 75000000)">
							<minScale>150000000</minScale>
							<maxScale>20000000</maxScale>
						</xsl:when>
						<!-- Globe 150,000,000 -->
						<xsl:when test="($value &gt; 75000000)">
							<minScale>150000000</minScale>
							<maxScale>50000000</maxScale>
						</xsl:when>
					</xsl:choose>
				</scaleRange>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="svIdInfo" priority="1">
		<dataIdInfo>
			<xsl:apply-templates select="node() | @*" />
		</dataIdInfo>
		<xsl:copy-of select="." />
	</xsl:template>

	<xsl:template match="svExt" priority="1">
		<dataExt>
			<xsl:apply-templates select="node() | @*" />
		</dataExt>
	</xsl:template>
	
</xsl:stylesheet>
