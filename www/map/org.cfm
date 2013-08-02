<cfparam name="url.id" default="" />

<cfif len(url.id)>
<cfset flash.org_id = url.id />
<cfinclude template="/web/cms/map/customcf/main_getOrgData.cfm" />
<cfelse>
<cfinclude template="/web/cms/map/customcf/main_getAllOrg.cfm" />
</cfif>

<!doctype html>
<html lang="en">
 <head>
  <meta charset="utf-8">
   <title>SCU Campus Map</title>
	<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
	<meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="translucent black">
       <link rel="stylesheet" href="/uicss/mobile-map.css"/>
	   <link rel="stylesheet" href="/uicss/scu.css" />
	   <link rel="stylesheet" href="/uicss/secondary.css" />
	   <style type="text/css">
	   .ui-header .sculogo {
	   	margin:-5px 0 0 -5px !important;
	   	}
	   </style>
       <script src="https://www.google.com/jsapi?"></script>
       <script>
        google.load('jquery', '1.7.1');
       </script>
        <script src="http://code.jquery.com/mobile/latest/jquery.mobile.min.js"></script>
       <script src="/includes/ui/min/jquery.ui.map.full.min.js"></script>
       <script src="/includes/ui/jquery.ui.map.extensions.js"></script>
      </head>
      <body>
       <div id="map_simple" data-role="page" class="type-interior" data-theme="g" data-add-back-btn="true">
<!-- page -->
<!-- header -->
		<div data-role="header"><a rel="external" href="/" data-role="none" data-direction="reverse" class="ui-btn-left"><img width="108" height="40" class="sculogo" alt="" src="/mobimages/scu-home.png" /></a>
			<h1><cfoutput><a href="/#listgetat(cgi.script_name,1,'/')#" rel="external">Campus Map</a></cfoutput></h1>
		</div>
<!-- /header -->
        <div data-role="content" class="content-secondary">
<!-- content-secondary -->
         <div data-role="collapsible" data-collapsed="true" data-content-theme="g">
<!-- nav-bar -->
          <h3>Menu</h3>
          <ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="a">
           <li><a rel="external" href="index.cfm">Campus map</a></li>
           <li data-theme="a"><a rel="external" href="#">Locations</a></li>
		   <li><a rel="external" href="parking.cfm">Parking</a></li>
           <li><a rel="external" href="directions.cfm">Get directions</a></li>
           </ul>
         </div>
<!-- /nav-bar -->
        </div>
<!-- /content-secondary -->
        <div data-role="content" class="content-primary" style="padding:1em;height:100%;">
		<!-- content-primary -->

		<cfoutput>
		<cfif isdefined("getit")>
		        <h3>#getIt.name#</h3>
		        <cfif len(getIt.descr_full)>
		            <p>#getIt.descr_full#</p>
		        </cfif>
		        
		        <h5><a href="locations.cfm?loc_id=#getLoc.loc_id#"><cfif len(getLoc.commonName)>#getLoc.commonName#<cfelse>#getLoc.name#</cfif></a><cfif len(getIt.location_text)> #getIt.location_text#</cfif></h5>
		        <div><a href="locations.cfm?loc_id=#getLoc.loc_id#">Campus Map</a></div>
		        <cfif len(getIt.phone)>
		            <div>Tel <cfif not find("408-",getit.phone)>408-</cfif>#getIt.phone#</div>
		        </cfif>
		        <cfif len(getIt.fax)>
		            <div>Fax <cfif not find("408-",getit.phone)>408-</cfif>#getIt.fax#</div>
		        </cfif>
		        <cfif len(getIt.orgemail)>
		            <div>Email #getIt.orgemail#</div>
		        </cfif>
		        
		        <cfif len(getIt.office_hours)>
		        <p><strong>Hours:</strong> #getIt.office_hours#</p>
		        </cfif>
		        <p><a href="/people/?oid=#getit.org_id#" rel="external">Directory listing &raquo;</a></p>
		        <cfif len(getIt.site_url)>
		        <p><a href="#getit.site_url#">Web site &raquo;</a></p>
		        </cfif>
		<cfelseif isdefined("getall")>
		    <h3>SCU Organizations</h3>
		    <ul>
		    <cfloop query="getall">
		    <li><a href="index.cfm?org_id=#getall.org_id#">#getall.name#</a></li>
		    </cfloop>
		    </ul>
		</cfif>
		</cfoutput>
        </div>
<!-- /content-primary -->

<cfinclude template="/includes/_foot.cfm" />
