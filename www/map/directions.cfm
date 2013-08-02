<!doctype html>
<html lang="en">
 <head>
  <meta charset="utf-8">
   <title>SCU Campus Map Directions</title>
	<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1"/>
   <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="translucent black">
       <link href="http://fonts.googleapis.com/css?family=Open Sans&subset=latin" rel="stylesheet" type="text/css">
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
        google.load('maps', '3.6', {
         other_params: 'sensor=false'
        });
        google.load('jquery', '1.6.4');
       </script>
        <script src="http://code.jquery.com/mobile/latest/jquery.mobile.min.js"></script>
       <script src="/includes/ui/min/jquery.ui.map.full.min.js"></script>
       <script src="/includes/ui/jquery.ui.map.extensions.js"></script>
       <script type="text/javascript">
        $('#directions_map').live("pageshow", function () {
         $('#map_canvas_1').gmap('refresh');
         $('#map_canvas_1').gmap('getCurrentPosition', function (position, status) {
          if (status === 'OK') {
           var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
            $('#map_canvas_1').gmap('get', 'map').panTo(latlng);
           $('#map_canvas_1').gmap('search', {
            'location': latlng
           }, function (results, status) {
            if (status === 'OK') {
             $('#from').val(results[0].formatted_address);
            }
           });
          } else {
           alert('Unable to get current position');
          }
         });
        });

        $('#directions_map').live("pagecreate", function () {
         $('#map_canvas_1').gmap({
          'center': '37.34942, -121.940178',
          'zoom': 18
         });
         $('#submit').click(function () {
          $('#map_canvas_1').gmap('displayDirections', {
           'origin': $('#from').val(),
           'destination': $('#to').val(),
           'travelMode': google.maps.DirectionsTravelMode.DRIVING
          }, {
           'panel': document.getElementById('directions')
          }, function (response, status) {
           if (status === 'OK') {
            $('#results').show();
           } else {
            $('#results').hide();
           }
          });
          return false;
         });
        });
        $('#directions_map').live("pageshow", function () {
         $('#results').hide();
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
       <div id="directions_map" data-role="page" class="type-interior" data-theme="g" data-add-back-btn="true">
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
           <li><a rel="external" href="locations.cfm">Locations</a></li>
           <li><a rel="external" href="parking.cfm">Parking</a></li>
           <li data-theme="a"><a rel="external" href="#">Get directions</a></li>
          </ul>
         </div>
<!-- /nav-bar -->
         <div id="results" class="ui-listview ui-listview-inset ui-corner-all ui-shadow" style="display:none;margin-left:20px;font-size:80%;">
<!-- direction results -->
          <div class="ui-li ui-li-divider ui-btn ui-bar-a ui-corner-top ui-btn-up-undefined">Results</div>
          <div id="directions"></div>
          <div class="ui-li ui-li-divider ui-btn ui-bar-a ui-corner-bottom ui-btn-up-undefined"></div>

         </div>
<!-- /direction results -->
        </div>
<!-- /content-secondary -->
        <div data-role="content" class="content-primary" style="padding:1em;height:100%;">
<!-- content-primary -->
         <div class="ui-bar-c ui-corner-all ui-shadow" style="padding:1em;">
          <div id="map_canvas_1"></div>
          <p>
           <label for="from">From</label>

           <input id="from" class="ui-bar-c" type="search" value=""/>
          </p>
          <p>
           <label for="to">To</label>
           <input id="to" class="ui-bar-c" type="search" value="Santa Clara University"/>
          </p>
          <a id="submit" href="#" data-role="button" data-theme="a" data-icon="search">Get directions</a>
         </div>

        </div>
<!-- /content-primary -->

<cfinclude template="/includes/_foot.cfm" />