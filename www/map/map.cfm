<cfparam name="url.vtype" default="" />
<cfparam name="url.tab" default="" />
<cfparam name="url.ltr" default="a" />
<cfparam name="url.loc_id" default="" />
<cfparam name="url.org_id" default="" />
<cfparam name="url.zoom" default="3" />
<cfparam name="url.permit" default="" />
<cfparam name="url.instanceid" default="" />
<cfparam name="url.dirfrom" default="" />
<cfparam name="url.hotelid" default="" />
<cfparam name="url.image_id" default="" />
<cfset variables.sitepath = 'http://test01.scu.edu/'>
<cfset variables.mapdetailxsl = "/web/apps/mobile/xsl/map_class_2.xsl" />
<cfset variables.listxsl = "/web/apps/mobile/xsl/map_class_2.xsl" />

<cfif cgi.http_host is "staging.scu.edu">
	<cfset apikey = "ABQIAAAAaoSYJmjfiSwGCLatW2-acRSuhtVft4W3LuNj2btANICjUEp4ORQT3P61bisqrEUqTlMjMC0mtrQQ9w"/>
<cfelseif cgi.http_host is "cms.scu.edu">
	<cfset apikey = "ABQIAAAAaoSYJmjfiSwGCLatW2-acRSTT89riGvws9IM6Nhc3-4pTdTCqRT8IxwjDJKIDB_xl6MpjrtK5dbmFQ"/>
<cfelseif cgi.http_host is "m.scu.edu">  
    <cfset apikey = "ABQIAAAAJZQPadk0_ohIETBiB0P4SRSzHA5gvy4Qj-shM5ZvfADeNLqYwhSZc5ijy_eH4cp1DJvuX8NNaujR8Q" />
<cfelseif cgi.http_host is "mobile.scu.edu">  
    <cfset apikey = "ABQIAAAAJZQPadk0_ohIETBiB0P4SRTg2_sFiBBl-GFCNPxv0fmRaB3i0xQ-UMh1OmTgMnWAUdQ0kpXPxOvoeA" />
<cfelseif cgi.http_host is "test01.scu.edu">  
    <cfset apikey = "ABQIAAAAJZQPadk0_ohIETBiB0P4SRTlNDKi5TzAaAcMSjzVTBL4O0t_bRR_0F3uiBvCGpKaQGyJQjVQyDvkiw" />
<cfelse>
	<cfset apikey = "ABQIAAAAaoSYJmjfiSwGCLatW2-acRRP0dVXz5knKJqEji11nI5_9ainXBR7GRozlZp5cD6tZNL37GtBaVTV1g"/>
</cfif>

	
<cfset pageBuilder = createobject("component","web.apps.mobile.pageBuilder").init("mobile.map")>

<cfset xslparams = structnew()>
<cfset xslparams["qstring"] = "vtype=#url.vtype#&">
<cfset xslparams["breadcrumb_html"] = "">
<cfif len(url.vtype)>
	<cfset xslparams["breadcrumb_html"] = xslparams["breadcrumb_html"] & " &raquo; <a href='" & variables.sitepath & "map/?vtype=#url.vtype#'>#replace(url.vtype,"_"," ","All")#</a>">
</cfif>

<cfoutput>
<cfif len(url.loc_id)>
    <cfset xslparams["zoom"] = url.zoom>
	<cfset xslparams["qstring"] = xslparams["qstring"] & "loc_id=#url.loc_id#&">
    <cfset xslparams["viewmode"] = "mapdetail">
	<cfset pageBuilder.setMethod("getLocationDetailView","loc_id=#url.loc_id#&zoom=#url.zoom#")>
    <cfset pageBuilder.setTransformer(variables.mapdetailxsl)>
          
<cfelseif len(url.org_id)>
    <cfset xslparams["zoom"] = url.zoom>
	<cfset xslparams["qstring"] = xslparams["qstring"] & "org_id=#url.org_id#&">
    <cfset xslparams["viewmode"] = "mapdetail">
	<cfset pageBuilder.setMethod("getOrgDetailView","org_id=#url.org_id#&zoom=#url.zoom#")>
    <cfset pageBuilder.setTransformer(variables.mapdetailxsl)>

<cfelseif len(url.instanceid)>
    <cfset xslparams["zoom"] = url.zoom>
 	<cfset xslparams["qstring"] = xslparams["qstring"] & "instanceid=#url.instanceid#&">
	<cfset xslparams["apikey"] = apikey>
    <cfset xslparams["viewmode"] = "mapdetail">
	<cfset pageBuilder.setMethod("getInstanceDetails","instanceid=#url.instanceid#&zoom=#url.zoom#")>
    <cfset pageBuilder.setTransformer(variables.mapdetailxsl)>
      
 
