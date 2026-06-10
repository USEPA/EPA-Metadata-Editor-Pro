<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="esri res t msxsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.esri.com/xslt/translator" xmlns:esri="http://www.esri.com/metadata/" xmlns:res="http://www.esri.com/metadata/res/" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:template match="/">
		<metadata>
			<xsl:call-template name="idinfo"/>
			<xsl:call-template name="dq"/>
			<xsl:call-template name="spdoinfo"/>
			<xsl:call-template name="spref"/>
			<xsl:call-template name="entity-and-attribute"/>
			<xsl:call-template name="distribution"/>
			<xsl:call-template name="metainfo"/>
			<xsl:call-template name="binary"/>
		</metadata>
	</xsl:template>
	<xsl:template name="spref">
		<xsl:if test="function-available('esri:decodenodeset') and function-available('msxsl:node-set')">
			<xsl:if test="/metadata/Esri/DataProperties/coordRef/peXml">
				<spref>
					<horizsys>
						<xsl:variable name="pestring" select="esri:decodenodeset(/metadata/Esri/DataProperties/coordRef/peXml)"/>
						<xsl:apply-templates select="msxsl:node-set($pestring)" mode="pexml"/>
					</horizsys>
				</spref>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="GeographicCoordinateSystem" mode="pexml">
		<xsl:variable name="wkt" select="WKT"/>
		<xsl:variable name="resolution" select="XYTolerance"/>
		<xsl:variable name="unit" select="translate(substring-before(substring-after($wkt, 'UNIT[&quot;'), '&quot;'), $upper, $lower)"/>
		<xsl:variable name="datum" select="substring-before(substring-after($wkt, 'DATUM[&quot;'), '&quot;')"/>
		<xsl:variable name="spheroid" select="substring-before(substring-after($wkt, 'SPHEROID[&quot;'), '&quot;')"/>
		<xsl:variable name="semimajoraxis" select="substring-before(substring-after(substring-after($wkt, 'SPHEROID[&quot;'), '&quot;,'), ',')"/>
		<xsl:variable name="denflatratio" select="substring-before(substring-after(substring-after(substring-after($wkt, 'SPHEROID[&quot;'), '&quot;,'), ','), ']')"/>
		<geograph>
			<latres>
				<xsl:value-of select="$resolution"/>
			</latres>
			<longres>
				<xsl:value-of select="$resolution"/>
			</longres>
      <geogunit>
        <xsl:choose>
          <xsl:when test="($unit != 'radians') and ($unit != 'grads')">
            <xsl:value-of select="concat('Decimal ', $unit, 's')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$unit"/>
          </xsl:otherwise>
        </xsl:choose>
      </geogunit>
		</geograph>
		<geodetic>
			<horizdn>
				<xsl:value-of select="translate($datum, '_', ' ')"/>
			</horizdn>
			<ellips>
				<xsl:value-of select="translate($spheroid, '_', ' ')"/>
			</ellips>
			<semiaxis>
				<xsl:value-of select="$semimajoraxis"/>
			</semiaxis>
			<denflat>
				<xsl:value-of select="$denflatratio"/>
			</denflat>
		</geodetic>
	</xsl:template>
	<xsl:template match="ProjectedCoordinateSystem" mode="pexml">
		<xsl:variable name="wkt" select="WKT"/>
		<xsl:variable name="name" select="substring-before(substring-after($wkt, '[&quot;'), '&quot;')"/>
		<xsl:variable name="projcs" select="translate(substring-after($wkt, 'PROJECTION'), $upper, $lower)"/>
		<xsl:variable name="projname" select="substring-before(substring-after($projcs, '[&quot;'), '&quot;')"/>
		<xsl:variable name="projnametest" select="translate(translate($projname, '_', ' '), $upper, $lower)"/>
		<xsl:variable name="resolution" select="(1 div number(XYScale))"/>
		<xsl:variable name="geogcs" select="substring-before(substring-after($wkt, 'GEOGCS['), '],PROJECTION')"/>
		<xsl:variable name="datum" select="substring-before(substring-after($geogcs, 'DATUM[&quot;'), '&quot;')"/>
		<xsl:variable name="spheroid" select="substring-before(substring-after($geogcs, 'SPHEROID[&quot;'), '&quot;')"/>
		<xsl:variable name="semimajoraxis" select="substring-before(substring-after(substring-after($geogcs, 'SPHEROID[&quot;'), '&quot;,'), ',')"/>
		<xsl:variable name="denflatratio" select="substring-before(substring-after(substring-after(substring-after($geogcs, 'SPHEROID[&quot;'), '&quot;,'), ','), ']')"/>
		<planar>
			<mapproj>
				<mapprojn>
					<xsl:value-of select="translate($name, '_', ' ')"/>
				</mapprojn>
				<xsl:choose>
					<xsl:when test="($projnametest = 'albers') or ($projnametest = 'albers conical equal area') or ($projnametest = 'albers equal area conic')">
						<albers>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_2&quot;,'), ']')"/>
							</stdparll>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</albers>
					</xsl:when>
					<xsl:when test="($projnametest = 'azimuthal equidistant')">
						<azimequi>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</azimequi>
					</xsl:when>
					<xsl:when test="($projnametest = 'equidistant conic')">
						<equicon>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_2&quot;,'), ']')"/>
							</stdparll>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</equicon>
					</xsl:when>
					<xsl:when test="($projnametest = 'equidistant cylindrical')">
						<equirect>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</equirect>
					</xsl:when>
					<xsl:when test="($projnametest = 'vertical near side perspective')">
						<gvnsp>
							<heightpt>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;height&quot;,'), ']')"/>
							</heightpt>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_center&quot;,'), ']')"/>
							</longpc>
							<latprjc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_center&quot;,'), ']')"/>
							</latprjc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</gvnsp>
					</xsl:when>
					<xsl:when test="($projnametest = 'gnomonic')">
						<gnomonic>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_center&quot;,'), ']')"/>
							</longpc>
							<latprjc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_center&quot;,'), ']')"/>
							</latprjc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</gnomonic>
					</xsl:when>
					<xsl:when test="($projnametest = 'lambert azimuthal equal area')">
						<lamberta>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longpc>
							<latprjc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</lamberta>
					</xsl:when>
					<xsl:when test="($projnametest = 'lambert conformal conic') or ($projnametest = 'lambert conformal conic 1sp') or ($projnametest = 'lambert conformal conic 2sp')">
						<lambertc>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_2&quot;,'), ']')"/>
							</stdparll>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</lambertc>
					</xsl:when>
					<xsl:when test="($projnametest = 'mercator') or ($projnametest = 'mercator 2sp')">
						<mercator>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</mercator>
					</xsl:when>
					<xsl:when test="($projnametest = 'miller cylindrical')">
						<miller>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</miller>
					</xsl:when>
					<xsl:when test="($projnametest = 'hotine oblique mercator azimuth natural origin') or ($projnametest = 'hotine oblique mercator') or ($projnametest = 'hotine oblique mercator two point natural origin')">
						<obqmerc>
							<sfctrlin>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;scale_factor&quot;,'), ']')"/>
							</sfctrlin>
							<xsl:if test="contains($projcs,'azimuth')">
								<obqlazim>
									<azimangl>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;azimuth&quot;,'), ']')"/>
									</azimangl>
									<azimptl>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_center&quot;,'), ']')"/>
									</azimptl>
								</obqlazim>
							</xsl:if>
							<xsl:if test="contains($projcs,'1st_point')">
								<obqlpt>
									<obqllat>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_1st_point&quot;,'), ']')"/>
									</obqllat>
									<obqllong>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_1st_point&quot;,'), ']')"/>
									</obqllong>
								</obqlpt>
							</xsl:if>
							<xsl:if test="contains($projcs,'2nd_point')">
								<obqlpt>
									<obqllat>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_2nd_point&quot;,'), ']')"/>
									</obqllat>
									<obqllong>
										<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_2nd_point&quot;,'), ']')"/>
									</obqllong>
								</obqlpt>
							</xsl:if>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_center&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</obqmerc>
					</xsl:when>
					<xsl:when test="($projnametest = 'orthographic')">
						<orthogr>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;longitude_of_center&quot;,'), ']')"/>
							</longpc>
							<latprjc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_center&quot;,'), ']')"/>
							</latprjc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</orthogr>
					</xsl:when>
					<xsl:when test="($projnametest = 'stereographic north pole') or ($projnametest = 'stereographic south pole')">
						<polarst>
							<svlong>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</svlong>
							<stdparll>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;standard_parallel_1&quot;,'), ']')"/>
							</stdparll>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</polarst>
					</xsl:when>
					<xsl:when test="($projnametest = 'polyconic')">
						<polycon>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</polycon>
					</xsl:when>
					<xsl:when test="($projnametest = 'robinson') or ($projnametest = 'robinson arc info')">
						<robinson>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longpc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</robinson>
					</xsl:when>
					<xsl:when test="($projnametest = 'sinusoidal')">
						<sinusoid>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</sinusoid>
					</xsl:when>
					<xsl:when test="($projnametest = 'stereographic')">
						<stereo>
							<longpc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longpc>
							<latprjc>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjc>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</stereo>
					</xsl:when>
					<xsl:when test="($projnametest = 'transverse mercator')">
						<transmer>
							<sfctrmer>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;scale_factor&quot;,'), ']')"/>
							</sfctrmer>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<latprjo>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;latitude_of_origin&quot;,'), ']')"/>
							</latprjo>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</transmer>
					</xsl:when>
					<xsl:when test="contains($projnametest, 'van der grinten')">
						<vdgrin>
							<longcm>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;central_meridian&quot;,'), ']')"/>
							</longcm>
							<feast>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_easting&quot;,'), ']')"/>
							</feast>
							<fnorth>
								<xsl:value-of select="substring-before(substring-after($projcs, 'parameter[&quot;false_northing&quot;,'), ']')"/>
							</fnorth>
						</vdgrin>
					</xsl:when>
					<xsl:otherwise>
						<mapprojp>
							<otherprj>
								<xsl:value-of select="$wkt"/>
							</otherprj>
						</mapprojp>
					</xsl:otherwise>
				</xsl:choose>
			</mapproj>
			<planci>
				<plance>coordinate pair</plance>
				<coordrep>
					<absres>
						<xsl:value-of select="$resolution"/>
					</absres>
					<ordres>
						<xsl:value-of select="$resolution"/>
					</ordres>
				</coordrep>
				<plandu>
					<xsl:value-of select="substring-before(substring-after($projcs, 'unit[&quot;'), '&quot;')"/>
				</plandu>
			</planci>
		</planar>
		<geodetic>
			<horizdn>
				<xsl:value-of select="translate($datum, '_', ' ')"/>
			</horizdn>
			<ellips>
				<xsl:value-of select="translate($spheroid, '_', ' ')"/>
			</ellips>
			<semiaxis>
				<xsl:value-of select="$semimajoraxis"/>
			</semiaxis>
			<denflat>
				<xsl:value-of select="$denflatratio"/>
			</denflat>
		</geodetic>
	</xsl:template>
	<xsl:template name="dq">
		<xsl:if test="(count(/metadata/dqInfo/report[(@type='DQQuanAttAcc') or (@type='DQConcConsis') or (@type='DQCompOm') or (@type='DQAbsExtPosAcc')] | /metadata/dqInfo/dataLineage/dataSource | /metadata/dqInfo/dataLineage/prcStep | /metadata/contInfo/ImgDesc/cloudCovPer) &gt; 0)">
      <xsl:for-each select="(/metadata/dqInfo[report[@type='DQConcConsis']/measDesc |&#xA;    report[@type='DQCompOm']/measDesc |&#xA;    report[@type='DQAbsExtPosAcc'] | &#xA;    dataLineage[dataSource or prcStep] |&#xA;    /metadata/contInfo/ImgDesc/cloudCovPer])[1]">
        <dataqual>
          <xsl:for-each select="/metadata/dqInfo[1]/report[(@type='DQQuanAttAcc') and ((measDesc != '') or (evalMethDesc != '') or (measResult/QuanResult/quanVal != ''))]"><!-- account for dqReport[@type='DQQuanAttAcc'] -->
            <attracc>
              <xsl:for-each select="(measDesc[. != ''])">
                <xsl:variable name="attraccr" select="substring-after(starts-with(.,'Attribute Accuracy Report: '),'Attribute Accuracy Report: ')"/>
                <xsl:choose>
                  <xsl:when test="($attraccr != '')">
                    <attraccr>
                      <xsl:value-of select="$attraccr"/>
                    </attraccr>
                  </xsl:when>
                  <xsl:otherwise>
                    <attraccr>
                      <xsl:value-of select="."/>
                    </attraccr>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:if test="(evalMethDesc != '') or (measResult/QuanResult/quanVal != '')">
                <qattracc>
                  <xsl:for-each select="measResult/QuanResult/quanVal[. != ''][1]">
                    <attraccv>
                      <xsl:value-of select="."/>
                    </attraccv>
                  </xsl:for-each>
                  <xsl:for-each select="(evalMethDesc[. != ''])">
                    <xsl:choose>
                      <xsl:when test="(starts-with(.,'Attr: '))">
                        <attracce>
                          <xsl:value-of select="substring-after(.,'Attr: ')"/>
                        </attracce>
                      </xsl:when>
                      <xsl:otherwise>
                        <attracce>
                          <xsl:value-of select="."/>
                        </attracce>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </qattracc>
              </xsl:if>
            </attracc>
          </xsl:for-each>
          <xsl:for-each select="/metadata/dqInfo[1]/report[(@type='DQConcConsis') and (measDesc != '')]">
            <xsl:variable name="logic" select="substring-after(measDesc[starts-with(.,'Logical Consistency Report: ')][1],'Logical Consistency Report: ')"/>
            <xsl:choose>
              <xsl:when test="($logic != '')">
                <logic>
                  <xsl:value-of select="$logic"/>
                </logic>
              </xsl:when>
              <xsl:otherwise>
                <logic>
                  <xsl:value-of select="measDesc"/>
                </logic>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <xsl:for-each select="/metadata/dqInfo[1]/report[(@type='DQCompOm') and (measDesc != '')]">
            <xsl:variable name="complete" select="substring-after(measDesc[starts-with(.,'Completeness Report: ')][1],'Completeness Report: ')"/>
            <xsl:choose>
              <xsl:when test="($complete != '')">
                <complete>
                  <xsl:value-of select="$complete"/>
                </complete>
              </xsl:when>
              <xsl:otherwise>
                <complete>
                  <xsl:value-of select="measDesc"/>
                </complete>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <xsl:for-each select="/metadata/dqInfo[1]/report[(@type='DQAbsExtPosAcc') and ((measDesc != '') or (evalMethDesc != '') or (measResult/QuanResult/quanVal != ''))]">
            <posacc>
              <xsl:choose>
                <xsl:when test="(@dimension = 'vertical')">
                  <vertacc>
                    <xsl:for-each select="(measDesc[. != ''])">
                      <xsl:variable name="vertaccr" select="substring-after(starts-with(.,'Vertical Positional Accuracy Report: '),'Vertical Positional Accuracy Report: ')"/>
                      <xsl:choose>
                        <xsl:when test="($vertaccr != '')">
                          <vertaccr>
                            <xsl:value-of select="$vertaccr"/>
                          </vertaccr>
                        </xsl:when>
                        <xsl:otherwise>
                          <vertaccr>
                            <xsl:value-of select="."/>
                          </vertaccr>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="(evalMethDesc[. != '']) or (measResult/QuanResult/quanVal != '')">
                      <qvertpa>
                        <xsl:for-each select="measResult/QuanResult/quanVal[. != ''][1]">
                          <vertaccv>
                            <xsl:value-of select="."/>
                          </vertaccv>
                        </xsl:for-each>
                        <xsl:for-each select="(evalMethDesc[. != ''])">
                          <xsl:choose>
                            <xsl:when test="(starts-with(.,'Vert: '))">
                              <vertacce>
                                <xsl:value-of select="substring-after(.,'Vert: ')"/>
                              </vertacce>
                            </xsl:when>
                            <xsl:otherwise>
                              <vertacce>
                                <xsl:value-of select="."/>
                              </vertacce>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </qvertpa>
                    </xsl:if>
                  </vertacc>
                </xsl:when>
                <xsl:otherwise>
                  <horizpa>
                    <xsl:for-each select="(measDesc[. != ''])">
                      <xsl:variable name="horizpar" select="substring-after(starts-with(.,'Horizontal Positional Accuracy Report: '),'Horizontal Positional Accuracy Report: ')"/>
                      <xsl:choose>
                        <xsl:when test="($horizpar != '')">
                          <horizpar>
                            <xsl:value-of select="$horizpar"/>
                          </horizpar>
                        </xsl:when>
                        <xsl:otherwise>
                          <horizpar>
                            <xsl:value-of select="."/>
                          </horizpar>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="(evalMethDesc != '') or (measResult/QuanResult/quanVal != '')">
                      <qhorizpa>
                        <xsl:for-each select="measResult/QuanResult/quanVal[. != ''][1]">
                          <horizpav>
                            <xsl:value-of select="."/>
                          </horizpav>
                        </xsl:for-each>
                        <xsl:for-each select="(evalMethDesc[. != ''])">
                          <xsl:choose>
                            <xsl:when test="(starts-with(.,'Horiz: '))">
                              <horizpae>
                                <xsl:value-of select="substring-after(.,'Horiz: ')"/>
                              </horizpae>
                            </xsl:when>
                            <xsl:otherwise>
                              <horizpae>
                                <xsl:value-of select="."/>
                              </horizpae>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </qhorizpa>
                    </xsl:if>
                  </horizpa>
                </xsl:otherwise>
              </xsl:choose>
            </posacc>
          </xsl:for-each>
          <xsl:for-each select="/metadata/dqInfo/dataLineage[(dataSource != '') or (prcStep != '')]">
            <lineage>
              <xsl:for-each select="dataSource">
                <srcinfo>
                  <xsl:for-each select="(srcCitatn)[1]">
                    <srccite>
                      <citeinfo>
                        <xsl:call-template name="citation"/>
                      </citeinfo>
                    </srccite>
                  </xsl:for-each>
                  <xsl:for-each select="(srcScale/rfDenom)[1]">
                    <srcscale>
                      <xsl:value-of select="."/>
                    </srcscale>
                  </xsl:for-each>
                  <xsl:for-each select="(srcMedName/MedNameCd/@value)[1]">
                    <typesrc>
                      <xsl:choose>
                        <xsl:when test=". = '001'">
                          <xsl:text>CD-ROM</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '002'">
                          <xsl:text>dvd</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '003'">
                          <xsl:text>dvdRom</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '004'">
                          <xsl:text>3-1/2 inch floppy disk</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '005'">
                          <xsl:text>5-1/4 inch floppy disk</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '006'">
                          <xsl:text>7trackTape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '007'">
                          <xsl:text>9-track tape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '008'">
                          <xsl:text>3480Cartridge</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '009'">
                          <xsl:text>3490Cartridge</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '010'">
                          <xsl:text>3580Cartridge</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '011'">
                          <xsl:text>4 mm cartridge tape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '012'">
                          <xsl:text>8 mm cartridge tape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '013'">
                          <xsl:text>1/4-inch cartridge tape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '014'">
                          <xsl:text>digitalLinearTape</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '015'">
                          <xsl:text>onLine</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '016'">
                          <xsl:text>satellite</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '017'">
                          <xsl:text>telephoneLink</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '018'">
                          <xsl:text>hardcopy</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '019'">
                          <xsl:text>hardcopyDiazoPolyester08</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '020'">
                          <xsl:text>hardcopyCardMicrofilm</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '021'">
                          <xsl:text>hardcopyMicrofilm240</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '022'">
                          <xsl:text>hardcopyMicrofilm35</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '023'">
                          <xsl:text>hardcopyMicrofilm70</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '024'">
                          <xsl:text>hardcopyMicrofilmGeneral</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '025'">
                          <xsl:text>hardcopyMicrofilmMicrofiche</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '026'">
                          <xsl:text>hardcopyNegativePhoto</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '027'">
                          <xsl:text>hardcopyPaper</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '028'">
                          <xsl:text>hardcopyDiazo</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '029'">
                          <xsl:text>hardcopyPhoto</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '030'">
                          <xsl:text>hardcopyTracedPaper</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '031'">
                          <xsl:text>hardDisk</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = '032'">
                          <xsl:text>USBFlashDrive</xsl:text>
                        </xsl:when>
                      </xsl:choose>
                    </typesrc>
                  </xsl:for-each>
                  <xsl:if test="not(srcMedName/MedNameCd/@value)">
                    <typesrc>None</typesrc>
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="(srcExt/tempEle/TempExtent/exTemp/TM_Period != '')">
                      <xsl:for-each select="(srcExt/tempEle/TempExtent/exTemp/TM_Period)[1]">
                        <srctime>
                          <timeinfo>
                            <rngdates>
                              <xsl:for-each select="(tmBegin)[1]">
                                <xsl:call-template name="dateTimeElements">
                                  <xsl:with-param name="dateEleName">begdate</xsl:with-param>
                                  <xsl:with-param name="timeEleName">begtime</xsl:with-param>
                                </xsl:call-template>
                              </xsl:for-each>
                              <xsl:for-each select="(tmEnd)[1]">
                                <xsl:call-template name="dateTimeElements">
                                  <xsl:with-param name="dateEleName">enddate</xsl:with-param>
                                  <xsl:with-param name="timeEleName">endtime</xsl:with-param>
                                </xsl:call-template>
                              </xsl:for-each>
                            </rngdates>
                          </timeinfo>
                          <xsl:for-each select="(../../../../exDesc)[1]">
                            <srccurr>
                              <xsl:value-of select="."/>
                            </srccurr>
                          </xsl:for-each>
                          <xsl:if test="not(../../../../exDesc)">
                            <srccurr>Unknown</srccurr>
                          </xsl:if>
                        </srctime>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="(srcExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition != '')">
                      <xsl:for-each select="(srcExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition)[1]">
                        <srctime>
                          <timeinfo>
                            <sngdate>
                              <xsl:call-template name="dateTimeElements">
                                <xsl:with-param name="dateEleName">caldate</xsl:with-param>
                                <xsl:with-param name="timeEleName">time</xsl:with-param>
                              </xsl:call-template>
                            </sngdate>
                          </timeinfo>
                          <xsl:for-each select="(../../../../../exDesc)[1]">
                            <srccurr>
                              <xsl:value-of select="."/>
                            </srccurr>
                          </xsl:for-each>
                          <xsl:if test="not(../../../../../exDesc)">
                            <srccurr>Unknown</srccurr>
                          </xsl:if>
                        </srctime>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:for-each select="(srcCitatn/resAltTitle)[1]">
                    <srccitea>
                      <xsl:value-of select="."/>
                    </srccitea>
                  </xsl:for-each>
                  <xsl:for-each select="(srcCitatn[not(resAltTitle)]/resTitle)[1]">
                    <srccitea>
                      <xsl:value-of select="."/>
                    </srccitea>
                  </xsl:for-each>
                  <xsl:for-each select="(srcDesc)[1]">
                    <srccontr>
                      <xsl:value-of select="."/>
                    </srccontr>
                  </xsl:for-each>
                </srcinfo>
              </xsl:for-each>
              <xsl:for-each select="prcStep">
                <xsl:sort select="substring(stepDateTm, 1, 4)" data-type="number"/>
                <xsl:sort select="substring(stepDateTm, 6, 2)" data-type="number"/>
                <xsl:sort select="substring(stepDateTm, 9, 2)" data-type="number"/>
                <procstep>
                  <xsl:for-each select="(stepDesc)[1]">
                    <procdesc>
                      <xsl:value-of select="."/>
                    </procdesc>
                  </xsl:for-each>
                  <xsl:for-each select="stepSrc[@type = 'used']/srcCitatn[(resAltTitle != '') or (resTitle != '')]">
                    <xsl:choose>
                      <xsl:when test="(resAltTitle != '')">
                        <srcused>
                          <xsl:value-of select="resAltTitle"/>
                        </srcused>
                      </xsl:when>
                      <xsl:when test="(resTitle != '')">
                        <srcused>
                          <xsl:value-of select="resTitle"/>
                        </srcused>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:for-each select="(stepDateTm)[1]">
                    <xsl:call-template name="dateTimeElements">
                      <xsl:with-param name="dateEleName">procdate</xsl:with-param>
                      <xsl:with-param name="timeEleName">proctime</xsl:with-param>
                    </xsl:call-template>
                  </xsl:for-each>
                  <xsl:for-each select="stepSrc[@type = 'produced']/srcCitatn[(resAltTitle != '') or (resTitle != '')]">
                    <xsl:choose>
                      <xsl:when test="(resAltTitle != '')">
                        <srcprod>
                          <xsl:value-of select="resAltTitle"/>
                        </srcprod>
                      </xsl:when>
                      <xsl:when test="(resTitle != '')">
                        <srcprod>
                          <xsl:value-of select="resTitle"/>
                        </srcprod>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:for-each select="(stepProc)[1]">
                    <proccont>
                      <cntinfo>
                        <xsl:call-template name="responsible-party"/>
                      </cntinfo>
                    </proccont>
                  </xsl:for-each>
                </procstep>
              </xsl:for-each>
            </lineage>
          </xsl:for-each>
          <xsl:for-each select="(/metadata/contInfo/ImgDesc/cloudCovPer[. != ''])[1]">
            <cloud>
              <xsl:value-of select="round(.)"/>
            </cloud>
          </xsl:for-each>
        </dataqual>
      </xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="spdoinfo">
		<xsl:if test="((/metadata/dataIdInfo[1]/spatRpType/SpatRepTypCd/@value = '001') or (/metadata/dataIdInfo[1]/spatRpType/SpatRepTypCd/@value = '002') or /metadata/spdoinfo/ptvctinf/esriterm or /metadata/spatRepInfo/VectSpatRep/geometObjs or /metadata/spatRepInfo/*/axisDimension or /metadata/contInfo/*/contentTyp/ContentTypCd/@value or /metadata/spatRepInfo/*/cellGeo/CellGeoCd/@value or (/metadata/spatRepInfo/Indref != ''))">
			<spdoinfo>
				<xsl:for-each select="((/metadata/spatRepInfo/Indref))[1]">
					<indspref>
						<xsl:value-of select="."/>
					</indspref>
				</xsl:for-each>
				<xsl:if test="(/metadata/dataIdInfo[1]/spatRpType/SpatRepTypCd/@value = '001')">
					<direct>Vector</direct>
				</xsl:if>
				<xsl:if test="(/metadata/dataIdInfo[1]/spatRpType/SpatRepTypCd/@value = '002')">
					<direct>Raster</direct>
				</xsl:if>
				<xsl:if test="(/metadata/spdoinfo/ptvctinf/esriterm or /metadata/spatRepInfo/VectSpatRep/geometObjs)">
					<ptvctinf>
						<xsl:choose>
							<xsl:when test="/metadata/spdoinfo/ptvctinf/esriterm">
								<xsl:for-each select="/metadata/spdoinfo/ptvctinf/esriterm">
									<sdtsterm>
										<xsl:for-each select="(efeageom/@code[. != ''])[1]">
											<sdtstype>
												<xsl:choose>
													<xsl:when test=". = '1'">
														<xsl:text>Entity point</xsl:text>
													</xsl:when>
													<xsl:when test=". = '2'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '3'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '4'">
														<xsl:text>GT-polygon composed of chains</xsl:text>
													</xsl:when>
													<xsl:when test=". = '5'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = '6'">
														<xsl:text>Complete chain</xsl:text>
													</xsl:when>
													<xsl:when test=". = '9'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '11'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = '13'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '14'">
														<xsl:text>Circular arc, three point center</xsl:text>
													</xsl:when>
													<xsl:when test=". = '15'">
														<xsl:text>Piecewise Bezier</xsl:text>
													</xsl:when>
													<xsl:when test=". = '16'">
														<xsl:text>Elliptical arc</xsl:text>
													</xsl:when>
													<xsl:when test=". = '18'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '19'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '20'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '22'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
												</xsl:choose>
											</sdtstype>
										</xsl:for-each>
										<xsl:for-each select="(efeageom[not(./@code) or (./@code = '')])[1]">
											<sdtstype>
												<xsl:choose>
													<xsl:when test=". = '1'">
														<xsl:text>Entity point</xsl:text>
													</xsl:when>
													<xsl:when test=". = '2'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '3'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '4'">
														<xsl:text>GT-polygon composed of chains</xsl:text>
													</xsl:when>
													<xsl:when test=". = '5'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = '6'">
														<xsl:text>Complete chain</xsl:text>
													</xsl:when>
													<xsl:when test=". = '9'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '11'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = '13'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '14'">
														<xsl:text>Circular arc, three point center</xsl:text>
													</xsl:when>
													<xsl:when test=". = '15'">
														<xsl:text>Piecewise Bezier</xsl:text>
													</xsl:when>
													<xsl:when test=". = '16'">
														<xsl:text>Elliptical arc</xsl:text>
													</xsl:when>
													<xsl:when test=". = '18'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '19'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = '20'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = '22'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Point'">
														<xsl:text>Entity point</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Label'">
														<xsl:text>Label point</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Tic'">
														<xsl:text>Point</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Multipoint'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Polyline'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Arc'">
														<xsl:text>Complete chain</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Polygon'">
														<xsl:text>GT-polygon composed of chains</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Envelope'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Region'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Route'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'MultiPatch'">
														<xsl:text>Composite object</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Region'">
														<xsl:text>G-polygon</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Triangle'">
														<xsl:text>Ring composed of chains</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Node'">
														<xsl:text>Node, planar graph</xsl:text>
													</xsl:when>
													<xsl:when test=". = 'Edge'">
														<xsl:text>Link</xsl:text>
													</xsl:when>
												</xsl:choose>
											</sdtstype>
										</xsl:for-each>
										<xsl:choose>
											<xsl:when test="count (efeacnt) = 0"/>
											<xsl:when test="count (efeacnt) &gt; 1">
												<xsl:for-each select="(efeacnt)[1]">
													<ptvctcnt>
														<xsl:value-of select="."/>
													</ptvctcnt>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="efeacnt">
													<ptvctcnt>
														<xsl:value-of select="."/>
													</ptvctcnt>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</sdtsterm>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="/metadata/spatRepInfo/VectSpatRep/geometObjs">
								<xsl:for-each select="/metadata/spatRepInfo/VectSpatRep/geometObjs">
									<sdtsterm>
										<xsl:for-each select="(geoObjTyp/GeoObjTypCd/@value[. != ''])[1]">
											<sdtstype>
												<xsl:choose>
													<xsl:when test=". = '001'">
														<xsl:text>GT-polygon composed of chains</xsl:text>
													</xsl:when>
													<xsl:when test=". = '002'">
														<xsl:text>Complete chain</xsl:text>
													</xsl:when>
													<xsl:when test=". = '003'">
														<xsl:text>Circular arc, three point center</xsl:text>
													</xsl:when>
													<xsl:when test=". = '004'">
														<xsl:text>Entity point</xsl:text>
													</xsl:when>
													<xsl:when test=". = '005'">
														<xsl:text>Solid</xsl:text>
													</xsl:when>
													<xsl:when test=". = '006'">
														<xsl:text>GT-polygon composed of chains</xsl:text>
													</xsl:when>
												</xsl:choose>
											</sdtstype>
										</xsl:for-each>
										<xsl:choose>
											<xsl:when test="count (geoObjCnt) = 0"/>
											<xsl:when test="count (geoObjCnt) &gt; 1">
												<xsl:for-each select="(geoObjCnt)[1]">
													<ptvctcnt>
														<xsl:value-of select="."/>
													</ptvctcnt>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="geoObjCnt">
													<ptvctcnt>
														<xsl:value-of select="."/>
													</ptvctcnt>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</sdtsterm>
								</xsl:for-each>
							</xsl:when>
						</xsl:choose>
					</ptvctinf>
				</xsl:if>
				<xsl:if test="(/metadata/spatRepInfo/*/axisDimension) or (/metadata/contInfo/*/contentTyp/ContentTypCd/@value) or (/metadata/spatRepInfo/*/cellGeo/CellGeoCd/@value) or (/metadata/dataIdInfo[1]/spatRpType/SpatRepTypCd/@value = '002')">
					<rastinfo>
						<xsl:choose>
							<xsl:when test="(/metadata/contInfo/*/contentTyp/ContentTypCd/@value = '001')">
								<rasttype>Pixel</rasttype>
							</xsl:when>
							<xsl:when test="(/metadata/spatRepInfo/*/cellGeo/CellGeoCd/@value = '001')">
								<rasttype>Point</rasttype>
							</xsl:when>
							<xsl:when test="(/metadata/spatRepInfo/*/cellGeo/CellGeoCd/@value = '002')">
								<rasttype>Grid Cell</rasttype>
							</xsl:when>
							<xsl:when test="(/metadata/spatRepInfo/*/cellGeo/CellGeoCd/@value = '003')">
								<rasttype>Voxel</rasttype>
							</xsl:when>
							<xsl:when test="(/metadata/contInfo/*/contentTyp/ContentTypCd/@value = '002') or (/metadata/contInfo/*/contentTyp/ContentTypCd/@value = '003')">
								<rasttype>Grid Cell</rasttype>
							</xsl:when>
							<xsl:when test="(/metadata/dataIdInfo/spatRpType/SpatRepTypCd/@value = '002')">
								<rasttype>Grid Cell</rasttype>
							</xsl:when>
						</xsl:choose>
						<xsl:for-each select="(/metadata/spatRepInfo/*/axisDimension[@type = '001']/dimSize)[1]">
							<rowcount>
								<xsl:value-of select="."/>
							</rowcount>
						</xsl:for-each>
						<xsl:for-each select="(/metadata/spatRepInfo/*/axisDimension[@type = '002']/dimSize)[1]">
							<colcount>
								<xsl:value-of select="."/>
							</colcount>
						</xsl:for-each>
						<xsl:for-each select="(/metadata/spatRepInfo/*/axisDimension[@type = '003']/dimSize)[1]">
							<vrtcount>
								<xsl:value-of select="."/>
							</vrtcount>
						</xsl:for-each>
					</rastinfo>
				</xsl:if>
			</spdoinfo>
		</xsl:if>
	</xsl:template>
	<xsl:template name="distribution">
		<xsl:for-each select="/metadata/distInfo/distributor">
			<distinfo>
				<xsl:for-each select="distorCont">
					<distrib>
						<cntinfo>
							<xsl:call-template name="responsible-party"/>
						</cntinfo>
					</distrib>
				</xsl:for-each>
				<xsl:choose>
					<xsl:when test="(/metadata/Esri/DataProperties/itemProps/imsContentType != '') and (/metadata/Esri/DataProperties/itemProps/imsContentType/@export = 'True')">
						<xsl:for-each select="(/metadata/Esri/DataProperties/itemProps/imsContentType)[1]">
							<resdesc>
								<xsl:choose>
									<xsl:when test=". = '001'">
										<xsl:text>Live Data and Maps</xsl:text>
									</xsl:when>
									<xsl:when test=". = '002'">
										<xsl:text>Downloadable Data</xsl:text>
									</xsl:when>
									<xsl:when test=". = '003'">
										<xsl:text>Offline Data</xsl:text>
									</xsl:when>
									<xsl:when test=". = '004'">
										<xsl:text>Static Map Images</xsl:text>
									</xsl:when>
									<xsl:when test=". = '005'">
										<xsl:text>Other Documents</xsl:text>
									</xsl:when>
									<xsl:when test=". = '006'">
										<xsl:text>Applications</xsl:text>
									</xsl:when>
									<xsl:when test=". = '007'">
										<xsl:text>Geographic Services</xsl:text>
									</xsl:when>
									<xsl:when test=". = '008'">
										<xsl:text>Clearinghouses</xsl:text>
									</xsl:when>
									<xsl:when test=". = '009'">
										<xsl:text>Map Files</xsl:text>
									</xsl:when>
									<xsl:when test=". = '010'">
										<xsl:text>Geographic Activities</xsl:text>
									</xsl:when>
								</xsl:choose>
							</resdesc>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="count (distorTran/onLineSrc/orDesc[not((. = 'Live Data and Maps') or (. = 'Downloadable Data') or (. = 'Offline Data') or (. = 'Static Map Images') or (. = 'Other Documents') or (. = 'Clearinghouses') or (. = 'Applications') or (. = 'Geographic Services') or (. = 'Map Files') or (. = 'Geographic Activities') or (. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010'))]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(distorTran/onLineSrc/orDesc[not((. = 'Live Data and Maps') or (. = 'Downloadable Data') or (. = 'Offline Data') or (. = 'Static Map Images') or (. = 'Other Documents') or (. = 'Clearinghouses') or (. = 'Applications') or (. = 'Geographic Services') or (. = 'Map Files') or (. = 'Geographic Activities') or (. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010'))])[1]">
									<resdesc>
										<xsl:value-of select="."/>
									</resdesc>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="distliab" select="substring-after(/metadata/dataIdInfo[1]/resConst//*[starts-with(.,'Distribution liability: ')][1],'Distribution liability: ')"/>
				<xsl:choose>
					<xsl:when test="($distliab != '')">
						<distliab>
							<xsl:value-of select="$distliab"/>
						</distliab>
					</xsl:when>
					<xsl:when test="/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Use constraints: ')) and not(starts-with(., 'Access constraints: '))]">
						<xsl:choose>
							<xsl:when test="count (/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Use constraints: ')) and not(starts-with(., 'Access constraints: '))]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Use constraints: ')) and not(starts-with(., 'Access constraints: '))])[1]">
									<distliab>
										<xsl:value-of select="."/>
									</distliab>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<distliab>See access and use constraints information.</distliab>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="distorTran/offLineMed/medName/MedNameCd/@value[(. = '018') or (. = '019') or (. = '020') or (. = '021') or (. = '022') or (. = '023') or (. = '024') or (. = '025') or (. = '026') or (. = '027') or (. = '028') or (. = '029') or (. = '030')]">
					<stdorder>
						<xsl:choose>
							<xsl:when test="count (distorTran/offLineMed[(medName/MedNameCd/@value = '018') or (medName/MedNameCd/@value = '019') or (medName/MedNameCd/@value = '020') or (medName/MedNameCd/@value = '021') or (medName/MedNameCd/@value = '022') or (medName/MedNameCd/@value = '023') or (medName/MedNameCd/@value = '024') or (medName/MedNameCd/@value = '025') or (medName/MedNameCd/@value = '026') or (medName/MedNameCd/@value = '027') or (medName/MedNameCd/@value = '028') or (medName/MedNameCd/@value = '029') or (medName/MedNameCd/@value = '030')]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(distorTran/offLineMed[(medName/MedNameCd/@value = '018') or (medName/MedNameCd/@value = '019') or (medName/MedNameCd/@value = '020') or (medName/MedNameCd/@value = '021') or (medName/MedNameCd/@value = '022') or (medName/MedNameCd/@value = '023') or (medName/MedNameCd/@value = '024') or (medName/MedNameCd/@value = '025') or (medName/MedNameCd/@value = '026') or (medName/MedNameCd/@value = '027') or (medName/MedNameCd/@value = '028') or (medName/MedNameCd/@value = '029') or (medName/MedNameCd/@value = '030')])[1]">
									<xsl:choose>
										<xsl:when test="(medNote != '')">
											<xsl:for-each select="(medNote)[1]">
												<nondig>
													<xsl:value-of select="."/>
												</nondig>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<nondig>
												<xsl:for-each select="(medName/MedNameCd/@value)[1]">
													<xsl:choose>
														<xsl:when test=". = '018'">
															<xsl:text>hardcopy</xsl:text>
														</xsl:when>
														<xsl:when test=". = '019'">
															<xsl:text>hardcopy diazo polyester 08</xsl:text>
														</xsl:when>
														<xsl:when test=". = '020'">
															<xsl:text>hardcopy card microfilm</xsl:text>
														</xsl:when>
														<xsl:when test=". = '021'">
															<xsl:text>hardcopy microfilm 240</xsl:text>
														</xsl:when>
														<xsl:when test=". = '022'">
															<xsl:text>hardcopy microfilm 35</xsl:text>
														</xsl:when>
														<xsl:when test=". = '023'">
															<xsl:text>hardcopy microfilm 70</xsl:text>
														</xsl:when>
														<xsl:when test=". = '024'">
															<xsl:text>hardcopy microfilm general</xsl:text>
														</xsl:when>
														<xsl:when test=". = '025'">
															<xsl:text>hardcopy microfilm microfiche</xsl:text>
														</xsl:when>
														<xsl:when test=". = '026'">
															<xsl:text>hardcopy negative photo</xsl:text>
														</xsl:when>
														<xsl:when test=". = '027'">
															<xsl:text>hardcopy paper</xsl:text>
														</xsl:when>
														<xsl:when test=". = '028'">
															<xsl:text>hardcopy diazo</xsl:text>
														</xsl:when>
														<xsl:when test=". = '029'">
															<xsl:text>hardcopy photo</xsl:text>
														</xsl:when>
														<xsl:when test=". = '030'">
															<xsl:text>hardcopy traced paper</xsl:text>
														</xsl:when>
													</xsl:choose>
												</xsl:for-each>
											</nondig>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="count (distorOrdPrc[(resFees or ordInstr or ordTurn)]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(distorOrdPrc[(resFees or ordInstr or ordTurn)])[1]">
									<xsl:for-each select="(resFees[. != ''])[1]">
										<fees>
											<xsl:value-of select="."/>
										</fees>
									</xsl:for-each>
									<xsl:for-each select="(ordInstr)[1]">
										<ordering>
											<xsl:value-of select="."/>
										</ordering>
									</xsl:for-each>
									<xsl:for-each select="(ordTurn)[1]">
										<turnarnd>
											<xsl:value-of select="."/>
										</turnarnd>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</stdorder>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="distorFormat[formatName | formatVer | formatSpec | fileDecmTech | formatInfo] or distorTran/onLineSrc/linkage or distorTran/offLineMed[not((medName/MedNameCd/@value = '018') or (medName/MedNameCd/@value = '019') or (medName/MedNameCd/@value = '020') or (medName/MedNameCd/@value = '021') or (medName/MedNameCd/@value = '022') or (medName/MedNameCd/@value = '023') or (medName/MedNameCd/@value = '024') or (medName/MedNameCd/@value = '025') or (medName/MedNameCd/@value = '026') or (medName/MedNameCd/@value = '027') or (medName/MedNameCd/@value = '028') or (medName/MedNameCd/@value = '029') or (medName/MedNameCd/@value = '030'))]">
						<stdorder>
							<digform>
								<xsl:choose>
									<xsl:when test="count (distorFormat[formatName | formatVer | formatSpec | fileDecmTech | formatInfo]) = 0"/>
									<xsl:otherwise>
										<xsl:for-each select="(distorFormat[formatName | formatVer | formatSpec | fileDecmTech | formatInfo])[1]">
											<digtinfo>
												<xsl:call-template name="format"/>
												<xsl:choose>
													<xsl:when test="count (../distorTran/transSize) = 0"/>
													<xsl:otherwise>
														<xsl:for-each select="(../distorTran/transSize)[1]">
															<transize>
																<xsl:value-of select="."/>
															</transize>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</digtinfo>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="distorTran[onLineSrc/linkage | offLineMed]">
									<digtopt>
										<xsl:for-each select="distorTran[(onLineSrc/linkage != '')]">
											<onlinopt>
												<xsl:for-each select="onLineSrc[(starts-with(linkage,'http://') or starts-with(linkage,'https://') or starts-with(linkage,'HTTP://') or starts-with(linkage,'HTTPS://'))]">
													<computer>
														<xsl:for-each select="linkage">
															<networka>
																<networkr>
																	<xsl:value-of select="."/>
																</networkr>
															</networka>
														</xsl:for-each>
													</computer>
												</xsl:for-each>
												<xsl:choose>
													<xsl:when test="count (onLineSrc/orDesc[not((. = 'Live Data and Maps') or (. = 'Downloadable Data') or (. = 'Offline Data') or (. = 'Static Map Images') or (. = 'Other Documents') or (. = 'Clearinghouses') or (. = 'Applications') or (. = 'Geographic Services') or (. = 'Map Files') or (. = 'Geographic Activities') or (. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010'))]) = 0"/>
													<xsl:otherwise>
														<xsl:for-each select="(onLineSrc/orDesc[not((. = 'Live Data and Maps') or (. = 'Downloadable Data') or (. = 'Offline Data') or (. = 'Static Map Images') or (. = 'Other Documents') or (. = 'Clearinghouses') or (. = 'Applications') or (. = 'Geographic Services') or (. = 'Map Files') or (. = 'Geographic Activities') or (. = '001') or (. = '002') or (. = '003') or (. = '004') or (. = '005') or (. = '006') or (. = '007') or (. = '008') or (. = '009') or (. = '010'))])[1]">
															<accinstr>
																<xsl:value-of select="."/>
															</accinstr>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</onlinopt>
										</xsl:for-each>
										<xsl:for-each select="distorTran[not((offLineMed/medName/MedNameCd/@value = '018') or (offLineMed/medName/MedNameCd/@value = '019') or (offLineMed/medName/MedNameCd/@value = '020') or (offLineMed/medName/MedNameCd/@value = '021') or (offLineMed/medName/MedNameCd/@value = '022') or (offLineMed/medName/MedNameCd/@value = '023') or (offLineMed/medName/MedNameCd/@value = '024') or (offLineMed/medName/MedNameCd/@value = '025') or (offLineMed/medName/MedNameCd/@value = '026') or (offLineMed/medName/MedNameCd/@value = '027') or (offLineMed/medName/MedNameCd/@value = '028') or (offLineMed/medName/MedNameCd/@value = '029') or (offLineMed/medName/MedNameCd/@value = '030'))]">
											<xsl:for-each select="offLineMed">
												<offoptn>
													<xsl:for-each select="(medName/MedNameCd/@value)[1]">
														<offmedia>
															<xsl:choose>
																<xsl:when test=". = '001'">
																	<xsl:text>CD-ROM</xsl:text>
																</xsl:when>
																<xsl:when test=". = '002'">
																	<xsl:text>dvd</xsl:text>
																</xsl:when>
																<xsl:when test=". = '003'">
																	<xsl:text>dvdRom</xsl:text>
																</xsl:when>
																<xsl:when test=". = '004'">
																	<xsl:text>3-1/2 inch floppy disk</xsl:text>
																</xsl:when>
																<xsl:when test=". = '005'">
																	<xsl:text>5-1/4 inch floppy disk</xsl:text>
																</xsl:when>
																<xsl:when test=". = '006'">
																	<xsl:text>7trackTape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '007'">
																	<xsl:text>9-track tape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '008'">
																	<xsl:text>3480Cartridge</xsl:text>
																</xsl:when>
																<xsl:when test=". = '009'">
																	<xsl:text>3490Cartridge</xsl:text>
																</xsl:when>
																<xsl:when test=". = '010'">
																	<xsl:text>3580Cartridge</xsl:text>
																</xsl:when>
																<xsl:when test=". = '011'">
																	<xsl:text>4 mm cartridge tape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '012'">
																	<xsl:text>8 mm cartridge tape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '013'">
																	<xsl:text>1/4-inch cartridge tape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '014'">
																	<xsl:text>digitalLinearTape</xsl:text>
																</xsl:when>
																<xsl:when test=". = '015'">
																	<xsl:text>onLine</xsl:text>
																</xsl:when>
																<xsl:when test=". = '016'">
																	<xsl:text>satellite</xsl:text>
																</xsl:when>
																<xsl:when test=". = '017'">
																	<xsl:text>telephoneLink</xsl:text>
																</xsl:when>
																<xsl:when test=". = '031'">
																	<xsl:text>hardDisk</xsl:text>
																</xsl:when>
																<xsl:when test=". = '032'">
																	<xsl:text>USBFlashDrive</xsl:text>
																</xsl:when>
															</xsl:choose>
														</offmedia>
													</xsl:for-each>
													<xsl:if test="medDensity | medDenUnits">
														<reccap>
															<xsl:for-each select="medDensity">
																<recden>
																	<xsl:value-of select="."/>
																</recden>
															</xsl:for-each>
															<xsl:choose>
																<xsl:when test="count (medDenUnits) = 0"/>
																<xsl:when test="count (medDenUnits) &gt; 1">
																	<xsl:for-each select="(medDenUnits)[1]">
																		<recdenu>
																			<xsl:value-of select="."/>
																		</recdenu>
																	</xsl:for-each>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:for-each select="medDenUnits">
																		<recdenu>
																			<xsl:value-of select="."/>
																		</recdenu>
																	</xsl:for-each>
																</xsl:otherwise>
															</xsl:choose>
														</reccap>
													</xsl:if>
													<xsl:for-each select="medFormat/MedFormCd/@value">
														<recfmt>
															<xsl:choose>
																<xsl:when test=". = '001'">
																	<xsl:text>cpio</xsl:text>
																</xsl:when>
																<xsl:when test=". = '002'">
																	<xsl:text>tar</xsl:text>
																</xsl:when>
																<xsl:when test=". = '003'">
																	<xsl:text>High Sierra</xsl:text>
																</xsl:when>
																<xsl:when test=". = '004'">
																	<xsl:text>ISO 9660</xsl:text>
																</xsl:when>
																<xsl:when test=". = '005'">
																	<xsl:text>ISO 9660 with Rock Ridge extensions</xsl:text>
																</xsl:when>
																<xsl:when test=". = '006'">
																	<xsl:text>ISO 9660 with Apple HFS extensions</xsl:text>
																</xsl:when>
																<xsl:when test=". = '007'">
																	<xsl:text>Universal Disk Format file system</xsl:text>
																</xsl:when>
															</xsl:choose>
														</recfmt>
													</xsl:for-each>
													<xsl:for-each select="(medNote)[1]">
														<compat>
															<xsl:value-of select="."/>
														</compat>
													</xsl:for-each>
												</offoptn>
											</xsl:for-each>
										</xsl:for-each>
									</digtopt>
								</xsl:if>
							</digform>
							<xsl:choose>
								<xsl:when test="count (distorOrdPrc[(resFees or ordInstr or ordTurn)]) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(distorOrdPrc[(resFees or ordInstr or ordTurn)])[1]">
										<xsl:choose>
											<xsl:when test="count (resFees[. != '']) = 0"/>
											<xsl:when test="count (resFees[. != '']) &gt; 1">
												<xsl:for-each select="(resFees[. != ''])[1]">
													<fees>
														<xsl:value-of select="."/>
													</fees>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="resFees[. != '']">
													<fees>
														<xsl:value-of select="."/>
													</fees>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:for-each select="(ordInstr)[1]">
											<ordering>
												<xsl:value-of select="."/>
											</ordering>
										</xsl:for-each>
										<xsl:for-each select="(ordTurn)[1]">
											<turnarnd>
												<xsl:value-of select="."/>
											</turnarnd>
										</xsl:for-each>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</stdorder>
					</xsl:when>
					<xsl:when test="(distorOrdPrc/resFees != '') or (distorOrdPrc/ordTurn != '')">
						<stdorder>
							<xsl:choose>
								<xsl:when test="count (distorOrdPrc[(resFees != '') or (ordTurn != '')]) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(distorOrdPrc[(resFees != '') or (ordTurn != '')])[1]">
										<xsl:choose>
											<xsl:when test="count (resFees[. != '']) = 0"/>
											<xsl:when test="count (resFees[. != '']) &gt; 1">
												<xsl:for-each select="(resFees[. != ''])[1]">
													<fees>
														<xsl:value-of select="."/>
													</fees>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each select="resFees[. != '']">
													<fees>
														<xsl:value-of select="."/>
													</fees>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:for-each select="(ordInstr)[1]">
											<ordering>
												<xsl:value-of select="."/>
											</ordering>
										</xsl:for-each>
										<xsl:for-each select="(ordTurn)[1]">
											<turnarnd>
												<xsl:value-of select="."/>
											</turnarnd>
										</xsl:for-each>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</stdorder>
					</xsl:when>
					<xsl:when test="(distorOrdPrc/ordInstr != '') and (not(distorOrdPrc/resFees) or (distorOrdPrc/resFees = '')) and (not(distorOrdPrc/ordTurn) or (distorOrdPrc/ordTurn = ''))">
						<xsl:choose>
							<xsl:when test="count (distorOrdPrc[(ordInstr != '') and (not(resFees) or (resFees = '')) and (not(ordTurn) or (ordTurn = ''))]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(distorOrdPrc[(ordInstr != '') and (not(resFees) or (resFees = '')) and (not(ordTurn) or (ordTurn = ''))])[1]">
									<xsl:for-each select="(ordInstr)[1]">
										<custom>
											<xsl:value-of select="."/>
										</custom>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="(distorOrdPrc/planAvDtTm != '') or (distorOrdPrc/planAvTmPd != '')">
					<xsl:choose>
						<xsl:when test="count (distorOrdPrc/planAvDtTm) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(distorOrdPrc/planAvDtTm)[1]">
								<availabl>
									<timeinfo>
										<sngdate>
											<xsl:call-template name="dateTimeElements">
												<xsl:with-param name="dateEleName">caldate</xsl:with-param>
												<xsl:with-param name="timeEleName">time</xsl:with-param>
											</xsl:call-template>
										</sngdate>
									</timeinfo>
								</availabl>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(distorOrdPrc/planAvDtTm) and (distorOrdPrc/planAvTmPd)">
						<xsl:for-each select="(distorOrdPrc/planAvTmPd)[1]">
							<availabl>
								<timeinfo>
									<rngdates>
										<xsl:for-each select="(tmBegin)[1]">
											<xsl:call-template name="dateTimeElements">
												<xsl:with-param name="dateEleName">begdate</xsl:with-param>
												<xsl:with-param name="timeEleName">begtime</xsl:with-param>
											</xsl:call-template>
										</xsl:for-each>
										<xsl:for-each select="(tmEnd)[1]">
											<xsl:call-template name="dateTimeElements">
												<xsl:with-param name="dateEleName">enddate</xsl:with-param>
												<xsl:with-param name="timeEleName">endtime</xsl:with-param>
											</xsl:call-template>
										</xsl:for-each>
									</rngdates>
								</timeinfo>
							</availabl>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
				<xsl:if test="(distorFormat/formatTech != '')">
					<xsl:choose>
						<xsl:when test="count (distorFormat/formatTech) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(distorFormat/formatTech)[1]">
								<techpreq>
									<xsl:value-of select="."/>
								</techpreq>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</distinfo>
		</xsl:for-each>
		<xsl:if test="(/metadata/Esri/DataProperties/itemProps/imsContentType[(. != '') and (@export = 'True')]) and not(/metadata/distInfo/distributor//* != '')">
			<xsl:for-each select="(/metadata/Esri/DataProperties/itemProps/imsContentType)[1]">
				<distinfo>
					<resdesc>
						<xsl:choose>
							<xsl:when test=". = '001'">
								<xsl:text>Live Data and Maps</xsl:text>
							</xsl:when>
							<xsl:when test=". = '002'">
								<xsl:text>Downloadable Data</xsl:text>
							</xsl:when>
							<xsl:when test=". = '003'">
								<xsl:text>Offline Data</xsl:text>
							</xsl:when>
							<xsl:when test=". = '004'">
								<xsl:text>Static Map Images</xsl:text>
							</xsl:when>
							<xsl:when test=". = '005'">
								<xsl:text>Other Documents</xsl:text>
							</xsl:when>
							<xsl:when test=". = '006'">
								<xsl:text>Applications</xsl:text>
							</xsl:when>
							<xsl:when test=". = '007'">
								<xsl:text>Geographic Services</xsl:text>
							</xsl:when>
							<xsl:when test=". = '008'">
								<xsl:text>Clearinghouses</xsl:text>
							</xsl:when>
							<xsl:when test=". = '009'">
								<xsl:text>Map Files</xsl:text>
							</xsl:when>
							<xsl:when test=". = '010'">
								<xsl:text>Geographic Activities</xsl:text>
							</xsl:when>
						</xsl:choose>
					</resdesc>
				</distinfo>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="format">
		<xsl:choose>
			<xsl:when test="count (formatName) = 0"/>
			<xsl:when test="count (formatName) &gt; 1">
				<xsl:for-each select="(formatName)[1]">
					<formname>
						<xsl:value-of select="."/>
					</formname>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="formatName">
					<formname>
						<xsl:value-of select="."/>
					</formname>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="(formatVer)[1]">
			<formvern>
				<xsl:value-of select="."/>
			</formvern>
		</xsl:for-each>
		<xsl:for-each select="(formatSpec)[1]">
			<formspec>
				<xsl:value-of select="."/>
			</formspec>
		</xsl:for-each>
		<xsl:for-each select="(formatInfo)[1]">
			<formcont>
				<xsl:value-of select="."/>
			</formcont>
		</xsl:for-each>
		<xsl:for-each select="(fileDecmTech)[1]">
			<filedec>
				<xsl:value-of select="."/>
			</filedec>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="binary"/>
	<xsl:template name="entity-and-attribute">
		<xsl:for-each select="/metadata/eainfo">
			<xsl:apply-templates select="." mode="recurse-copy-IDAU51C"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="metainfo">
		<metainfo>
			<xsl:choose>
				<xsl:when test="count (/metadata/mdDateSt) = 0"/>
				<xsl:when test="count (/metadata/mdDateSt) &gt; 1">
					<xsl:for-each select="(/metadata/mdDateSt)[1]">
						<xsl:call-template name="dateOnlyElements">
							<xsl:with-param name="dateEleName">metd</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="/metadata/mdDateSt">
						<xsl:call-template name="dateOnlyElements">
							<xsl:with-param name="dateEleName">metd</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="lastReviewDate" select="substring-after(/metadata/mdMaint/maintNote[starts-with(.,'Last metadata review date: ')],'Last metadata review date: ')"/>
			<xsl:choose>
				<xsl:when test="count (/metadata/mdMaint/maintNote[substring-after(.,'Last metadata review date: ')]) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/mdMaint/maintNote[substring-after(.,'Last metadata review date: ')])[1]">
						<metrd>
							<xsl:value-of select="$lastReviewDate"/>
						</metrd>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count (/metadata/mdMaint/dateNext) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/mdMaint/dateNext)[1]">
						<xsl:call-template name="dateOnlyElements">
							<xsl:with-param name="dateEleName">metfrd</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count (/metadata/mdContact) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/mdContact)[1]">
						<metc>
							<cntinfo>
								<xsl:call-template name="responsible-party"/>
							</cntinfo>
						</metc>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<metstdn>FGDC Content Standard for Digital Geospatial Metadata</metstdn>
			<metstdv>FGDC-STD-001-1998</metstdv>
			<mettc>local time</mettc>
			<xsl:variable name="metac" select="substring-after(/metadata/mdConst//*[starts-with(.,'Access constraints: ')][1],'Access constraints: ')"/>
			<xsl:choose>
				<xsl:when test="($metac != '')">
					<metac>
						<xsl:value-of select="$metac"/>
					</metac>
				</xsl:when>
				<xsl:when test="(/metadata/mdConst//othConsts != '')">
					<metac>
						<xsl:value-of select="/metadata/mdConst//othConsts[. != ''][1]"/>
					</metac>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="/metadata/mdConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]">
					<xsl:choose>
						<xsl:when test="count (/metadata/mdConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(/metadata/mdConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))])[1]">
								<metuc>
									<xsl:call-template name="fixHTML">
										<xsl:with-param name="text">
											<xsl:value-of select="."/>
										</xsl:with-param>
									</xsl:call-template>
								</metuc>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="/metadata/mdConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]">
					<xsl:choose>
						<xsl:when test="count (/metadata/mdConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(/metadata/mdConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))])[1]">
								<metuc>
									<xsl:value-of select="."/>
								</metuc>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="/metadata/mdConst/LegConsts/othConsts[starts-with(., 'Use constraints: ')]">
					<xsl:variable name="metuc" select="substring-after(/metadata/mdConst/LegConsts/othConsts[starts-with(.,'Use constraints: ')][1],'Use constraints: ')"/>
					<xsl:if test="($metuc != '')">
						<metuc>
							<xsl:value-of select="$metuc"/>
						</metuc>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count (/metadata/mdConst/SecConsts) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/mdConst/SecConsts)[1]">
						<metsi>
							<xsl:choose>
								<xsl:when test="count (classSys) = 0"/>
								<xsl:when test="count (classSys) &gt; 1">
									<xsl:for-each select="(classSys)[1]">
										<metscs>
											<xsl:value-of select="."/>
										</metscs>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="classSys">
										<metscs>
											<xsl:value-of select="."/>
										</metscs>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="count (class/ClasscationCd/@value) = 0"/>
								<xsl:when test="count (class/ClasscationCd/@value) &gt; 1">
									<xsl:for-each select="(class/ClasscationCd/@value)[1]">
										<metsc>
											<xsl:call-template name="security-info"/>
										</metsc>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="class/ClasscationCd/@value">
										<metsc>
											<xsl:call-template name="security-info"/>
										</metsc>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="(handDesc)[1]">
								<metshd>
									<xsl:value-of select="."/>
								</metshd>
							</xsl:for-each>
						</metsi>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</metainfo>
	</xsl:template>
	<xsl:template name="security-info">
		<xsl:choose>
			<xsl:when test=". = '001'">
				<xsl:text>Unclassified</xsl:text>
			</xsl:when>
			<xsl:when test=". = '002'">
				<xsl:text>Restricted</xsl:text>
			</xsl:when>
			<xsl:when test=". = '003'">
				<xsl:text>Confidential</xsl:text>
			</xsl:when>
			<xsl:when test=". = '004'">
				<xsl:text>Secret</xsl:text>
			</xsl:when>
			<xsl:when test=". = '005'">
				<xsl:text>Top secret</xsl:text>
			</xsl:when>
			<xsl:when test=". = '006'">
				<xsl:text>Sensitive</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="idinfo">
		<idinfo>
			<xsl:for-each select="/metadata/dataIdInfo[1]/idCitation">
				<citation>
					<citeinfo>
						<xsl:call-template name="citation"/>
					</citeinfo>
				</citation>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="count (/metadata/dataIdInfo[1][idAbs | idPurp | suppInfo]) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="/metadata/dataIdInfo[1][idAbs | idPurp | suppInfo]">
						<descript>
							<xsl:choose>
								<xsl:when test="count (idAbs) = 0"/>
								<xsl:when test="count (idAbs) &gt; 1">
									<xsl:for-each select="(idAbs)[1]">
										<abstract>
											<xsl:call-template name="fixHTML">
												<xsl:with-param name="text">
													<xsl:value-of select="."/>
												</xsl:with-param>
											</xsl:call-template>
										</abstract>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="idAbs">
										<abstract>
											<xsl:call-template name="fixHTML">
												<xsl:with-param name="text">
													<xsl:value-of select="."/>
												</xsl:with-param>
											</xsl:call-template>
										</abstract>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="(idPurp)[1]">
								<purpose>
									<xsl:call-template name="fixHTML">
										<xsl:with-param name="text">
											<xsl:value-of select="."/>
										</xsl:with-param>
									</xsl:call-template>
								</purpose>
							</xsl:for-each>
							<xsl:for-each select="(suppInfo)[1]">
								<supplinf>
									<xsl:value-of select="."/>
								</supplinf>
							</xsl:for-each>
						</descript>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Period)[1]">
				<timeperd>
					<timeinfo>
						<rngdates>
							<xsl:for-each select="(tmBegin)[1]">
								<xsl:call-template name="dateTimeElements">
									<xsl:with-param name="dateEleName">begdate</xsl:with-param>
									<xsl:with-param name="timeEleName">begtime</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:for-each select="(tmEnd)[1]">
								<xsl:call-template name="dateTimeElements">
									<xsl:with-param name="dateEleName">enddate</xsl:with-param>
									<xsl:with-param name="timeEleName">endtime</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
						</rngdates>
					</timeinfo>
					<xsl:choose>
						<xsl:when test="count (../../../../exDesc) = 0"/>
						<xsl:when test="count (../../../../exDesc) &gt; 1">
							<xsl:for-each select="(../../../../exDesc)[1]">
								<current>
									<xsl:value-of select="."/>
								</current>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="../../../../exDesc">
								<current>
									<xsl:value-of select="."/>
								</current>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(../../../../exDesc)">
						<current>Unknown</current>
					</xsl:if>
				</timeperd>
			</xsl:for-each>
			<xsl:if test="not(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Period) and (count(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition) = 1)">
				<xsl:for-each select="(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition)[1]">
					<timeperd>
						<timeinfo>
							<sngdate>
								<xsl:call-template name="dateTimeElements">
									<xsl:with-param name="dateEleName">caldate</xsl:with-param>
									<xsl:with-param name="timeEleName">time</xsl:with-param>
								</xsl:call-template>
							</sngdate>
						</timeinfo>
						<xsl:choose>
							<xsl:when test="count (../../../../../exDesc) = 0"/>
							<xsl:when test="count (../../../../../exDesc) &gt; 1">
								<xsl:for-each select="(../../../../../exDesc)[1]">
									<current>
										<xsl:value-of select="."/>
									</current>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="../../../../../exDesc">
									<current>
										<xsl:value-of select="."/>
									</current>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="not(../../../../../exDesc)">
							<current>Unknown</current>
						</xsl:if>
					</timeperd>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="not(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Period) and (count(/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition) &gt; 1)">
				<timeperd>
					<timeinfo>
						<mdattim>
							<xsl:for-each select="/metadata/dataIdInfo[1]/dataExt/tempEle/TempExtent/exTemp/TM_Instant/tmPosition">
								<sngdate>
									<xsl:call-template name="dateTimeElements">
										<xsl:with-param name="dateEleName">caldate</xsl:with-param>
										<xsl:with-param name="timeEleName">time</xsl:with-param>
									</xsl:call-template>
								</sngdate>
							</xsl:for-each>
						</mdattim>
					</timeinfo>
					<xsl:choose>
						<xsl:when test="count (/metadata/dataIdInfo[1]/dataExt[tempEle//tmPosition]/exDesc[(. != '')]) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(/metadata/dataIdInfo[1]/dataExt[tempEle//tmPosition]/exDesc[(. != '')])[1]">
								<current>
									<xsl:value-of select="."/>
								</current>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(/metadata/dataIdInfo[1]/dataExt[tempEle//tmPosition]/exDesc[(. != '')])">
						<current>Unknown</current>
					</xsl:if>
				</timeperd>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="count (/metadata/dataIdInfo[1]/idStatus/ProgCd/@value | /metadata/dataIdInfo[1]/resMaint/maintFreq/MaintFreqCd/@value) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/dataIdInfo[1]/idStatus/ProgCd/@value | /metadata/dataIdInfo[1]/resMaint/maintFreq/MaintFreqCd/@value)[1]">
						<status>
							<xsl:choose>
								<xsl:when test="count (/metadata/dataIdInfo[1]/idStatus/ProgCd/@value) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(/metadata/dataIdInfo[1]/idStatus/ProgCd/@value)[1]">
										<progress>
											<xsl:choose>
												<xsl:when test=". = '001'">
													<xsl:text>Complete</xsl:text>
												</xsl:when>
												<xsl:when test=". = '002'">
													<xsl:text>Complete</xsl:text>
												</xsl:when>
												<xsl:when test=". = '003'">
													<xsl:text>Complete</xsl:text>
												</xsl:when>
												<xsl:when test=". = '004'">
													<xsl:text>In work</xsl:text>
												</xsl:when>
												<xsl:when test=". = '005'">
													<xsl:text>Planned</xsl:text>
												</xsl:when>
												<xsl:when test=". = '006'">
													<xsl:text>Planned</xsl:text>
												</xsl:when>
												<xsl:when test=". = '007'">
													<xsl:text>In work</xsl:text>
												</xsl:when>
											</xsl:choose>
										</progress>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="count (/metadata/dataIdInfo[1]/resMaint/maintFreq/MaintFreqCd/@value) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(/metadata/dataIdInfo[1]/resMaint/maintFreq/MaintFreqCd/@value)[1]">
										<update>
											<xsl:choose>
												<xsl:when test=". = '001'">
													<xsl:text>Continually</xsl:text>
												</xsl:when>
												<xsl:when test=". = '002'">
													<xsl:text>Daily</xsl:text>
												</xsl:when>
												<xsl:when test=". = '003'">
													<xsl:text>Weekly</xsl:text>
												</xsl:when>
												<xsl:when test=". = '004'">
													<xsl:text>Fortnightly</xsl:text>
												</xsl:when>
												<xsl:when test=". = '005'">
													<xsl:text>Monthly</xsl:text>
												</xsl:when>
												<xsl:when test=". = '006'">
													<xsl:text>Quarterly</xsl:text>
												</xsl:when>
												<xsl:when test=". = '007'">
													<xsl:text>Biannually</xsl:text>
												</xsl:when>
												<xsl:when test=". = '008'">
													<xsl:text>Annually</xsl:text>
												</xsl:when>
												<xsl:when test=". = '009'">
													<xsl:text>As needed</xsl:text>
												</xsl:when>
												<xsl:when test=". = '010'">
													<xsl:text>Irregular</xsl:text>
												</xsl:when>
												<xsl:when test=". = '011'">
													<xsl:text>None planned</xsl:text>
												</xsl:when>
												<xsl:when test=". = '012'">
													<xsl:text>Unknown</xsl:text>
												</xsl:when>
											</xsl:choose>
										</update>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</status>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="(/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[not(@esriExtentType='native')]) or (/metadata/dataIdInfo[1]/dataExt/geoEle/BoundPoly/polygon/exterior)">
				<spdom>
					<xsl:choose>
						<xsl:when test="/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[(@esriExtentType='search') and (*/@Sync = 'TRUE') and ((westBL &gt; -181) and (westBL &lt; 181) and (eastBL &gt; -181) and (eastBL &lt; 181) and (northBL &gt; -91) and (northBL &lt; 91) and (southBL &gt; -91) and (southBL &lt; 91))]">
							<xsl:choose>
								<xsl:when test="count (/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[(@esriExtentType='search') and (*/@Sync = 'TRUE') and ((westBL &gt; -181) and (westBL &lt; 181) and (eastBL &gt; -181) and (eastBL &lt; 181) and (northBL &gt; -91) and (northBL &lt; 91) and (southBL &gt; -91) and (southBL &lt; 91))]) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[(@esriExtentType='search') and (*/@Sync = 'TRUE') and ((westBL &gt; -181) and (westBL &lt; 181) and (eastBL &gt; -181) and (eastBL &lt; 181) and (northBL &gt; -91) and (northBL &lt; 91) and (southBL &gt; -91) and (southBL &lt; 91))])[1]">
										<bounding>
											<westbc>
												<xsl:choose>
													<xsl:when test="count (westBL) = 0"/>
													<xsl:when test="count (westBL) &gt; 1">
														<xsl:for-each select="(westBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="westBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</westbc>
											<eastbc>
												<xsl:choose>
													<xsl:when test="count (eastBL) = 0"/>
													<xsl:when test="count (eastBL) &gt; 1">
														<xsl:for-each select="(eastBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="eastBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</eastbc>
											<northbc>
												<xsl:choose>
													<xsl:when test="count (northBL) = 0"/>
													<xsl:when test="count (northBL) &gt; 1">
														<xsl:for-each select="(northBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="northBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</northbc>
											<southbc>
												<xsl:choose>
													<xsl:when test="count (southBL) = 0"/>
													<xsl:when test="count (southBL) &gt; 1">
														<xsl:for-each select="(southBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="southBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</southbc>
										</bounding>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="count (/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[not(@esriExtentType='native') and ((westBL &gt; -181) and (westBL &lt; 181) and (eastBL &gt; -181) and (eastBL &lt; 181) and (northBL &gt; -91) and (northBL &lt; 91) and (southBL &gt; -91) and (southBL &lt; 91))]) = 0"/>
								<xsl:otherwise>
									<xsl:for-each select="(/metadata/dataIdInfo[1]/dataExt/geoEle/GeoBndBox[not(@esriExtentType='native') and ((westBL &gt; -181) and (westBL &lt; 181) and (eastBL &gt; -181) and (eastBL &lt; 181) and (northBL &gt; -91) and (northBL &lt; 91) and (southBL &gt; -91) and (southBL &lt; 91))])[1]">
										<bounding>
											<westbc>
												<xsl:choose>
													<xsl:when test="count (westBL) = 0"/>
													<xsl:when test="count (westBL) &gt; 1">
														<xsl:for-each select="(westBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="westBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</westbc>
											<eastbc>
												<xsl:choose>
													<xsl:when test="count (eastBL) = 0"/>
													<xsl:when test="count (eastBL) &gt; 1">
														<xsl:for-each select="(eastBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="eastBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</eastbc>
											<northbc>
												<xsl:choose>
													<xsl:when test="count (northBL) = 0"/>
													<xsl:when test="count (northBL) &gt; 1">
														<xsl:for-each select="(northBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="northBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</northbc>
											<southbc>
												<xsl:choose>
													<xsl:when test="count (southBL) = 0"/>
													<xsl:when test="count (southBL) &gt; 1">
														<xsl:for-each select="(southBL)[1]">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:for-each select="southBL">
															<xsl:value-of select="."/>
														</xsl:for-each>
													</xsl:otherwise>
												</xsl:choose>
											</southbc>
										</bounding>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="/metadata/dataIdInfo[1]/dataExt/geoEle/BoundPoly/polygon">
						<dsgpoly>
							<xsl:choose>
								<xsl:when test="count (exterior) = 0"/>
								<xsl:when test="count (exterior) &gt; 1">
									<xsl:for-each select="(exterior)[1]">
										<dsgpolyo>
											<xsl:choose>
												<xsl:when test="pos">
													<xsl:for-each select="pos">
														<xsl:variable name="lat" select="substring-after(.,' ')"/>
														<xsl:variable name="long" select="substring-before(.,' ')"/>
														<grngpoin>
															<gringlat>
																<xsl:value-of select="$lat"/>
															</gringlat>
															<gringlon>
																<xsl:value-of select="$long"/>
															</gringlon>
														</grngpoin>
													</xsl:for-each>
												</xsl:when>
												<xsl:when test="posList">
													<xsl:choose>
														<xsl:when test="count (posList) = 0"/>
														<xsl:when test="count (posList) &gt; 1">
															<xsl:for-each select="(posList)[1]">
																<gring>
																	<xsl:value-of select="."/>
																</gring>
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="posList">
																<gring>
																	<xsl:value-of select="."/>
																</gring>
															</xsl:for-each>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
											</xsl:choose>
										</dsgpolyo>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="exterior">
										<dsgpolyo>
											<xsl:choose>
												<xsl:when test="pos">
													<xsl:for-each select="pos">
														<xsl:variable name="lat" select="substring-after(.,' ')"/>
														<xsl:variable name="long" select="substring-before(.,' ')"/>
														<grngpoin>
															<gringlat>
																<xsl:value-of select="$lat"/>
															</gringlat>
															<gringlon>
																<xsl:value-of select="$long"/>
															</gringlon>
														</grngpoin>
													</xsl:for-each>
												</xsl:when>
												<xsl:when test="posList">
													<xsl:choose>
														<xsl:when test="count (posList) = 0"/>
														<xsl:when test="count (posList) &gt; 1">
															<xsl:for-each select="(posList)[1]">
																<gring>
																	<xsl:value-of select="."/>
																</gring>
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="posList">
																<gring>
																	<xsl:value-of select="."/>
																</gring>
															</xsl:for-each>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
											</xsl:choose>
										</dsgpolyo>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="interior">
								<dsgpolyx>
									<xsl:choose>
										<xsl:when test="pos">
											<xsl:for-each select="pos">
												<xsl:variable name="lat" select="substring-after(.,' ')"/>
												<xsl:variable name="long" select="substring-before(.,' ')"/>
												<grngpoin>
													<gringlat>
														<xsl:value-of select="$lat"/>
													</gringlat>
													<gringlon>
														<xsl:value-of select="$long"/>
													</gringlon>
												</grngpoin>
											</xsl:for-each>
										</xsl:when>
										<xsl:when test="posList">
											<xsl:choose>
												<xsl:when test="count (posList) = 0"/>
												<xsl:when test="count (posList) &gt; 1">
													<xsl:for-each select="(posList)[1]">
														<gring>
															<xsl:value-of select="."/>
														</gring>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:for-each select="posList">
														<gring>
															<xsl:value-of select="."/>
														</gring>
													</xsl:for-each>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
									</xsl:choose>
								</dsgpolyx>
							</xsl:for-each>
						</dsgpoly>
					</xsl:for-each>
				</spdom>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="count (/metadata/dataIdInfo[1][themeKeys] | /metadata/dataIdInfo[1][placeKeys] | /metadata/dataIdInfo[1][stratKeys] | /metadata/dataIdInfo[1][tempKeys] | /metadata/dataIdInfo[1][searchKeys] | /metadata/dataIdInfo[1][tpCat/TopicCatCd/@value]) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="/metadata/dataIdInfo[1][themeKeys] | /metadata/dataIdInfo[1][placeKeys] | /metadata/dataIdInfo[1][stratKeys] | /metadata/dataIdInfo[1][tempKeys] | /metadata/dataIdInfo[1][searchKeys] | /metadata/dataIdInfo[1][tpCat/TopicCatCd/@value]">
						<keywords>
							<xsl:for-each select="themeKeys">
								<theme>
									<xsl:choose>
										<xsl:when test="count (thesaName/resTitle) = 0"/>
										<xsl:when test="count (thesaName/resTitle) &gt; 1">
											<xsl:for-each select="(thesaName/resTitle)[1]">
												<themekt>
													<xsl:value-of select="."/>
												</themekt>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="thesaName/resTitle">
												<themekt>
													<xsl:value-of select="."/>
												</themekt>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="not(thesaName/resTitle)">
										<themekt>None</themekt>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="count (keyword) = 0"/>
										<xsl:otherwise>
											<xsl:for-each select="keyword">
												<themekey>
													<xsl:value-of select="."/>
												</themekey>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</theme>
							</xsl:for-each>
							<xsl:if test="/metadata/dataIdInfo[1][not(contains(themeKeys/thesaName/resTitle, '19115') or contains(themeKeys/thesaName/resTitle, 'Topic Categories') or contains(themeKeys/thesaName/resTitle, 'Topic Category')) and (tpCat/TopicCatCd/@value)]">
								<xsl:for-each select="/metadata/dataIdInfo[1][tpCat/TopicCatCd/@value != '']">
									<theme>
										<themekt>ISO 19115 Topic Categories</themekt>
										<xsl:for-each select="tpCat/TopicCatCd/@value">
											<themekey>
												<xsl:choose>
													<xsl:when test=". = '001'">
														<xsl:text>farming</xsl:text>
													</xsl:when>
													<xsl:when test=". = '002'">
														<xsl:text>biota</xsl:text>
													</xsl:when>
													<xsl:when test=". = '003'">
														<xsl:text>boundaries</xsl:text>
													</xsl:when>
													<xsl:when test=". = '004'">
														<xsl:text>climatologyMeteorologyAtmosphere</xsl:text>
													</xsl:when>
													<xsl:when test=". = '005'">
														<xsl:text>economy</xsl:text>
													</xsl:when>
													<xsl:when test=". = '006'">
														<xsl:text>elevation</xsl:text>
													</xsl:when>
													<xsl:when test=". = '007'">
														<xsl:text>environment</xsl:text>
													</xsl:when>
													<xsl:when test=". = '008'">
														<xsl:text>geoscientificInformation</xsl:text>
													</xsl:when>
													<xsl:when test=". = '009'">
														<xsl:text>health</xsl:text>
													</xsl:when>
													<xsl:when test=". = '010'">
														<xsl:text>imageryBaseMapsEarthCover</xsl:text>
													</xsl:when>
													<xsl:when test=". = '011'">
														<xsl:text>intelligenceMilitary</xsl:text>
													</xsl:when>
													<xsl:when test=". = '012'">
														<xsl:text>inlandWaters</xsl:text>
													</xsl:when>
													<xsl:when test=". = '013'">
														<xsl:text>location</xsl:text>
													</xsl:when>
													<xsl:when test=". = '014'">
														<xsl:text>oceans</xsl:text>
													</xsl:when>
													<xsl:when test=". = '015'">
														<xsl:text>planningCadastre</xsl:text>
													</xsl:when>
													<xsl:when test=". = '016'">
														<xsl:text>society</xsl:text>
													</xsl:when>
													<xsl:when test=". = '017'">
														<xsl:text>structure</xsl:text>
													</xsl:when>
													<xsl:when test=". = '018'">
														<xsl:text>transportation</xsl:text>
													</xsl:when>
													<xsl:when test=". = '019'">
														<xsl:text>utilitiesCommunication</xsl:text>
													</xsl:when>
												</xsl:choose>
											</themekey>
										</xsl:for-each>
									</theme>
								</xsl:for-each>
							</xsl:if>
							<xsl:for-each select="placeKeys">
								<place>
									<xsl:choose>
										<xsl:when test="count (thesaName/resTitle) = 0"/>
										<xsl:when test="count (thesaName/resTitle) &gt; 1">
											<xsl:for-each select="(thesaName/resTitle)[1]">
												<placekt>
													<xsl:value-of select="."/>
												</placekt>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="thesaName/resTitle">
												<placekt>
													<xsl:value-of select="."/>
												</placekt>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="not(thesaName/resTitle)">
										<placekt>None</placekt>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="count (keyword) = 0"/>
										<xsl:otherwise>
											<xsl:for-each select="keyword">
												<placekey>
													<xsl:value-of select="."/>
												</placekey>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</place>
							</xsl:for-each>
							<xsl:for-each select="stratKeys">
								<stratum>
									<xsl:choose>
										<xsl:when test="count (thesaName/resTitle) = 0"/>
										<xsl:when test="count (thesaName/resTitle) &gt; 1">
											<xsl:for-each select="(thesaName/resTitle)[1]">
												<stratkt>
													<xsl:value-of select="."/>
												</stratkt>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="thesaName/resTitle">
												<stratkt>
													<xsl:value-of select="."/>
												</stratkt>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="not(thesaName/resTitle)">
										<stratkt>None</stratkt>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="count (keyword) = 0"/>
										<xsl:otherwise>
											<xsl:for-each select="keyword">
												<stratkey>
													<xsl:value-of select="."/>
												</stratkey>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</stratum>
							</xsl:for-each>
							<xsl:for-each select="tempKeys">
								<temporal>
									<xsl:choose>
										<xsl:when test="count (thesaName/resTitle) = 0"/>
										<xsl:when test="count (thesaName/resTitle) &gt; 1">
											<xsl:for-each select="(thesaName/resTitle)[1]">
												<tempkt>
													<xsl:value-of select="."/>
												</tempkt>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:for-each select="thesaName/resTitle">
												<tempkt>
													<xsl:value-of select="."/>
												</tempkt>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="not(thesaName/resTitle)">
										<tempkt>None</tempkt>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="count (keyword) = 0"/>
										<xsl:otherwise>
											<xsl:for-each select="keyword">
												<tempkey>
													<xsl:value-of select="."/>
												</tempkey>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
								</temporal>
							</xsl:for-each>
							<xsl:if test="not(themeKeys or placeKeys or stratKeys or tempKeys) and (searchKeys)">
								<xsl:for-each select="searchKeys">
									<theme>
										<themekt>None</themekt>
										<xsl:choose>
											<xsl:when test="count (keyword) = 0"/>
											<xsl:otherwise>
												<xsl:for-each select="keyword">
													<themekey>
														<xsl:value-of select="."/>
													</themekey>
												</xsl:for-each>
											</xsl:otherwise>
										</xsl:choose>
									</theme>
								</xsl:for-each>
							</xsl:if>
						</keywords>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="accconst" select="substring-after(/metadata/dataIdInfo[1]/resConst//*[starts-with(.,'Access constraints: ')][1],'Access constraints: ')"/>
			<xsl:choose>
				<xsl:when test="($accconst != '')">
					<accconst>
						<xsl:value-of select="$accconst"/>
					</accconst>
				</xsl:when>
				<xsl:when test="(/metadata/dataIdInfo[1]/resConst//othConsts != '')">
					<accconst>
						<xsl:value-of select="/metadata/dataIdInfo[1]/resConst//othConsts[. != ''][1]"/>
					</accconst>
				</xsl:when>
				<xsl:otherwise>
					<accconst>None</accconst>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="/metadata/dataIdInfo[1]/resConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]">
					<xsl:choose>
						<xsl:when test="count (/metadata/dataIdInfo[1]/resConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(/metadata/dataIdInfo[1]/resConst/Consts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))])[1]">
								<useconst>
									<xsl:call-template name="fixHTML">
										<xsl:with-param name="text">
											<xsl:value-of select="."/>
										</xsl:with-param>
									</xsl:call-template>
								</useconst>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[(starts-with(., 'Use constraints: '))]">
					<xsl:variable name="useconst" select="substring-after(/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[starts-with(.,'Use constraints: ')][1],'Use constraints: ')"/>
					<xsl:if test="($useconst != '')">
						<useconst>
							<xsl:value-of select="$useconst"/>
						</useconst>
					</xsl:if>
				</xsl:when>
				<xsl:when test="/metadata/dataIdInfo[1]/resConst/LegConsts/othConsts[starts-with(., 'Use constraints: ')]">
					<xsl:variable name="useconst" select="substring-after(/metadata/dataIdInfo[1]/resConst/LegConsts/othConsts[starts-with(.,'Use constraints: ')][1],'Use constraints: ')"/>
					<xsl:if test="($useconst != '')">
						<useconst>
							<xsl:value-of select="$useconst"/>
						</useconst>
					</xsl:if>
				</xsl:when>
				<xsl:when test="/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]">
					<xsl:choose>
						<xsl:when test="count (/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))]) = 0"/>
						<xsl:otherwise>
							<xsl:for-each select="(/metadata/dataIdInfo[1]/resConst/LegConsts/useLimit[not(starts-with(., 'Distribution liability: ')) and not(starts-with(., 'Access constraints: '))])[1]">
								<useconst>
									<xsl:value-of select="."/>
								</useconst>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<useconst>None</useconst>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="/metadata/dataIdInfo[1]/idPoC">
				<ptcontac>
					<cntinfo>
						<xsl:call-template name="responsible-party"/>
					</cntinfo>
				</ptcontac>
			</xsl:for-each>
			<xsl:for-each select="/metadata/dataIdInfo[1]/idCitation/citRespParty[role/RoleCd/@value = 7]">
				<ptcontac>
					<cntinfo>
						<xsl:call-template name="responsible-party"/>
					</cntinfo>
				</ptcontac>
			</xsl:for-each>
    <!-- browse graphic file name element not required to be a URL for FGDC CSDGM, make sure internal content not shared -->
			<xsl:for-each select="/metadata/dataIdInfo[1]/graphOver[(bgFileName != '') and not(contains(bgFileName, '\\')) and not(contains(bgFileName, ':\')) and not(contains(bgFileName, 'ftp://')) and not(contains(bgFileName, 'Server='))]">
				<browse>
          <xsl:for-each select="(bgFileName[not(contains(., '\\')) and not(contains(., ':\')) and not(contains(., 'ftp://')) and not(contains(., 'Server='))])[1]">
            <browsen>
              <xsl:value-of select="."/>
            </browsen>
          </xsl:for-each>
					<xsl:choose>
						<xsl:when test="count (bgFileDesc) = 0"/>
						<xsl:when test="count (bgFileDesc) &gt; 1">
							<xsl:for-each select="(bgFileDesc)[1]">
								<browsed>
									<xsl:value-of select="."/>
								</browsed>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="bgFileDesc">
								<browsed>
									<xsl:value-of select="."/>
								</browsed>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="count (bgFileType) = 0"/>
						<xsl:when test="count (bgFileType) &gt; 1">
							<xsl:for-each select="(bgFileType)[1]">
								<browset>
									<xsl:value-of select="."/>
								</browset>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="bgFileType">
								<browset>
									<xsl:value-of select="."/>
								</browset>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</browse>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="count (/metadata/dataIdInfo[1]/idCredit) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/dataIdInfo[1]/idCredit)[1]">
						<datacred>
							<xsl:value-of select="."/>
						</datacred>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count (/metadata/dataIdInfo[1]/resConst/SecConsts) = 0"/>
				<xsl:otherwise>
					<xsl:for-each select="(/metadata/dataIdInfo[1]/resConst/SecConsts)[1]">
						<secinfo>
							<xsl:choose>
								<xsl:when test="count (classSys) = 0"/>
								<xsl:when test="count (classSys) &gt; 1">
									<xsl:for-each select="(classSys)[1]">
										<secsys>
											<xsl:value-of select="."/>
										</secsys>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="classSys">
										<secsys>
											<xsl:value-of select="."/>
										</secsys>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="count (class/ClasscationCd/@value) = 0"/>
								<xsl:when test="count (class/ClasscationCd/@value) &gt; 1">
									<xsl:for-each select="(class/ClasscationCd/@value)[1]">
										<secclass>
											<xsl:call-template name="security-info"/>
										</secclass>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="class/ClasscationCd/@value">
										<secclass>
											<xsl:call-template name="security-info"/>
										</secclass>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="(handDesc)[1]">
								<sechandl>
									<xsl:value-of select="."/>
								</sechandl>
							</xsl:for-each>
						</secinfo>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="(/metadata/dataIdInfo[1]/envirDesc)[1]">
				<native>
					<xsl:value-of select="."/>
				</native>
			</xsl:for-each>
			<xsl:for-each select="/metadata/dataIdInfo[1]/aggrInfo[(.//AscTypeCd/@value = '001')]/aggrDSName">
				<crossref>
					<citeinfo>
						<xsl:call-template name="citation"/>
					</citeinfo>
				</crossref>
			</xsl:for-each>
		</idinfo>
	</xsl:template>
	<xsl:template name="responsible-party">
		<xsl:choose>
			<xsl:when test="rpOrgName">
				<cntorgp>
					<xsl:choose>
						<xsl:when test="count (rpOrgName) = 0"/>
						<xsl:when test="count (rpOrgName) &gt; 1">
							<xsl:for-each select="(rpOrgName)[1]">
								<cntorg>
									<xsl:value-of select="."/>
								</cntorg>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="rpOrgName">
								<cntorg>
									<xsl:value-of select="."/>
								</cntorg>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="(rpIndName)[1]">
						<cntper>
							<xsl:value-of select="."/>
						</cntper>
					</xsl:for-each>
				</cntorgp>
				<xsl:for-each select="(rpPosName)[1]">
					<cntpos>
						<xsl:value-of select="."/>
					</cntpos>
				</xsl:for-each>
				<xsl:call-template name="responsible-party-2"/>
			</xsl:when>
			<xsl:when test="rpIndName">
				<cntperp>
					<xsl:choose>
						<xsl:when test="count (rpIndName) = 0"/>
						<xsl:when test="count (rpIndName) &gt; 1">
							<xsl:for-each select="(rpIndName)[1]">
								<cntper>
									<xsl:value-of select="."/>
								</cntper>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="rpIndName">
								<cntper>
									<xsl:value-of select="."/>
								</cntper>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="(rpOrgName)[1]">
						<cntorg>
							<xsl:value-of select="."/>
						</cntorg>
					</xsl:for-each>
				</cntperp>
				<xsl:for-each select="(rpPosName)[1]">
					<cntpos>
						<xsl:value-of select="."/>
					</cntpos>
				</xsl:for-each>
				<xsl:call-template name="responsible-party-2"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>no contact person or organization name available</xsl:comment>
				<xsl:for-each select="(rpPosName)[1]">
					<cntpos>
						<xsl:value-of select="."/>
					</cntpos>
				</xsl:for-each>
				<xsl:call-template name="responsible-party-2"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="responsible-party-2">
		<xsl:for-each select="(rpCntInfo/cntAddress[(@addressType != '') or (delPoint != '') or (city != '') or (adminArea != '') or (postCode != '') or (country != '')])[1]">
			<cntaddr>
				<xsl:choose>
					<xsl:when test="(@addressType = 'postal')">
						<addrtype>mailing</addrtype>
					</xsl:when>
					<xsl:when test="(@addressType = 'physical')">
						<addrtype>physical</addrtype>
					</xsl:when>
					<xsl:when test="(@addressType = 'both')">
						<addrtype>mailing and physical</addrtype>
					</xsl:when>
					<xsl:otherwise>
						<addrtype>unknown</addrtype>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="delPoint">
					<address>
						<xsl:value-of select="."/>
					</address>
				</xsl:for-each>
				<xsl:choose>
					<xsl:when test="count (city) = 0"/>
					<xsl:when test="count (city) &gt; 1">
						<xsl:for-each select="(city)[1]">
							<city>
								<xsl:value-of select="."/>
							</city>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="city">
							<city>
								<xsl:value-of select="."/>
							</city>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="count (adminArea) = 0"/>
					<xsl:when test="count (adminArea) &gt; 1">
						<xsl:for-each select="(adminArea)[1]">
							<state>
								<xsl:value-of select="."/>
							</state>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="adminArea">
							<state>
								<xsl:value-of select="."/>
							</state>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="count (postCode) = 0"/>
					<xsl:when test="count (postCode) &gt; 1">
						<xsl:for-each select="(postCode)[1]">
							<postal>
								<xsl:value-of select="."/>
							</postal>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="postCode">
							<postal>
								<xsl:value-of select="."/>
							</postal>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="(country)[1]">
					<country>
						<xsl:value-of select="."/>
					</country>
				</xsl:for-each>
			</cntaddr>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="count (rpCntInfo/cntPhone/voiceNum[not(@tddtty = 'True')]) = 0"/>
			<xsl:otherwise>
				<xsl:for-each select="rpCntInfo/cntPhone/voiceNum[not(@tddtty = 'True')]">
					<cntvoice>
						<xsl:value-of select="."/>
					</cntvoice>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count (rpCntInfo/cntPhone/voiceNum[(@tddtty = 'True')]) = 0"/>
			<xsl:otherwise>
				<xsl:for-each select="rpCntInfo/cntPhone/voiceNum[(@tddtty = 'True')]">
					<cnttdd>
						<xsl:value-of select="."/>
					</cnttdd>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="rpCntInfo/cntPhone/faxNum">
			<cntfax>
				<xsl:value-of select="."/>
			</cntfax>
		</xsl:for-each>
		<xsl:for-each select="rpCntInfo/cntAddress/eMailAdd">
			<cntemail>
				<xsl:value-of select="."/>
			</cntemail>
		</xsl:for-each>
		<xsl:for-each select="(rpCntInfo/cntHours)[1]">
			<hours>
				<xsl:value-of select="."/>
			</hours>
		</xsl:for-each>
		<xsl:for-each select="(rpCntInfo/cntInstr)[1]">
			<cntinst>
				<xsl:value-of select="."/>
			</cntinst>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="citation">
		<xsl:choose>
			<xsl:when test="count (citRespParty[role/RoleCd/@value = 6]) = 0"/>
			<xsl:otherwise>
				<xsl:for-each select="citRespParty[role/RoleCd/@value = 6]">
					<xsl:if test="(rpOrgName != '') or (rpIndName != '') or (rpPosName != '')">
						<origin>
							<xsl:variable name="goodnodes">
								<xsl:for-each select="rpOrgName | rpIndName | rpPosName">
									<xsl:if test=". != ''">
										<text>
											<xsl:value-of select="."/>
										</text>
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="function-available('msxsl:node-set')">
								<xsl:for-each select="msxsl:node-set($goodnodes)/text">
									<xsl:if test="position() &gt; 1">
										<xsl:text>, </xsl:text>
									</xsl:if>
									<xsl:value-of select="."/>
								</xsl:for-each>
							</xsl:if>
						</origin>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count (date/pubDate) = 0"/>
			<xsl:when test="count (date/pubDate) &gt; 1">
				<xsl:for-each select="(date/pubDate)[1]">
					<xsl:call-template name="dateTimeElements">
						<xsl:with-param name="dateEleName">pubdate</xsl:with-param>
						<xsl:with-param name="timeEleName">pubtime</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="date/pubDate">
					<xsl:call-template name="dateTimeElements">
						<xsl:with-param name="dateEleName">pubdate</xsl:with-param>
						<xsl:with-param name="timeEleName">pubtime</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count (resTitle) = 0"/>
			<xsl:when test="count (resTitle) &gt; 1">
				<xsl:for-each select="(resTitle)[1]">
					<title>
						<xsl:value-of select="."/>
					</title>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="resTitle">
					<title>
						<xsl:value-of select="."/>
					</title>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="(resEd)[1]">
			<edition>
				<xsl:value-of select="."/>
			</edition>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="(local-name(.) = 'idCitation')">
				<xsl:choose>
					<xsl:when test="(presForm/fgdcGeoform != '')">
						<xsl:choose>
							<xsl:when test="count (presForm/fgdcGeoform[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(presForm/fgdcGeoform[. != ''])[1]">
									<geoform>
										<xsl:value-of select="."/>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="(/metadata/contInfo/*/contentTyp/ContentTypCd/@value != '')">
						<xsl:choose>
							<xsl:when test="count (/metadata/contInfo/*/contentTyp/ContentTypCd/@value[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(/metadata/contInfo/*/contentTyp/ContentTypCd/@value[. != ''])[1]">
									<geoform>
										<xsl:choose>
											<xsl:when test=". = '001'">
												<xsl:text>remote-sensing image</xsl:text>
											</xsl:when>
											<xsl:when test=". = '002'">
												<xsl:text>raster digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '003'">
												<xsl:text>raster digital data</xsl:text>
											</xsl:when>
										</xsl:choose>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="(/metadata/dataIdInfo/spatRpType/SpatRepTypCd/@value != '')">
						<xsl:choose>
							<xsl:when test="count (/metadata/dataIdInfo/spatRpType/SpatRepTypCd/@value[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(/metadata/dataIdInfo/spatRpType/SpatRepTypCd/@value[. != ''])[1]">
									<geoform>
										<xsl:choose>
											<xsl:when test=". = '001'">
												<xsl:text>vector digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '002'">
												<xsl:text>raster digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '003'">
												<xsl:text>tabular digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '004'">
												<xsl:text>model</xsl:text>
											</xsl:when>
											<xsl:when test=". = '005'">
												<xsl:text>video</xsl:text>
											</xsl:when>
										</xsl:choose>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="count (presForm/PresFormCd/@value[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(presForm/PresFormCd/@value[. != ''])[1]">
									<geoform>
										<xsl:choose>
											<xsl:when test=". = '001'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '002'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '003'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '004'">
												<xsl:text>imageHardcopy</xsl:text>
											</xsl:when>
											<xsl:when test=". = '005'">
												<xsl:text>map</xsl:text>
											</xsl:when>
											<xsl:when test=". = '006'">
												<xsl:text>map</xsl:text>
											</xsl:when>
											<xsl:when test=". = '007'">
												<xsl:text>model</xsl:text>
											</xsl:when>
											<xsl:when test=". = '008'">
												<xsl:text>model</xsl:text>
											</xsl:when>
											<xsl:when test=". = '009'">
												<xsl:text>profile</xsl:text>
											</xsl:when>
											<xsl:when test=". = '010'">
												<xsl:text>profile</xsl:text>
											</xsl:when>
											<xsl:when test=". = '011'">
												<xsl:text>tabular digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '012'">
												<xsl:text>tableHardcopy</xsl:text>
											</xsl:when>
											<xsl:when test=". = '013'">
												<xsl:text>video</xsl:text>
											</xsl:when>
											<xsl:when test=". = '014'">
												<xsl:text>video</xsl:text>
											</xsl:when>
											<xsl:when test=". = '015'">
												<xsl:text>audio</xsl:text>
											</xsl:when>
											<xsl:when test=". = '016'">
												<xsl:text>audio</xsl:text>
											</xsl:when>
											<xsl:when test=". = '017'">
												<xsl:text>multimedia presentation</xsl:text>
											</xsl:when>
											<xsl:when test=". = '018'">
												<xsl:text>multimedia presentation</xsl:text>
											</xsl:when>
											<xsl:when test=". = '019'">
												<xsl:text>diagram</xsl:text>
											</xsl:when>
											<xsl:when test=". = '020'">
												<xsl:text>diagram</xsl:text>
											</xsl:when>
										</xsl:choose>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="(presForm/fgdcGeoform != '')">
						<xsl:choose>
							<xsl:when test="count (presForm/fgdcGeoform[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(presForm/fgdcGeoform[. != ''])[1]">
									<geoform>
										<xsl:value-of select="."/>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="count (presForm/PresFormCd/@value[. != '']) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(presForm/PresFormCd/@value[. != ''])[1]">
									<geoform>
										<xsl:choose>
											<xsl:when test=". = '001'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '002'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '003'">
												<xsl:text>document</xsl:text>
											</xsl:when>
											<xsl:when test=". = '004'">
												<xsl:text>imageHardcopy</xsl:text>
											</xsl:when>
											<xsl:when test=". = '005'">
												<xsl:text>map</xsl:text>
											</xsl:when>
											<xsl:when test=". = '006'">
												<xsl:text>map</xsl:text>
											</xsl:when>
											<xsl:when test=". = '007'">
												<xsl:text>model</xsl:text>
											</xsl:when>
											<xsl:when test=". = '008'">
												<xsl:text>model</xsl:text>
											</xsl:when>
											<xsl:when test=". = '009'">
												<xsl:text>profile</xsl:text>
											</xsl:when>
											<xsl:when test=". = '010'">
												<xsl:text>profile</xsl:text>
											</xsl:when>
											<xsl:when test=". = '011'">
												<xsl:text>tabular digital data</xsl:text>
											</xsl:when>
											<xsl:when test=". = '012'">
												<xsl:text>tableHardcopy</xsl:text>
											</xsl:when>
											<xsl:when test=". = '013'">
												<xsl:text>video</xsl:text>
											</xsl:when>
											<xsl:when test=". = '014'">
												<xsl:text>video</xsl:text>
											</xsl:when>
											<xsl:when test=". = '015'">
												<xsl:text>audio</xsl:text>
											</xsl:when>
											<xsl:when test=". = '016'">
												<xsl:text>audio</xsl:text>
											</xsl:when>
											<xsl:when test=". = '017'">
												<xsl:text>multimedia presentation</xsl:text>
											</xsl:when>
											<xsl:when test=". = '018'">
												<xsl:text>multimedia presentation</xsl:text>
											</xsl:when>
											<xsl:when test=". = '019'">
												<xsl:text>diagram</xsl:text>
											</xsl:when>
											<xsl:when test=". = '020'">
												<xsl:text>diagram</xsl:text>
											</xsl:when>
										</xsl:choose>
									</geoform>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="(datasetSeries)[1]">
			<serinfo>
				<xsl:for-each select="(seriesName)[1]">
					<sername>
						<xsl:value-of select="."/>
					</sername>
				</xsl:for-each>
				<xsl:for-each select="(issId)[1]">
					<issue>
						<xsl:value-of select="."/>
					</issue>
				</xsl:for-each>
			</serinfo>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="count (citRespParty[role/RoleCd/@value = 10]) = 0"/>
			<xsl:otherwise>
				<xsl:for-each select="citRespParty[role/RoleCd/@value = 10]">
					<pubinfo>
						<xsl:choose>
							<xsl:when test="count (rpCntInfo/cntAddress[delPoint | city | adminArea | postCode | country]) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(rpCntInfo/cntAddress[delPoint | city | adminArea | postCode | country])[1]">
									<pubplace>
										<xsl:variable name="goodnodes">
											<xsl:for-each select="delPoint | city | adminArea | postCode | country">
												<xsl:if test=". != ''">
													<text>
														<xsl:value-of select="."/>
													</text>
												</xsl:if>
											</xsl:for-each>
										</xsl:variable>
										<xsl:if test="function-available('msxsl:node-set')">
											<xsl:for-each select="msxsl:node-set($goodnodes)/text">
												<xsl:if test="position() &gt; 1">
													<xsl:text>, </xsl:text>
												</xsl:if>
												<xsl:value-of select="."/>
											</xsl:for-each>
										</xsl:if>
									</pubplace>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="count (rpOrgName | rpIndName | rpPosName) = 0"/>
							<xsl:otherwise>
								<xsl:for-each select="(rpOrgName | rpIndName | rpPosName)[1]">
									<publish>
										<xsl:value-of select="."/>
									</publish>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</pubinfo>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:for-each select="(otherCitDet)[1]">
			<othercit>
				<xsl:value-of select="."/>
			</othercit>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="(local-name(.) = 'idCitation')">
				<xsl:for-each select="/metadata/distInfo/distTranOps/onLineSrc/linkage[(starts-with(.,'http://') or starts-with(.,'https://') or starts-with(.,'HTTP://') or starts-with(.,'HTTPS://'))]">
					<onlink>
						<xsl:value-of select="."/>
					</onlink>
				</xsl:for-each>
				<xsl:choose>
					<xsl:when test="count (../aggrInfo[(.//AscTypeCd/@value = '002')]/aggrDSName) = 0"/>
					<xsl:otherwise>
						<xsl:for-each select="(../aggrInfo[(.//AscTypeCd/@value = '002')]/aggrDSName)[1]">
							<lworkcit>
								<citeinfo>
									<xsl:call-template name="citation"/>
								</citeinfo>
							</lworkcit>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="citOnlineRes/linkage[(starts-with(.,'http://') or starts-with(.,'https://') or starts-with(.,'HTTP://') or starts-with(.,'HTTPS://'))]">
					<onlink>
						<xsl:value-of select="."/>
					</onlink>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="dateTimeElements">
		<xsl:param name="dateEleName"/>
		<xsl:param name="timeEleName"/>
		<xsl:choose>
			<xsl:when test="(contains(., 'T') and contains(., '-') and contains(., ':'))">
				<xsl:variable name="date" select="translate(substring-before(.,'T'),'-','')"/>
				<xsl:variable name="time" select="translate(substring-after(.,'T'),':','')"/>
				<xsl:choose>
					<xsl:when test="(function-available('msxsl:utc'))">
						<xsl:choose>
							<xsl:when test="(msxsl:utc(.) != '')">
								<xsl:choose>
									<xsl:when test="(number($date) &gt; 0)">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="$date"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="($dateEleName = 'enddate') and (@date = 'now')">
												<xsl:element name="{$dateEleName}">present</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'procdate') and (@date = 'inapplicable')">
												<xsl:element name="{$dateEleName}">not complete</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'pubdate') and (@date = 'inapplicable')">
												<xsl:element name="{$dateEleName}">unpublished material</xsl:element>
											</xsl:when>
											<xsl:when test="(@date != '')">
												<xsl:element name="{$dateEleName}">
													<xsl:value-of select="@date"/>
												</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'enddate') and (not(@date) or (@date = ''))">
												<xsl:element name="{$dateEleName}">unknown</xsl:element>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="(number($time) &gt; 0)">
										<xsl:element name="{$timeEleName}">
											<xsl:value-of select="$time"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="(@time != '')">
										<xsl:element name="{$timeEleName}">
											<xsl:value-of select="@time"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="{$dateEleName}">unknown</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="(number($date) &gt; 0)">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="$date"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="($dateEleName = 'enddate') and (@date = 'now')">
										<xsl:element name="{$dateEleName}">present</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'procdate') and (@date = 'inapplicable')">
										<xsl:element name="{$dateEleName}">not complete</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'pubdate') and (@date = 'inapplicable')">
										<xsl:element name="{$dateEleName}">unpublished material</xsl:element>
									</xsl:when>
									<xsl:when test="(@date != '')">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="@date"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'enddate') and (not(@date) or (@date = ''))">
										<xsl:element name="{$dateEleName}">unknown</xsl:element>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="(number($time) &gt; 0)">
								<xsl:element name="{$timeEleName}">
									<xsl:value-of select="$time"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="(@time != '')">
								<xsl:element name="{$timeEleName}">
									<xsl:value-of select="@time"/>
								</xsl:element>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(contains(., '-') and not(contains(., 'T')) and not(contains(., ':')))">
				<xsl:variable name="date" select="translate(.,'-','')"/>
				<xsl:choose>
					<xsl:when test="(function-available('msxsl:utc'))">
						<xsl:choose>
							<xsl:when test="(msxsl:utc(.) != '')">
								<xsl:choose>
									<xsl:when test="(number($date) &gt; 0)">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="$date"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="($dateEleName = 'enddate') and (@date = 'now')">
												<xsl:element name="{$dateEleName}">present</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'procdate') and (@date = 'inapplicable')">
												<xsl:element name="{$dateEleName}">not complete</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'pubdate') and (@date = 'inapplicable')">
												<xsl:element name="{$dateEleName}">unpublished material</xsl:element>
											</xsl:when>
											<xsl:when test="(@date != '')">
												<xsl:element name="{$dateEleName}">
													<xsl:value-of select="@date"/>
												</xsl:element>
											</xsl:when>
											<xsl:when test="($dateEleName = 'enddate') and (not(@date) or (@date = ''))">
												<xsl:element name="{$dateEleName}">unknown</xsl:element>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="(@time != '')">
									<xsl:element name="{$timeEleName}">
										<xsl:value-of select="@time"/>
									</xsl:element>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="{$dateEleName}">unknown</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="(number($date) &gt; 0)">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="$date"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="($dateEleName = 'enddate') and (@date = 'now')">
										<xsl:element name="{$dateEleName}">present</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'procdate') and (@date = 'inapplicable')">
										<xsl:element name="{$dateEleName}">not complete</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'pubdate') and (@date = 'inapplicable')">
										<xsl:element name="{$dateEleName}">unpublished material</xsl:element>
									</xsl:when>
									<xsl:when test="(@date != '')">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="@date"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="($dateEleName = 'enddate') and (not(@date) or (@date = ''))">
										<xsl:element name="{$dateEleName}">unknown</xsl:element>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="(@time != '')">
							<xsl:element name="{$timeEleName}">
								<xsl:value-of select="@time"/>
							</xsl:element>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="number(.)">
				<xsl:variable name="date">
					<xsl:choose>
						<xsl:when test="(string-length(.) &gt; 8)">
							<xsl:value-of select="substring(.,1,8)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="(number($date) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="$date"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="(@time != '')">
					<xsl:element name="{$timeEleName}">
						<xsl:value-of select="@time"/>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains(., ' ') and contains(., '/')">
				<xsl:variable name="date" select="substring-before(.,' ')"/>
				<xsl:variable name="t1" select="substring-before(substring-after(.,' '), ' ')"/>
				<xsl:variable name="ampm" select="substring-after(substring-after(.,' '), ' ')"/>
				<xsl:variable name="y1" select="substring-after(substring-after($date,'/'),'/')"/>
				<xsl:variable name="m1" select="substring-before($date,'/')"/>
				<xsl:variable name="d1" select="substring-before(substring-after($date,'/'),'/')"/>
				<xsl:variable name="month">
					<xsl:choose>
						<xsl:when test="($m1 &lt; 10)">
							<xsl:value-of select="concat('0',$m1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$m1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="day">
					<xsl:choose>
						<xsl:when test="($d1 &lt; 10)">
							<xsl:value-of select="concat('0',$d1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$d1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="time">
					<xsl:choose>
						<xsl:when test="($ampm = 'AM') and ($t1 = '12:00:00')">00:00:00</xsl:when>
						<xsl:when test="($ampm = 'PM') or ($ampm = 'pm')">
							<xsl:variable name="hours" select="substring-before($t1,':')"/>
							<xsl:variable name="rest" select="substring-after($t1,':')"/>
							<xsl:value-of select="concat($hours + 12,':',$rest)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$t1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="(number(concat($y1,$month,$day)) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="concat($y1,$month,$day)"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="(number(translate($time,':','')) &gt; 0)">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="translate($time,':','')"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@time != '')">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="@time"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains(., 'T') and contains(., '/') and not(contains(., '-')) and not(contains(., ':') and (number(substring-before(.,'T')) &gt; 0) and (number(substring-after(substring-before(.,'/'),'T')) &gt; 0))">
				<xsl:variable name="dateTime" select="substring-before(.,'/')"/>
				<xsl:variable name="date">substring-before($dateTime,'T')</xsl:variable>
				<xsl:variable name="time">after($dateTime,'T')</xsl:variable>
				<xsl:choose>
					<xsl:when test="(number($date) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="$date"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="(number($time) &gt; 0)">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="$time"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@time != '')">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="@time"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(contains(., 'T')) and not(contains(., '-')) and not(contains(., ':') and (number(substring-before(.,'T')) &gt; 0) and (number(substring-after(.,'T')) &gt; 0))">
				<xsl:choose>
					<xsl:when test="(number(substring-before(.,'T')) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="substring-before(.,'T')"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="(number(substring-after(.,'T')) &gt; 0)">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="substring-after(.,'T')"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@time != '')">
						<xsl:element name="{$timeEleName}">
							<xsl:value-of select="@time"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="($dateEleName = 'enddate') and (@date = 'now')">
				<xsl:element name="{$dateEleName}">present</xsl:element>
			</xsl:when>
			<xsl:when test="($dateEleName = 'procdate') and (@date = 'inapplicable')">
				<xsl:element name="{$dateEleName}">not complete</xsl:element>
			</xsl:when>
			<xsl:when test="($dateEleName = 'pubdate') and (@date = 'inapplicable')">
				<xsl:element name="{$dateEleName}">unpublished material</xsl:element>
			</xsl:when>
			<xsl:when test="(@date != '')">
				<xsl:element name="{$dateEleName}">
					<xsl:value-of select="@date"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="($dateEleName = 'enddate') and (not(@date) or (@date = ''))">
				<xsl:element name="{$dateEleName}">unknown</xsl:element>
			</xsl:when>
			<xsl:when test="(. != '')">
				<xsl:element name="{$dateEleName}">unknown</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="dateOnlyElements">
		<xsl:param name="dateEleName"/>
		<xsl:choose>
			<xsl:when test="(contains(., 'T') and contains(., '-') and contains(., ':'))">
				<xsl:variable name="date" select="translate(substring-before(.,'T'),'-','')"/>
				<xsl:choose>
					<xsl:when test="(function-available('msxsl:utc'))">
						<xsl:choose>
							<xsl:when test="(msxsl:utc(.) != '')">
								<xsl:choose>
									<xsl:when test="(number($date) &gt; 0)">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="$date"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="(@date != '')">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="@date"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="{$dateEleName}">unknown</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="(number($date) &gt; 0)">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="$date"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="(@date != '')">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="@date"/>
								</xsl:element>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(contains(., '-') and not(contains(., 'T')) and not(contains(., ':')))">
				<xsl:variable name="date" select="translate(.,'-','')"/>
				<xsl:choose>
					<xsl:when test="(function-available('msxsl:utc'))">
						<xsl:choose>
							<xsl:when test="(msxsl:utc(.) != '')">
								<xsl:choose>
									<xsl:when test="(number($date) &gt; 0)">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="$date"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="(@date != '')">
										<xsl:element name="{$dateEleName}">
											<xsl:value-of select="@date"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="{$dateEleName}">unknown</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="(number($date) &gt; 0)">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="$date"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="(@date != '')">
								<xsl:element name="{$dateEleName}">
									<xsl:value-of select="@date"/>
								</xsl:element>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="number(.)">
				<xsl:variable name="date">
					<xsl:choose>
						<xsl:when test="(string-length(.) &gt; 8)">
							<xsl:value-of select="substring(.,1,8)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="(number($date) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="$date"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains(., ' ') and contains(., '/')">
				<xsl:variable name="date" select="substring-before(.,' ')"/>
				<xsl:variable name="y1" select="substring-after(substring-after($date,'/'),'/')"/>
				<xsl:variable name="m1" select="substring-before($date,'/')"/>
				<xsl:variable name="d1" select="substring-before(substring-after($date,'/'),'/')"/>
				<xsl:variable name="month">
					<xsl:choose>
						<xsl:when test="($m1 &lt; 10)">
							<xsl:value-of select="concat('0',$m1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$m1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="day">
					<xsl:choose>
						<xsl:when test="($d1 &lt; 10)">
							<xsl:value-of select="concat('0',$d1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$d1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="(number(concat($y1,$month,$day)) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="concat($y1,$month,$day)"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(contains(., 'T')) and not(contains(., '-')) and not(contains(., ':') and (number(substring-before(.,'T')) &gt; 0) and (number(substring-after(.,'T')) &gt; 0))">
				<xsl:choose>
					<xsl:when test="(number(substring-before(.,'T')) &gt; 0)">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="substring-before(.,'T')"/>
						</xsl:element>
					</xsl:when>
					<xsl:when test="(@date != '')">
						<xsl:element name="{$dateEleName}">
							<xsl:value-of select="@date"/>
						</xsl:element>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(@date != '')">
				<xsl:element name="{$dateEleName}">
					<xsl:value-of select="@date"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="(. != '')">
				<xsl:element name="{$dateEleName}">unknown</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="eainfo" mode="recurse-copy-IDAU51C" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="detailed" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="overview" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="detailed" mode="recurse-copy-IDAU51C" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="enttyp" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attr" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="enttyp" mode="recurse-copy-IDAU51C" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="enttypl" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="enttypd" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="enttypds" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="attr" mode="recurse-copy-IDAU51C" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="attrlabl" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attrdef" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attrdefs" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attrdomv" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="begdatea" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="enddatea" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attrvai" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="attrmfrq" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="overview" mode="recurse-copy-IDAU51C" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="eaover" mode="recurse-copy-IDAU51C"/>
			<xsl:apply-templates select="eadetcit" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|*" mode="recurse-copy-IDAU51C" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="@*|*|text()" mode="recurse-copy-IDAU51C"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@* | subtype | relinfo | enttypt | enttypc | attalias | attrtype | attwidth | atprecis | attscale | atoutwid | atnumdec | atindex | rdommean | rdomstdv" mode="recurse-copy-IDAU51C" priority="2"/>
	<xsl:template name="fixHTML">
		<xsl:param name="text"/>
		<xsl:variable name="lessThan">&lt;</xsl:variable>
		<xsl:variable name="greaterThan">&gt;</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $lessThan)">
				<xsl:variable name="before" select="substring-before($text, $lessThan)"/>
				<xsl:variable name="middle" select="substring-after($text, $lessThan)"/>
				<xsl:variable name="after" select="substring-after($middle, $greaterThan)"/>
				<xsl:choose>
					<xsl:when test="$middle">
						<xsl:value-of select="$before"/>
						<xsl:text/>
						<xsl:call-template name="fixHTML">
							<xsl:with-param name="text" select="$after"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$text"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
