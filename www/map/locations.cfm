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
        <div data-role="collapsible">		
   			<h3>Maps</h3>
			<ul data-role="listview" data-inset="true" data-theme="b" data-dividertheme="a">
	           <li data-theme="a"><a rel="external" href="index.cfm">Campus map</a></li>
	           <li><a rel="external" href="locations.cfm">Buildings</a></li>
			   <li><a rel="external" href="parking.cfm">Parking</a></li>
	         </ul>
	     </div>
	     <div data-role="collapsible">
	         <h3>Get Directions</h3>
	         <ul data-role="listview" data-inset="true" data-theme="b" data-dividertheme="a">				 
				<li><a rel="external" href="driving.cfm">Driving to SCU</a></li>
				<li><a rel="external" href="campus.cfm">Wayfinding on campus</a></li>
				<li><a rel="external" href="rooms.cfm">Wayfinding in a building</a></li>
				<li><a rel="external" href="facstaff.cfm">Locate Faculty or Staff</a></li>
			</ul>
	    </div>
<!-- /nav-bar -->
        </div>
<!-- /content-secondary -->
        <div data-role="content" class="content-primary" style="padding:1em;height:100%;">
<!-- content-primary -->
          <cfparam name="url.id" default="" />
			<cfset variables.fixedPos = "true" />
			<cfset variables.pageTitle = "Locations" />
			<cfif len(url.id)>
				<cfset flash.loc_id = url.id />
				<cfinclude template="/web/cms/map/customcf/main_getLocData.cfm" />
			<cfelse>
				<cfinclude template="/web/cms/map/customcf/main_getAllLoc.cfm" />
			</cfif>
			<cfoutput>
					<cfif isdefined("getit")>
						<h3><cfif len(getit.commonname)>#getit.commonname#<cfelse>#getit.name#</cfif></h3>
						<p>#getit.descr_full#</p>
						<p><a href="index.cfm?loc_id=#getit.loc_id#" data-ajax="false">Campus Map</a></p>
						<cfif getChildren.recordcount GT 0>
					    	<h4>Also in this location</h4>
						    <ul data-role="listview" data-inset="true">
						        <cfloop query="getChildren">
						        <li><a href="locations.cfm?id=#getChildren.loc_id#"><cfif len(getChildren.commonname)>#getChildren.commonname#<cfelse>#getChildren.name#</cfif></a></li>
						        </cfloop>
						    </ul>
					    </cfif>
					
						<cfif getOrgs.recordcount GT 0>
					    <h4>Organizations located here</h4>
					    <ul data-role="listview" data-inset="true">
					        <cfloop query="getOrgs">
					        <li><a href="/people?oid=#getOrgs.org_id#" rel="external">#getOrgs.name#</a></li>
					        </cfloop>
					    </ul>
					    </cfif>
					<cfelseif isdefined("getall")>
						<h4>Popular Locations</h4>
						 <ul data-role="listview" data-inset="true">
						    <li><a href="index.cfm?loc_id=120" data-ajax="false">Admission, Undergraduate</a></li>
						    <li><a href="index.cfm?loc_id=7" data-ajax="false">Benson Center</a></li>
						    <li><a href="index.cfm?loc_id=10" data-ajax="false">Buck Shaw Stadium</a></li>
						    <li><a href="index.cfm?loc_id=144" data-ajax="false">Learning Commons and Library</a></li>
						    <li><a href="index.cfm?loc_id=37" data-ajax="false">Leavey Event Center</a></li>
						    <li><a href="index.cfm?loc_id=148" data-ajax="false">Lucas Hall</a></li>
						    <li><a href="index.cfm?loc_id=39" data-ajax="false">Malley Center</a></li>
						    <li><a href="index.cfm?loc_id=42" data-ajax="false">Mission Church</a></li>
						    <li><a href="index.cfm?loc_id=114" data-ajax="false">Stephen Schott Stadium</a></li>
						    <li><a href="map.cfm?vtype=Access_Card_Locations" data-ajax="false">Access Card Locations</a></li>
					    </ul>
					    <h4>All Locations</h4>
					    <ul data-role="listview" data-filter="true" data-inset="true">
					    <cfloop query="getall">
					    	<li><a href="index.cfm?loc_id=#getall.loc_id#" data-ajax="false">#getall.name#</a></li>
					    </cfloop>
					    </ul>
					</cfif>
			</cfoutput>
        </div>
<!-- /content-primary -->

<cfinclude template="/includes/_foot.cfm" />