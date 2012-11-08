<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="#all">

	<xsl:variable name="myoceanSlidingWindowFlag">delta time</xsl:variable>

	<!-- main template - the way into processing iso19139.myocean -->
	<xsl:template name="metadata-iso19139.myoceanview-simple">
		<xsl:call-template name="metadata-iso19139view-simple"/>
	</xsl:template>

	<xsl:template mode="iso19139.myocean" match="*|@*"/> 
<!--	<xsl:template mode="iso19139.myocean" match="gmd:descriptiveKeywords" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="$edit"/>
			<xsl:with-param name="content">
				Create custom control for this element
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>-->
	

	<xsl:template mode="iso19139.myocean" match="gmd:contact|gmd:pointOfContact|gmd:citedResponsibleParty|gmd:distributorContact" priority="99">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		
		<xsl:for-each select="gmd:CI_ResponsibleParty">
			<xsl:apply-templates mode="elementEP" select="gmd:organisationName">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="elementEP" select="gmd:individualName|
				gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress
				">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit"   select="$edit"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="view-with-header-iso19139.myocean">
		<xsl:param name="tabs"/>

		<xsl:call-template name="view-with-header-iso19139">
			<xsl:with-param name="tabs" select="$tabs"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="metadata-iso19139.myocean" match="metadata-iso19139.myocean">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded"/>

		<!-- process in profile mode first -->
		<xsl:variable name="profileElements">
			<xsl:apply-templates mode="iso19139.myocean" select=".">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit" select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded"/>
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:choose>
			<!-- if we got a match in profile mode then show it -->
			<xsl:when test="count($profileElements/*)>0">
				<xsl:copy-of select="$profileElements"/>
			</xsl:when>
			<!-- otherwise process in base iso19139 mode -->
			<xsl:otherwise> 
				<xsl:apply-templates mode="iso19139" select="." >
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="embedded" select="$embedded" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template name="iso19139.myoceanCompleteTab">
		<xsl:param name="tabLink"/>
		<xsl:param name="schema"/>
		<xsl:call-template name="iso19139CompleteTab">
			<xsl:with-param name="tabLink" select="$tabLink"/>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
		
		<xsl:call-template name="mainTab">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/myocean.simpleTab"/>
			<xsl:with-param name="default">myocean.simple</xsl:with-param>
			<xsl:with-param name="menu">
				<item label="myocean.simpleTab">myocean.simple</item>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="mainTab">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/myoceanTab"/>
			<xsl:with-param name="default">myocean</xsl:with-param>
			<xsl:with-param name="menu">
				<item label="myoceanTab">myocean</item>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>




	<!--
    Redirection template for profil fra in order to process 
    extraTabs.
  -->
	<xsl:template mode="iso19139.myocean" match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"
		priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="embedded"/>

		
		<xsl:variable name="dataset"
			select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=''"/>
		<xsl:choose>

			<!-- metadata tab -->
			<xsl:when test="$currTab='metadata'">
				<xsl:call-template name="iso19139Metadata">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:call-template>
			</xsl:when>

			<!-- identification tab -->
			<xsl:when test="$currTab='identification'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- maintenance tab -->
			<xsl:when test="$currTab='maintenance'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- constraints tab -->
			<xsl:when test="$currTab='constraints'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- spatial tab -->
			<xsl:when test="$currTab='spatial'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- refSys tab -->
			<xsl:when test="$currTab='refSys'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- distribution tab -->
			<xsl:when test="$currTab='distribution'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- embedded distribution tab -->
			<xsl:when test="$currTab='distribution2'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- dataQuality tab -->
			<xsl:when test="$currTab='dataQuality'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- appSchInfo tab -->
			<xsl:when test="$currTab='appSchInfo'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- porCatInfo tab -->
			<xsl:when test="$currTab='porCatInfo'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- contentInfo tab -->
			<xsl:when test="$currTab='contentInfo'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- extensionInfo tab -->
			<xsl:when test="$currTab='extensionInfo'">
				<xsl:apply-templates mode="elementEP"
					select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- ISOMinimum tab -->
			<xsl:when test="$currTab='ISOMinimum'">
				<xsl:call-template name="isotabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
					<xsl:with-param name="core" select="false()"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ISOCore tab -->
			<xsl:when test="$currTab='ISOCore'">
				<xsl:call-template name="isotabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
					<xsl:with-param name="core" select="true()"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ISOAll tab -->
			<xsl:when test="$currTab='ISOAll'">
				<xsl:call-template name="iso19139Complete">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:call-template>
			</xsl:when>

			<!-- INSPIRE tab -->
			<xsl:when test="$currTab='inspire'">
				<xsl:call-template name="inspiretabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$currTab='myocean.simple'">
				<xsl:call-template name="myocean.simple">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$currTab='myocean'">
				<xsl:call-template name="myocean">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:call-template>
			</xsl:when>
			<!-- default -->
			<xsl:otherwise>
				<xsl:call-template name="iso19139Simple">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="flat"
						select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Simple view mode - apply to upstream products
	
	The most simple way to describe a product is to use the editing for dummy form.
	This form is dedicated to upstream products.
	-->
	<xsl:template name="myocean.simple">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="dataset"/>
		<xsl:param name="core"/>
		
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="''"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/metadataInfoTitle)"/>
			<xsl:with-param name="content">
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
																gmd:CI_Citation/gmd:title">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
																gmd:CI_Citation/gmd:alternateTitle">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
																gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
																gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-->
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/creationDate"/>
						<xsl:with-param name="text">
							<xsl:variable name="ref" select="gmd:date/gco:Date/geonet:element/@ref|gmd:date/gco:DateTime/geonet:element/@ref"/>
							<xsl:variable name="format">
								<xsl:choose>
									<xsl:when test="gmd:date/gco:Date"><xsl:text>%Y-%m-%d</xsl:text></xsl:when>
									<xsl:otherwise><xsl:text>%Y-%m-%dT%H:%M:00</xsl:text></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:call-template name="calendar">
								<xsl:with-param name="ref" select="$ref"/>
								<xsl:with-param name="date" select="gmd:date"/>
								<xsl:with-param name="format" select="$format"/>
							</xsl:call-template>
							
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
																gmd:CI_Citation/gmd:editionDate">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	

	<!-- The main view -->
	<xsl:template name="myocean">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="dataset"/>
		<xsl:param name="core"/>
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/metadataInfoTitle"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/metadataInfoTitle)"/>
			<xsl:with-param name="content">
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:title">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:fileIdentifier">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:alternateTitle">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				
				
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
                                                                gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
                    <xsl:with-param name="schema" select="$schema"/>
                    <xsl:with-param name="edit"   select="$edit"/>
                </xsl:apply-templates>-->
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/creationDate"/>
						<xsl:with-param name="text">
							<xsl:variable name="ref" select="gmd:date/gco:Date/geonet:element/@ref|gmd:date/gco:DateTime/geonet:element/@ref"/>
							<xsl:variable name="format">
								<xsl:choose>
									<xsl:when test="gmd:date/gco:Date"><xsl:text>%Y-%m-%d</xsl:text></xsl:when>
									<xsl:otherwise><xsl:text>%Y-%m-%dT%H:%M:00</xsl:text></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:call-template name="calendar">
								<xsl:with-param name="ref" select="$ref"/>
								<xsl:with-param name="date" select="gmd:date"/>
								<xsl:with-param name="format" select="$format"/>
							</xsl:call-template>
							
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:editionDate">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/
					gmd:CI_Citation/gmd:edition">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:call-template>
		
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/quicklookAndKeywords"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/quicklookAndKeywords)"/>
			<xsl:with-param name="content">
				<!--
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				-->
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString='MyOcean product type']/gmd:MD_Keywords">
					<xsl:variable name="productTypeKeywords" select="."/>
					
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/missionType"/>
						<xsl:with-param name="text">
							<xsl:call-template name="snippet-editor">
								<xsl:with-param name="elementRef" select="$productTypeKeywords/../geonet:element/@ref"/>
								<xsl:with-param name="widgetMode" select="'combo'"/>
								<xsl:with-param name="thesaurusId" select="'local.discipline.myocean.product.origin'"/>
								<xsl:with-param name="listOfKeywords" select="replace(replace(string-join($productTypeKeywords/gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
								<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
								<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				
				<xsl:apply-templates mode="elementEP" select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureTypes/gco:LocalName">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='areaOfBenefit']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-->
				
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='areaOfBenefit']/gmd:MD_Keywords">
					<xsl:variable name="areaOfBenefitKeywords" select="."/>
					
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/areaOfBenefit"/>
						<xsl:with-param name="text">
							<xsl:call-template name="snippet-editor">
								<xsl:with-param name="elementRef" select="$areaOfBenefitKeywords/../geonet:element/@ref"/>
								<xsl:with-param name="widgetMode" select="'multiplelist'"/>
								<xsl:with-param name="thesaurusId" select="'local.areaOfBenefit.myocean.area.of.benefit'"/>
								<xsl:with-param name="listOfKeywords" select="replace(replace(string-join($areaOfBenefitKeywords/gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
								<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
								<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='parametersGroup']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
				-->
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='parametersGroup']/gmd:MD_Keywords">
					<xsl:variable name="oceanVariablesKeywords" select="."/>
					
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/oceanVariables"/>
						<xsl:with-param name="text">
							<xsl:call-template name="snippet-editor">
								<xsl:with-param name="elementRef" select="$oceanVariablesKeywords/../geonet:element/@ref"/>
								<xsl:with-param name="widgetMode" select="'multiplelist'"/>
								<xsl:with-param name="thesaurusId" select="'local.parametersGroup.myocean.ocean.variables'"/>
								<xsl:with-param name="listOfKeywords" select="replace(replace(string-join($oceanVariablesKeywords/gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
								<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
								<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='parameter']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-->
				
				
				<!-- Force gmd:credit to be a number -->
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-->
				
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit">
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/labels/element[@name='gmd:credit']/label"/>
						<xsl:with-param name="text">
							<input type="number" class="md" 
								name="_{gco:CharacterString/geonet:element/@ref}" 
								id="_{gco:CharacterString/geonet:element/@ref}"  
								onkeyup="validateNumber(this,true,true);"
								onchange="validateNumber(this,true,true);"
								value="{gco:CharacterString}" size="30"/>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
		
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/spatioTemporalCoverage"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/spatioTemporalCoverage)"/>
			<xsl:with-param name="content">
				
				
				<xsl:call-template name="complexElementGuiWrapper">
					<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/geoCoverage"/>
					<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/geoCoverage)"/>
					<xsl:with-param name="content">
						
						<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/
							gmd:spatialResolution/gmd:MD_Resolution/gmd:distance">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates mode="iso19139" select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/
							gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						
						
						<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
							[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='my-ocean-areas']/gmd:MD_Keywords">
							<xsl:variable name="refAreaKeywords" select="."/>
							
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema"  select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
								<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/refArea"/>
								<xsl:with-param name="text">
									<xsl:call-template name="snippet-editor">
										<xsl:with-param name="elementRef" select="$refAreaKeywords/../geonet:element/@ref"/>
										<xsl:with-param name="widgetMode" select="'multiplelist'"/>
										<xsl:with-param name="thesaurusId" select="'local.my-ocean-areas.myocean.geographical-area'"/>
										<xsl:with-param name="listOfKeywords" select="replace(replace(string-join($refAreaKeywords/gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
										<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
										<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:for-each>
						<!--<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/
							gmd:MD_Identifier/gmd:code">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>-->
						
					</xsl:with-param>
				</xsl:call-template>
				
				<xsl:call-template name="complexElementGuiWrapper">
					<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/verticalCoverage"/>
					<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/verticalCoverage)"/>
					<xsl:with-param name="content">
						
						<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent/gmd:verticalElement/gmd:EX_VerticalExtent/gmd:minimumValue|gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent/gmd:verticalElement/gmd:EX_VerticalExtent/gmd:maximumValue">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						
						<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
							[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='verticalLevels']">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>-->
						
						<!--<xsl:variable name="verticalKeywords" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
							[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='verticalLevels']/gmd:MD_Keywords"/>
						
						<xsl:apply-templates mode="simpleElement" select=".">
							<xsl:with-param name="schema"  select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
							<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/oceanVariables"/>
							<xsl:with-param name="text">
								<xsl:call-template name="snippet-editor">
									<xsl:with-param name="elementRef" select="$verticalKeywords/../geonet:element/@ref"/>
									<xsl:with-param name="widgetMode" select="'multiplelist'"/>
									<xsl:with-param name="thesaurusId" select="'local.stratum.myocean.vertical.coverage'"/>
									<xsl:with-param name="listOfKeywords" select="replace(replace(string-join($verticalKeywords/gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
									<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
									<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:apply-templates>-->
						
						<xsl:for-each select="gmd:contentInfo/gmd:MD_CoverageDescription/gmd:dimension[2]/
							gmd:MD_RangeDimension/gmd:descriptor">
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema"  select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
								<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]//strings/nbVerticalLevels"/>
								<xsl:with-param name="text">
									<input type="number" class="md" 
										name="_{gco:CharacterString/geonet:element/@ref}" 
										id="_{gco:CharacterString/geonet:element/@ref}"  
										onkeyup="validateNumber(this,true,true);"
										onchange="validateNumber(this,true,true);"
										value="{gco:CharacterString}" size="30"/>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:for-each>
						
						<!--<xsl:for-each select="gmd:contentInfo/gmd:MD_CoverageDescription/gmd:dimension[2]/
							gmd:MD_RangeDimension/gmd:descriptor/gco:CharacterString">
							<xsl:variable name="text">
								<xsl:call-template name="getElementText">
									<xsl:with-param name="edit"   select="$edit"/>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema"   select="$schema"/>
								<xsl:with-param name="edit"     select="$edit"/>
								<xsl:with-param name="title"     select="/root/gui/schemas/*[name()=$schema]/strings/nbVerticalLevels"/>
								<xsl:with-param name="text"     select="$text"/>
							</xsl:apply-templates>
						</xsl:for-each>-->
					</xsl:with-param>
				</xsl:call-template>
				
				<xsl:call-template name="complexElementGuiWrapper">
					<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/temporalCoverage"/>
					<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/temporalCoverage)"/>
					<xsl:with-param name="content">
						<!-- In edit mode, a gml:TimePeriodTypeCHOICE_ELEMENT2 is added between TimePeriod and its children -->
						<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent[gmd:description/gco:CharacterString=$myoceanSlidingWindowFlag]/gmd:temporalElement/
							gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:begin/*">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
							<xsl:with-param name="title"  select="/root/gui/schemas/*[name()=$schema]/strings/startDate"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
							gmd:EX_Extent[gmd:description/gco:CharacterString=$myoceanSlidingWindowFlag]/gmd:temporalElement/
							gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:end/*">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
							<xsl:with-param name="title"  select="/root/gui/schemas/*[name()=$schema]/strings/endDate"/>
						</xsl:apply-templates>
						
						<!--
							Old field use for temporal resolution now stored in range dimension.
							UFO is taking care of reporting the info in that field too.
							<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						-->
						
						<xsl:for-each select="gmd:contentInfo/gmd:MD_CoverageDescription/gmd:dimension[1]/
							gmd:MD_RangeDimension/gmd:descriptor/gco:CharacterString">
							<xsl:variable name="text">
								<xsl:call-template name="getElementText">
									<xsl:with-param name="edit"   select="$edit"/>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema"   select="$schema"/>
								<xsl:with-param name="edit"     select="$edit"/>
								<xsl:with-param name="title"     select="/root/gui/schemas/*[name()=$schema]/strings/temporalResolution"/>
								<xsl:with-param name="text"     select="$text"/>
							</xsl:apply-templates>
						</xsl:for-each><!--
						<xsl:apply-templates mode="elementEP" select="gmd:contentInfo/gmd:MD_CoverageDescription/gmd:dimension[1]/
							gmd:MD_RangeDimension">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>-->
						
						
						<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
							[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='temporal']/gmd:MD_Keywords">
							
							<xsl:apply-templates mode="simpleElement" select=".">
								<xsl:with-param name="schema"  select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
								<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/temporalScale"/>
								<xsl:with-param name="text">
									<xsl:call-template name="snippet-editor">
										<xsl:with-param name="elementRef" select="../geonet:element/@ref"/>
										<xsl:with-param name="widgetMode" select="'combo'"/>
										<xsl:with-param name="thesaurusId" select="'local.temporal.myocean.temporal.scale'"/>
										<xsl:with-param name="listOfKeywords" select="replace(replace(string-join(gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
										<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
										<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:for-each>
						<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
							[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='temporal']">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>-->
						
					</xsl:with-param>
				</xsl:call-template>
				
			</xsl:with-param>
		</xsl:call-template>
		
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/processingOperation"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/processingOperation)"/>
			<xsl:with-param name="content">
				
				
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='processing-levels']/gmd:MD_Keywords">
					
					<xsl:apply-templates mode="simpleElement" select=".">
						<xsl:with-param name="schema"  select="$schema"/>
						<xsl:with-param name="edit"   select="$edit"/>
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/processingLevel"/>
						<xsl:with-param name="text">
							<xsl:call-template name="snippet-editor">
								<xsl:with-param name="elementRef" select="../geonet:element/@ref"/>
								<xsl:with-param name="widgetMode" select="'combo'"/>
								<xsl:with-param name="thesaurusId" select="'local.processing-levels.myocean.processing-level'"/>
								<xsl:with-param name="listOfKeywords" select="replace(replace(string-join(gmd:keyword/*[1], '#,#'), '''', '\\'''), '#', '''')"/>
								<xsl:with-param name="listOfTransformations" select="'''to-iso19139.myocean-keyword-with-anchor'''"/>
								<xsl:with-param name="transformation" select="'to-iso19139.myocean-keyword-with-anchor'"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
				<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords
					[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='processing-levels']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-->
				
				<xsl:call-template name="complexElementGuiWrapper">
					<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/processingSchedule"/>
					<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/processingSchedule)"/>
					<xsl:with-param name="content">
						
						<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/
							gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/
							gmd:MD_MaintenanceInformation/gmd:maintenanceNote">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						
						<!--<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit"   select="$edit"/>
						</xsl:apply-templates>
						-->
						
						<xsl:call-template name="complexElementGuiWrapper">
							<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/slidingWindow"/>
							<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/slidingWindow)"/>
							<xsl:with-param name="content">
								<!--<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
									gmd:EX_Extent[not(gmd:description)]/gmd:temporalElement/*">
									<xsl:with-param name="schema" select="$schema"/>
									<xsl:with-param name="edit"   select="$edit"/>
								</xsl:apply-templates>
								-->
								
								<!--
								<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/
									gmd:MD_MaintenanceInformation/gmd:updateScopeDescription/gmd:MD_ScopeDescription/gmd:other">
									<xsl:with-param name="schema" select="$schema"/>
									<xsl:with-param name="edit"   select="$edit"/>
								</xsl:apply-templates>
								-->
								
								
								<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/
									gmd:MD_MaintenanceInformation/gmd:updateScopeDescription/gmd:MD_ScopeDescription/gmd:other">
									<xsl:apply-templates mode="simpleElement" select=".">
										<xsl:with-param name="schema"  select="$schema"/>
										<xsl:with-param name="edit"   select="$edit"/>
										<xsl:with-param name="title" select="''"/>
										<xsl:with-param name="text">
											<xsl:variable name="id" select="gco:CharacterString/geonet:element/@ref"/>
											<xsl:variable name="value" select="gco:CharacterString"/>
											<xsl:variable name="start" select="replace(substring-before($value, '#'), 'P','')"/>
											<xsl:variable name="end" select="replace(substring-after($value, '#'), 'P','')"/>
											
											<input class="md" type="hidden"
												name="_{$id}" 
												id="_{$id}"  
												value="{$value}" size="30"/>
											
											
											<div class="slidingWindow">
												<label><xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/startPeriod"/></label>
												<br/>
												<label for="_{$id}_s_month">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/month"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_s_month" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before($start, 'M')}" size="5"/>
												<label for="_{$id}_s_month">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/day"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_s_day" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before(substring-after($start, 'M'), 'D')}" size="5"/>
												<label for="_{$id}_s_hour">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/hour"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_s_hour" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before(substring-after($start, 'D'), 'H')}" size="5"/>
											</div>
											<div class="slidingWindow">
												<label><xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/endPeriod"/></label>
												<br/>
												<label for="_{$id}_e_month">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/month"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_e_month" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before($start, 'M')}" size="5"/>
												<label for="_{$id}_e_month">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/day"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_e_day" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before(substring-after($end, 'M'), 'D')}" size="5"/>
												<label for="_{$id}_e_hour">
													<xsl:value-of select="/root/gui/schemas/*[name()=$schema]/strings/hour"/>
												</label>
												<input type="number" class="md small" 
													id="_{$id}_e_hour" 
													onkeyup="updateSlidingWindow('_{$id}');"
													onchange="updateSlidingWindow('_{$id}');"
													value="{substring-before(substring-after($end, 'D'), 'H')}" size="5"/>
											</div>
										</xsl:with-param>
									</xsl:apply-templates>
								</xsl:for-each>
								
								
								<!--<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
									gmd:EX_Extent[not(gmd:description)]/gmd:temporalElement[1]/
									gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:duration">
									<xsl:with-param name="schema" select="$schema"/>
									<xsl:with-param name="edit"   select="$edit"/>
									<xsl:with-param name="title"  select="/root/gui/schemas/*[name()=$schema]/strings/startPeriod"/>
								</xsl:apply-templates>
								
								<xsl:apply-templates mode="iso19139" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/
									gmd:EX_Extent[not(gmd:description)]/gmd:temporalElement[2]/
									gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod//gml:duration">
									<xsl:with-param name="schema" select="$schema"/>
									<xsl:with-param name="edit"   select="$edit"/>
									<xsl:with-param name="title"  select="/root/gui/schemas/*[name()=$schema]/strings/endPeriod"/>
								</xsl:apply-templates>-->
								
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				
			</xsl:with-param>
		</xsl:call-template>
		
		
		<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/org"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/org)"/>
			<xsl:with-param name="content">

				<!-- Production center -->
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/
					gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='originator']">
					<xsl:call-template name="complexElementGuiWrapper">
					<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/orgOriginator"/>
					<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/orgOriginator)"/>
						<xsl:with-param name="content">
							<xsl:apply-templates mode="iso19139.myocean" select=".">
								<xsl:with-param name="schema" select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				
				<!-- Product manager -->
				<xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact">
					<xsl:call-template name="complexElementGuiWrapper">
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/orgCustodian"/>
						<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/orgCustodian)"/>
						<xsl:with-param name="content">
							<xsl:apply-templates mode="iso19139.myocean" select=".">
								<xsl:with-param name="schema" select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				
				
				<!-- Local service desk -->
				<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/
					gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='custodian']">
					<xsl:call-template name="complexElementGuiWrapper">
						<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/orgServiceDesk"/>
						<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/orgServiceDesk)"/>
						<xsl:with-param name="content">
							<xsl:apply-templates mode="iso19139.myocean" select=".">
								<xsl:with-param name="schema" select="$schema"/>
								<xsl:with-param name="edit"   select="$edit"/>
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				
				<xsl:if test="$edit">
					<xsl:copy-of select="geonet:makeSubTemplateButton(gmd:identificationInfo/gmd:MD_DataIdentification/geonet:element/@ref, 
																	'gmd:pointOfContact', 
																	'gmd:CI_ResponsibleParty', 
																	/root/gui/strings/addXMLFragment,
																	/root/gui/strings/addXMLFragment)"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		
		
		<!--<xsl:call-template name="complexElementGuiWrapper">
			<xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/ancillaryInfo"/>
			<xsl:with-param name="id" select="generate-id(/root/gui/schemas/*[name()=$schema]/strings/ancillaryInfo)"/>
			<xsl:with-param name="content">
				
				<!-\- TODO : to be replace by relation manager 
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo/gmd:MD_DataIdentification/
					gmd:aggregationInfo/gmd:MD_AggregateInformation">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-\->
				
				<!-\- TODO : to be replace by relation manager 
				<xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/*//gmd:CI_OnlineResource">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>-\->
			</xsl:with-param>
		</xsl:call-template>-->
		
	</xsl:template>
	
</xsl:stylesheet>