<cfelseif len(url.permit)>
	<cfset xslparams["qstring"] = xslparams["qstring"] & "permit=#url.permit#&">
	<cfset xslparams["breadcrumb_html"] = xslparams["breadcrumb_html"] & " &raquo; <a href=/mobile/map/?permit=#url.permit#&vtype=Parking>#ucase(url.permit)# Permits</a>">
    <cfset xslparams["viewmode"] = "list">
	<cfset pageBuilder.setMethod("getPermitLocations","permitType=#url.permit#")>
    <cfset pageBuilder.setTransformer(variables.listxsl)>
        
<cfelseif len(url.vtype)>
   	<cfswitch expression="#url.vtype#">
        <cfcase value="Locations">
        	<cfset xslparams["viewmode"] = "alpha">
			<cfset pageBuilder.setMethod("getBuildings","letter=#url.ltr#&loc_id=&searchq=")>
			<cfset pageBuilder.setTransformer(variables.alphalistxsl)>
        </cfcase>
        <cfcase value="Organizations">
        	<cfset xslparams["viewmode"] = "alpha">
			<cfset pageBuilder.setMethod("getOrganizations","letter=#url.ltr#&org_id=&searchq=")>
			<cfset pageBuilder.setTransformer(variables.alphalistxsl)>
        </cfcase>
        <cfcase value="Access_Card_Locations">
        	<cfset xslparams["viewmode"] = "list">
			<cfset pageBuilder.setMethod("getAccessLocations")>
			<cfset pageBuilder.setTransformer(variables.listxsl)>
        </cfcase>
        <cfcase value="Directions">
        	<cfif len(url.dirfrom)>
                <cfset xslparams["apikey"] = apikey>
				<cfset xslparams["dirfrom"] =  url.dirfrom>
				<cfset xslparams["viewmode"] = "googledirections">
				<cfset pageBuilder.setXMLcontent("<item></item>")>
				<cfset pageBuilder.setTransformer(variables.directionsmapxsl)>

			<cfelse>
                <cfset xmldoc = XmlParse("/web/apps/mobile/xml/map_directions.xml")>
                <cfset xslparams["pagetitle"] = "Directions">
                <cfset xslparams["viewmode"] = "directions">
				<cfset pageBuilder.setXMLfile("/web/apps/mobile/xml/map_directions.xml")>
				<cfset pageBuilder.setTransformer(variables.directionsxsl)>
			</cfif>
        </cfcase>
        <cfcase value="Hotels">
			<cfset pageBuilder.setMethod("getHotels","hotelid=#url.hotelid#")>
            <cfif len(url.hotelid)>
            	<cfset xslparams["viewmode"] = "hotel">
				<cfset pageBuilder.setTransformer(variables.hoteldetailsxsl)>
			<cfelse>
            	<cfset xslparams["viewmode"] = "list">
				<cfset pageBuilder.setTransformer(variables.listxsl)>
			</cfif>
        </cfcase>
        <cfcase value="Weather">
        	<cfset xslparams["viewmode"] = "weather">
			<cfset pageBuilder.setXMLfile("http://rss.weather.com/weather/rss/local/95053?cm_ven=LWO&cm_cat=rss&par=LWO_rss")>
			<cfset pageBuilder.setTransformer(variables.weatherxsl)>
        </cfcase>
        <cfcase value="Caltrain">
        	<cflocation url="http://m.icaltrain.com/" />
        </cfcase>
        <cfcase value="Local_Attractions">
			<cfset xslparams["image_id"] = url.image_id>
            <cfset xslparams["viewmode"] = "attractions">
			<cfset pageBuilder.setXMLfile(expandpath("/web/cms/admission/findmore/customcf/slideshow_2759841.xml"))>
			<cfset pageBuilder.setTransformer(variables.attractionxsl)>
        </cfcase>
        <cfcase value="Regional_Attractions">
			<cfset xslparams["image_id"] = url.image_id>
            <cfset xslparams["viewmode"] = "attractions">
			<cfset pageBuilder.setXMLfile(expandpath("/web/cms/admission/findmore/customcf/slideshow_2759833.xml"))>
			<cfset pageBuilder.setTransformer(variables.attractionxsl)>
        </cfcase>
        <cfcase value="Residences,Food_Services,Parking,Academic_Offices">
        	<cfset xslparams["viewmode"] = "list">
			<cfset pageBuilder.setXMLfile("/web/apps/mobile/xml/map_#lcase(url.vtype)#.xml")>
			<cfset pageBuilder.setTransformer(variables.listxsl)>
        </cfcase>
   		<cfdefaultcase>
			XML not found
        </cfdefaultcase>
   </cfswitch>
   
   <cfelseif len(url.tab)>
		<cfset xslparams["tab"] = url.tab>
        <cfset xslparams["viewmode"] = "tab">
        <cfset pageBuilder.setXMLfile("/web/apps/mobile/xml/map_tab.xml")>
        <cfset pageBuilder.setTransformer(variables.mapxsl)>
<cfelse>

    <cfset xslparams["viewmode"] = "home">
	<cfset pageBuilder.setXMLfile("/web/apps/mobile/xml/map_home.xml")>
    <cfset pageBuilder.setTransformer(variables.mapxsl)>
    
</cfif>

<cfset pageBuilder.run(xslparams)>

</cfoutput>
