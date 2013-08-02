<cfset attributes.cfpath ="/cspot/phonebook/directions/shared.cfm">
<cfinclude template="/web/src/wwwroot/invoke_custom.cfm"> 

<cfinclude template="wf-shared.cfm">

<cfset url.dir = "campus">
<cftry>


<cfparam name="attributes.fullsite" default="http://www.scu.edu" />
<cfoutput>
    <cfparam name="url.imagefocus" default="">
    <cfparam name="url.dir" default="">
	<cfparam name="form.dirFrom" default="">
	<cfparam name="form.dirTo" default="">
	<cfparam name="form.latlong" default="">

	<cfset variables.scripts = 'carousel' />
    <cfset attributes.pagetype = 'home' />
	<cfset attributes.gmaps = true />
    <cfinclude template="/web/apps/mobile/includes/_head.cfm" />	
        <div data-role="content" id="homecontent">
			<div class="content-secondary">
			<cfset mainMenu()>
			</div>
            <div class="content-primary">				
            <ul id="navHome" data-role="listview">
            	<cfif len(url.imagefocus)>
					<cfset imgFocus()>
				<cfelseif isdefined("bodycontent")>
					<cfoutput>#bodycontent#</cfoutput>	
				<cfelseif isdefined("form.submitted")>		        
					<cfif (len(form.dirFrom) or (len(form.latlong) and not form.latlong is 0)) and len(form.dirTo)>
						<cfset getAllData()>		
				        <cfset showMaps()> 
					<cfelse>
	                   	 <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading">Error: please select to and from locations</li>					                                  
					</cfif>        	
                </cfif>
				<cfset selectLocations()>	 
            </ul>
            </div>
			
        </div><!-- /content -->
    <cfinclude template="/web/apps/mobile/includes/_foot.cfm" />	

</cfoutput>
	<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
</cftry>

<cffunction name="selectLocations">
	<cfparam name="form.latlong" default="">
	<cfquery name="campusLocs" datasource="phonebook">
        select distinct if(length(commonName)>0,commonName,name) as locname, loc_id from location l
            join floor_vertex v on l.loc_id = v.campus_loc_id
        order by if(length(commonName)>0,commonName,name)
    </cfquery>   
    <cfquery name="getStaff" datasource="phonebook">
        select distinct if(length(pref_first_name)>0,pref_first_name,legal_first_name) as fname, last_name, per.person_id from person per 
        	join position pos on pos.person_id = per.person_id
        where  pos.loc_id != 0 or  pos.floc_id is not null
        order by last_name, legal_first_name
    </cfquery>   
     	
	<cfoutput>
        <form id='directionsForm' name='directionsForm' action="?" method="post" class="ui-body ui-body-c" data-ajax="false">
        	<input type="hidden" name="submitted" value="1" />        	                	
            	<li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">Directions to an Office</li>
           
                <label for="dirfrom" class="ui-hidden-accessible">From:</label>
                <li>
                    <select name="dirfrom" id="dirfrom">
                        <option value="">from building...</option>
                        <cfif len(form.latlong) and form.latlong is not 0><option value="ll" selected>from My Current Location</option></cfif>
                        <cfloop query="campusLocs">
                            <option value="#loc_id#" <cfif form.dirfrom is loc_id>selected</cfif>>#locname#</option>
                        </cfloop>
                    </select>
                </li>
                <label for="dirto" class="ui-hidden-accessible">To:</label>
                <li>
                    <select name="dirto" id="dirto">
                        <option value="">to person...</option>
                       <cfloop query="getStaff">
                            <option value="#person_id#" <cfif form.dirto is person_id>selected</cfif>>#last_name#, #fname#</option>
                        </cfloop>
                    </select>
                </li>
                <input type="submit" name="go" id="search-basic" value="Map It &raquo;" data-icon="star"/> 
         		<input type="hidden" name="latlong" id="latlong" value="#form.latlong#" />
    
				<cfif not len(form.latlong)>
					<script type="text/javascript">
	                    $(document).ready(function(){
	                          if (navigator.geolocation) {
	                               navigator.geolocation.getCurrentPosition(onSuccess, onError);
	                          } else {
	                           	document.getElementById('latlong').value = 0;
	                          }
	                    });
	                    function onSuccess(position) {
							lat = position.coords.latitude;
							lng = position.coords.longitude;
							
							<cfif isdefined("url.fakell")>
								lat = 37.349459;
								lng = -121.941102;
							</cfif>
							
						  	if ( lat > #ey# && lat < #sy# && lng > #sx# && lng < #ex#) {
								document.getElementById('latlong').value = lat+','+lng;
								$('##dirfrom option[value=""]').text('from My Current Location...');
								$("##dirfrom").selectmenu("refresh");
												
							}
							
	                   }
	                    function onError(msg) {	         	                    	
	                        document.getElementById('latlong').value = 0;
	                    }				
	                 </script>
				</cfif>
                                
			
        </form>

	</cfoutput>
