<cfinclude template="wf-shared.cfm">
<!doctype html>
<html lang="en">
 <head>
  <meta charset="utf-8">
   <title>Campus Map</title>
   <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1"/>
   <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="translucent black">
       <link href="http://fonts.googleapis.com/css?family=Open%20Sans&subset=latin" rel="stylesheet">
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
        google.load('maps', '3.7', {
         other_params: 'sensor=false'
        });
        google.load('jquery', '1.7.1');
       </script>
       <script src="http://code.jquery.com/mobile/1.3.1/jquery.mobile-1.3.1.min.js"></script> 
       <script src="/includes/ui/min/jquery.ui.map.full.min.js"></script>
       <script src="/includes/ui/jquery.ui.map.extensions.js"></script>
       <cfparam name="url.loc_id" default="0" />
       <cfparam name="url.org_id" default="0" />
	   <cfif isdefined("url.r") and len(url.r)>
	   		<cfset getloc = qLocation(url.r)>
	   		<cfif getloc.recordcount>
		   		<cfset url.loc_id = getloc.loc_id />
		   	</cfif>
	   </cfif>
       <cfif len(url.loc_id) and url.loc_id GT 0>
			<cfset myLoc = getLocation(url.loc_id) />
		<cfelse>
			<cfset myLoc.GPS_LATITUDE = 37.34942 />
			<cfset myLoc.GPS_LONGITUDE = -121.94017 />
			<cfset myLoc.NAME = 'Santa Clara University' />
			<cfset myLoc.COMMONNAME = 'Santa Clara University' />
		</cfif>
       <script>
        var oncampus = false;
        var locid = <cfoutput>#url.loc_id#</cfoutput>
        var orgid = <cfoutput>#url.org_id#</cfoutput>
        var label = <cfoutput>'#xmlformat(myLoc.NAME)#'</cfoutput>
        var SCU_campus_region = {};
			SCU_campus_region.north_lat = 37.352588;
			SCU_campus_region.south_lat = 37.344415;
			SCU_campus_region.west_long = -121.946109;
			SCU_campus_region.east_long = -121.931895; 
        $('#gps_map').live("pageshow", function () {
         $('#map_canvas_2').gmap('refresh');
        });
        $('#gps_map').live("pagecreate", function () {
         $('#map_canvas_2').gmap({
          <cfoutput>'center': '#myLoc.GPS_LATITUDE#, #myLoc.GPS_LONGITUDE#',</cfoutput>
          'zoom': 18
         }).bind('init', function (event, map) {
          
          $('#map_canvas_2').gmap('watchPosition', function (position, status) {
           if (status === 'OK' && locid == 0) {
           	if ( (position.coords.latitude <= SCU_campus_region.north_lat) && (position.coords.latitude >= SCU_campus_region.south_lat) && (position.coords.longitude <= SCU_campus_region.east_long) && (position.coords.longitude >= SCU_campus_region.west_long) ) {
           		oncampus = true
           		}
			var myLocIcon = new google.maps.MarkerImage('/map/pegman.png');
            var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            var marker = $('#map_canvas_2').gmap('get', 'markers> client');
            if (!marker && oncampus) {
             $('#map_canvas_2').gmap('addMarker', {
              'id': 'client',
              'position': latlng,
              'icon': myLocIcon
             });
             map.panTo(latlng);
            } else {
             marker.setPosition(latlng);
             map.panTo(latlng);
            }
           }
          });
          if (locid != 0) {
          	if (orgid == 0 || orgid == '') {
				  	var pageview = 'locations';
					var mapid = locid;
					} else {
				  	var pageview = 'organizations';
					var mapid = orgid;	
					}
          	var content = '<a href="' + pageview +'.cfm?id=' + mapid +'">' + label + '<br>View details &raquo;</a>';
	          $('#map_canvas_2').gmap('addMarker', {
	           'position': map.getCenter(),
	           'animation': google.maps.Animation.DROP
	          }).click(function () {
	           $('#map_canvas_2').gmap('openInfoWindow', {
	            'content': content
	           }, this);
	          });
          }
          
          var trafficOptions = {
		  getTileUrl: function(coord, zoom) {
			cordstr = ''+coord;
			crdu = cordstr.replace(',','_').replace('(','').replace(')','').replace(' ','');
			return "/docs/gmaps/img_" +crdu+'.png';		
		  },

			tileSize: new google.maps.Size(256, 256),
			isPng: true
			};
		  var trafficMapType = new google.maps.ImageMapType(trafficOptions);
		  map.overlayMapTypes.insertAt(0, trafficMapType);
          
         });
        });
        $('#gps_map').live("pagehide", function () {
         $('#map_canvas_2').gmap('clearWatch');
        });
		$(function(){
	$('body').delegate('.content-secondary .ui-collapsible-content', 'click',  function(){
		$(this).trigger("collapse")
	});
});
function setDefaultTransition(){
	var winwidth = $( window ).width(),
		trans ="slide";
	if( winwidth >= 1000 ){
		trans = "none";
	}
	else if( winwidth >= 650 ){
		trans = "fade";
	}
	$.mobile.defaultPageTransition = trans;
}
$(function(){
	setDefaultTransition();
	$( window ).bind( "throttledresize", setDefaultTransition );
});
       </script>
      </head>
      <body>
       <div id="gps_map" data-role="page" class="type-interior" data-theme="g">
<!-- page -->
<!-- header -->
		<div data-role="header"><a rel="external" href="/" data-role="none" data-direction="reverse" class="ui-btn-left"><img width="108" height="40" class="sculogo" alt="" src="/mobimages/scu-home.png" /></a>
			<h1>Campus Map</h1>
		</div>
<!-- /header -->
	
<!-- content-secondary -->	
	 <div data-role="content" class="content-secondary">
	
		<cfset mainMenu()> <!--- this now lives in wf-shared.cfm --->
<!----

         <div data-role="collapsible" data-collapsed="true" data-content-theme="g">
<!-- nav-bar -->
          <h3>Menu</h3>
          <ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="a">
           <li data-theme="a"><a rel="external" href="index.cfm">Campus map</a></li>
           <li><a rel="external" href="locations.cfm">Locations</a></li>
		   <li><a rel="external" href="parking.cfm">Parking</a></li>
		   	
           <li data-role="collapsible" data-inset="false">		
   				<h3>Get Directons</h3>
				<ul data-theme="b">					 
					<li><a rel="external" href="driving.cfm">driving to campus</a></li>
					<li><a rel="external" href="campus.cfm">between campus buildings</a></li>
					<li><a rel="external" href="rooms.cfm">within a building</a></li>
				</ul>
			</li>
		
          </ul>
         </div>
<!-- /nav-bar -->----->
        </div>
<!-- /content-secondary -->
        <div data-role="content" class="content-primary" style="padding:1em;height:100%;">
<!-- content-primary -->
         <div class="ui-bar-c ui-corner-all ui-shadow" style="padding:1em;">
          <div id="map_canvas_2"></div>
         </div>
        </div>
<!-- /content-primary -->

<cffunction 
	name = "qLocation" 
	returnType = "query">
  	<cfargument name="roomname" default="" />
    
    <cfquery name="getRooms" datasource="phonebook">
    select * from floor_image_loc
    </cfquery>
    
    <cfquery name="getMapInfo" dbtype="query">
    select loc_id, room_descr
    from getRooms
    where roomname = <cfqueryparam value="#arguments.roomname#" />
		or room_descr = <cfqueryparam value="#arguments.roomname#" />
    </cfquery>

    <cfreturn getMapInfo />
</cffunction>

<cfinclude template="/includes/_foot.cfm" />