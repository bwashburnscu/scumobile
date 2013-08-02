<!doctype html>
<html lang="en">
 <head>
  <meta charset="utf-8">
   <title>SCU Campus Parking</title>
	<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1"/>
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
	   <script type="text/javascript">
        google.load('jquery', '1.6.4');
       </script>
        <script src="http://code.jquery.com/mobile/latest/jquery.mobile.min.js"></script>
       <script src="/includes/ui/min/jquery.ui.map.full.min.js"></script>
       <script src="/includes/ui/jquery.ui.map.extensions.js"></script>

      </head>
      <body>
       <div id="directions_map" data-role="page" class="type-interior" data-theme="g" data-add-back-btn="true">
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
         <div>
		<cfparam name="url.permit" default="" />
		<cfif len(url.permit)>
		    <cfquery name="permitlocations" datasource="phonebook">
		    select loc_id, name
		    from location
		    where name like <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.permit# - %" />
		    </cfquery>
		</cfif>
		<cfoutput>
		<h3><cfif len(url.permit)>#ucase(url.permit)# Parking Permit Locations<cfelse>Parking</cfif></h3>
		<cfif len(url.permit) and isdefined("permitlocations")>
		
		<ul data-role="listview" data-inset="true">
			<cfloop query="permitlocations">
		    <li>
		    <a rel="external" href="index.cfm?loc_id=#loc_id#">#name#</a>
		    </li>
		    </cfloop>
		</ul>
		
		<cfelse>
          <ul data-role="listview" data-inset="true">
		    <li>
		    <a rel="external" href="?permit=guest">Guest Parking</a>
		    </li>
		    <li>
		    <a rel="external" href="?permit=b">'B' Permits</a>
		    </li>
		    <li>
		    <a rel="external" href="?permit=c">'C' Permits</a>
		    </li>
		    <li>
		    <a rel="external" href="?permit=cw">'Cw' Permits</a>
		    </li>
		    <li>
		    <a rel="external" href="?permit=e">'E' Permits</a>
		    </li>
		    <li>
		    <a rel="external" href="?permit=f">'F' Permits</a>
		    </li>
		</ul>
		</cfif>
		</cfoutput>
         </div>

        </div>
<!-- /content-primary -->


<cfinclude template="/includes/_foot.cfm" />