</cffunction>


<cffunction name="showMaps">

	<cfset generator = createobject("Component","web.src.wwwroot.invoke_custom").init("c.phonebook.directions.generate_maps").init(url.dir)>                    

	<cfquery name="getLocs" datasource="phonebook">
    	select * from position where person_id = <cfqueryparam value="#form.dirto#"> order by psn_list desc
    </cfquery>
	
    <cfloop query="getlocs">
        <cfif len(floc_id)>
        	<cfquery name="getLoc" datasource="phonebook">
            	select fi.loc_id, fl.floc_id from  floor_image_loc fl join floor_image fi on fl.fid = fi.fid where fl.floc_id = <cfqueryparam value="#floc_id#">
            </cfquery>
            <cfset toBuilding = getLoc.loc_id>        
            <cfset usingPosition = position_id>  
            <cfset showFloorMap = true>  
        	<cfbreak>
    	<cfelseif len(loc_id)>
			<cfset toBuilding = loc_id>      
            <cfset usingPosition = position_id>  
            <cfset showFloorMap = false>  
        	<cfbreak>
        </cfif>
    </cfloop>


	<cfif toBuilding is form.dirFrom>
        <cfif showFloorMap>
        	<cfset showFloor(getLoc)>
        <cfelse>
			<cfoutput><li>Error: the person's office is in same building. Select a different building to view campus directions</li></cfoutput>
        
        </cfif>
        <cfreturn>
    </cfif>

    <cfif not len(form.dirfrom) and len(form.latlong) and not form.latlong is 0>
    	<cfset fromVert = getClosestVertexToLatLng(form.latlong)>
    
        <cfquery name="gettovert" datasource="phonebook">
            select * from floor_vertex where campus_loc_id = <cfqueryparam value="#toBuilding#">        	
        </cfquery>    
		<cfset res = generator.get(fromVert, gettovert.vertex_id,"Stairs","vert")>
    <cfelse>               
		<cfset res = generator.get(form.dirFrom,toBuilding,"Entrance")>
    </cfif>

    <cfquery name="getPsnDetails" datasource="phonebook">
        select per.*, per.last_name, 
            pos.position_id, pos.phone_pref, per.email_pref, pos.title as postitle, pos.ph_ac, pos.phone, pos.fax_ac, pos.fax, pos.phone_pref, pos.ext as posext, pos.loc_floor, pos.loc_room, pos.loc_id, pos.location as location_text, pos.loc_option,
            org.org_id, org.name as orgname, org.orgemail, org.phone as orgphone, org.areacode, org.fax as orgfax, loc.loc_id, loc.mailing_address, if (length(loc.commonName)>0,loc.commonName,loc.name) as buildname
        from person per, position pos left join location loc on pos.loc_id = loc.loc_id, organization org
        where per.person_id = pos.person_id 
            and pos.org_id = org.org_id and per.person_id = <cfqueryparam value="#form.dirto#">
            and pos.position_id = <cfqueryparam value="#usingPosition#">
        order by  psn_list desc
    </cfquery>

    <cfif isdefined("res.message") and find("Error",res.message)>
		<cfinclude template="/web/apps/mobile/includes/_head.cfm" />	
        <div data-role="content" id="homecontent">
            <div class="content-primary">
            <ul id="navHome" data-role="listview">            
            <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">#res.message#</li>               
			</div><!-- /content -->
		</div>
		<cfinclude template="/web/apps/mobile/includes/_foot.cfm" />	
    <cfelse>

		<cfset smlat = "">
		<cfset lglat = "">
		<cfset smlng = "">
		<cfset lglng = "">
		
		<cfloop from=1 to="#arraylen(res)#" index="i">
			<cfif not len(smlat) or smlat gt res[i][1]>
				<cfset smlat = res[i][1]>
			</cfif>									
			<cfif not len(lglat) or lglat lt res[i][1]>
				<cfset lglat = res[i][1]>
			</cfif>									
			<cfif not len(smlng) or smlng gt res[i][2]>
				<cfset smlng = res[i][2]>
			</cfif>									
			<cfif not len(lglng) or lglng lt res[i][2]>
				<cfset lglng = res[i][2]>
			</cfif>									
		</cfloop>
		               
		<cfset ladiff = lglat - smlat>
		<cfset lgdiff = lglng - smlng>					
        <cfset midlat = (ladiff/2)+smlat>
        <cfset midlng = (lgdiff/2)+smlng>
		
        
		<cfoutput>
			<cfloop query="getPsnDetails">
               <li>
               <a href="/people/?qtype=p&q=#last_name#%20#legal_first_name#"> <h4>#last_name#, <cfif len(pref_first_name)>#pref_first_name#<cfelse>#legal_first_name#</cfif></h4>
    
                <cfif loc_option is "2" and len(location_text)>
                        <p>#location_text#</p>
				<cfelseif len(buildname)>
                    
                    <cfset addr = "#buildname#" /> 
                    <cfif len(loc_floor)>
                        <cfset floor = loc_floor>
                        
                        <cfset addr = "#addr# Floor #floor#" />
                    </cfif>
                    <cfif len(loc_floor) and len(loc_room)>
                        <cfset addr = "#addr#, " />
                    </cfif>
                    <cfif len(loc_room)>
                        <cfset addr = "#addr#Room #loc_room# " />
                    </cfif>
                    <p>#addr#</p>
                </cfif>    
               </a>
               </li>
                <cfbreak>
           </cfloop>
	  <script src="https://www.google.com/jsapi?"></script>
       <script>
        google.load('maps', '3.7', {
         other_params: 'sensor=false'
        });
        google.load('jquery', '1.7.1');
       </script>

		<script>
		
          function gmapsinitialize() {                         	

            var mapOptions = {
              center: new google.maps.LatLng(#midlat#,#midlng#),
              zoom: 18,
              mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
																				
			google.maps.event.addListener(map, "idle", function(){
				google.maps.event.trigger(map, 'resize'); 
				var bounds = new google.maps.LatLngBounds();
				var bottleft = new google.maps.LatLng(#smlat#,#smlng#);
				var topright = new google.maps.LatLng(#lglat#,#lglng#);
				
				bounds.extend(bottleft);
				bounds.extend(topright);
				map.fitBounds(bounds);	
				google.maps.event.clearListeners(map, 'idle');										
			});	

			var pxPathCoordinates = [								
				<cfloop from=1 to="#arraylen(res)#" index="i">
					<cfif i is not 1>,</cfif>
					new google.maps.LatLng(#res[i][1]#, #res[i][2]#)
				</cfloop>
				  ];
			  var pxPath = new google.maps.Polyline({
				path: pxPathCoordinates,
				strokeColor: "##D529ED",
				strokeOpacity: .9,
				strokeWeight: 6
			  });
			
			  pxPath.setMap(map);

			var ctrpin = new google.maps.LatLng(#midlat#,#midlng#);
			var stpin = new google.maps.LatLng(#res[1][1]#, #res[1][2]#);
			var endpin = new google.maps.LatLng(#res[arraylen(res)][1]#, #res[arraylen(res)][2]#);			
			
			var markerend = new google.maps.Marker({
                 map:map,
                 draggable:false,
                 animation: google.maps.Animation.DROP,
                 title:'End',
                 position: endpin
             });
                        			

			var markerstrt = new google.maps.Marker({
                map:map,
                draggable:false,
                animation: google.maps.Animation.DROP,
                title:'Start',
                position: stpin
            });                         
			markerstrt.setIcon('green-dot-a.png');
			markerend.setIcon('green-dot-b.png');
	
		 var customTiles = {
			
		  getTileUrl: function(coord, zoom) {
			cordstr = ''+coord;
			crdu = cordstr.replace(',','_').replace('(','').replace(')','').replace(' ','');
			return "/docs/gmaps/img_" +crdu+'.png';		
		  },
		
			tileSize: new google.maps.Size(256, 256),
			isPng: true
		  };
		  var custTileType = new google.maps.ImageMapType(customTiles);
		  map.overlayMapTypes.insertAt(0, custTileType);			  
			  
        }
                      
		 $(document).ready(function() {
			   gmapsinitialize();
			     
		});						
                      
        </script>
		<div id="map_canvas" style="width:100%; height:350px"></div>	                          
		<cfif showFloorMap>
        	<cfset showFloor(getLoc)>
        </cfif>
       </cfoutput>         
	</cfif>
</cffunction>


<cffunction name="getClosestVertexToLatLng">
<cfargument name="latlngstring">
	<cfset mylat = listfirst(latlngstring)>
	<cfset mylng = listlast(latlngstring)>
	<cfset latspan = abs(sy-ey)>
	<cfset longspan = abs(sx-ex)>


    <cfset xPct = abs(mylng-sx)/longspan>
    <cfset yPct = abs(mylat-sy)/latspan>
    
    <cfset pixelX = xPct*mapPixelWidth>
    <cfset pixelY = yPct*mapPixelHeight>
            
     
    <cfif pixelX lt 0 or pixelY lt 0 or pixelX gt mapPixelWidth or pixelY gt mapPixelHeight>
        <cfreturn "Error: the coordinates  are not on the map.">
    </cfif>
            
    <cfquery name="getClosestVert" datasource="phonebook" maxrows="1">
        select mapx, mapy, label, vertex_id from floor_vertex
        where label != '' and floor_id = 0
        order by ABS(mapx-#pixelX#)+ABS(mapy-#pixelY#) asc
    </cfquery>	
    <cfreturn getClosestVert.vertex_id>
</cffunction>


<cffunction name="showFloor">
<cfargument name="fiquery">
	
    
    <cfset directionTo = fiquery.floc_id>
	
    <cfquery name="getEntrance" datasource="phonebook">
       	select fi.loc_id, fl.floc_id from  floor_image_loc fl join floor_image fi on fl.fid = fi.fid where fi.loc_id = <cfqueryparam value="#fiquery.loc_id#">
        	and (roomname = "Main Entrance" or roomnum = "Main Entrance" )
    </cfquery>

	<cfif getEntrance.recordcount is 0>
    	<!---<cfoutput>Error, not found #fiquery.loc_id#</cfoutput> 
		do nothing, room loc was not found--->
        <cfreturn>
    <cfelse>
		<cfset directionFrom = getEntrance.floc_id>
    </cfif>
    
	<cfset persistQS = "ib=#fiquery.loc_id#&df=#directionFrom#&dt=#directionTo#&u=Either">

	<cfset generator = createobject("Component","web.src.wwwroot.invoke_custom").init("c.phonebook.directions.generate_maps").init("rooms")>                    

	<cfset res = generator.get(directionFrom,directionTo,"Either")>

    <cfif isdefined("res.message") and find("Error",res.message)>
    	<!---<cfoutput>could not calc route #directionFrom#,#directionTo#</cfoutput>
        ignore--->
    <cfelse>

		<cfset ct = 1>
		<cfset bufferPct = .6>
       
		<cfoutput>     
           
        	<script type="text/javascript">
            	var floorsArr = [];
                function addFloor ( id, sx, sy, ex, ey, w, h ) {
					flrarr = [id, sx, sy, ex, ey, w, h];
					floorsArr.push(flrarr);
				}
				$(document).ready(buildFloorArr);				
				$(window).resize(zoomFloors);
				
				//$(window).bind("load", buildFloorArr);
				
				function buildFloorArr() {
					<cfloop list="#res.floorOrder#" index="f">
		            	<cfset thisFloor = res["f"&f]>
						addFloor('fl#ct#',#thisFloor.viewbound_sx#,#thisFloor.viewbound_sy#,#thisFloor.viewbound_ex#,#thisFloor.viewbound_ey#,#thisFloor.imwidth#,#thisFloor.imheight#);
						<cfset ct = ct+1>						
					</cfloop>
					zoomFloors();
				}
				
				function zoomFloors() {
					
					squareSide = $("li").width()-15;
					for (var i = 0; i < floorsArr.length; i++) {		
						id = floorsArr[i][0];
						sx = floorsArr[i][1];
						sy = floorsArr[i][2];
						ex = floorsArr[i][3];
						ey = floorsArr[i][4];
						w = floorsArr[i][5];
						h = floorsArr[i][6];
						
						document.getElementById(floorsArr[i][0]+'_cont').style.height = (squareSide)+'px'; 
						imgel = document.getElementById(floorsArr[i][0]);
						imgela = document.getElementById(floorsArr[i][0]+'_a');

						xSpan = ex-sx;
						ySpan = ey-sy;
						
						boxXScale = (squareSide*#bufferPct#)/xSpan;
						boxYScale = (squareSide*#bufferPct#)/ySpan;
							
						if (boxXScale < boxYScale ) 
							stretchPct = boxXScale;
						else 
							stretchPct = boxYScale;
						if (stretchPct > 1)
							stretchPct = 1;	
							
						//resize image, and set all values to new proportion
						neww = stretchPct * w;
						if (neww < squareSide ){ 
							neww = squareSide+15;
							stretchPct = neww/w;	
						}
					
						
						imgel.style.width = neww + 'px';
						sx = sx*stretchPct;
						sy = sy*stretchPct;
						ex = ex*stretchPct;
						ey = ey*stretchPct;
						xSpan = ex-sx;
						ySpan = ey-sy;
						
						newx = sx-(squareSide-xSpan)/2;
						newy = sy-(squareSide-ySpan)/2;
							
						if (newx > 0) {
							imgela.style.marginLeft = (-newx) + 'px';
						}
						if (newy > 0) {
							imgela.style.marginTop = (-newy) + 'px';
						}
					}
				}
            </script>
	    	<cfset ct = 1>
            
        	<div id="testlen" style="width:100%;"></div>
            <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">#res.title#    </li>          
            <cfloop list="#res.floorOrder#" index="f">
            	<cfset thisFloor = res["f"&f]>
                <cfif len(thisfloor.txt)><li class="ui-li ui-li-divider ui-bar-b ui-corner-top" data-role="list-divider">#thisFloor.txt#</li></cfif>               

                 <li class="ui-bar-c ui-corner-all ui-shadow" style="padding:4px;">                
                    	<div style="width:100%;overflow:hidden" id="fl#ct#_cont">
                            <div id="fl#ct#_a"><a href="?imagefocus=#thisFloor.image#&#persistQS#"><img src="#variables.config.dir_cached_image##thisFloor.image#" id="fl#ct#"></a></div>
                        </div>
                 </li>
				<cfset ct = ct+1>
            </cfloop>
		</cfoutput>
   </cfif>
</cffunction>
