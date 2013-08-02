<cfset attributes.cfpath ="/cspot/phonebook/directions/shared.cfm">
<cfinclude template="/web/src/wwwroot/invoke_custom.cfm"> 

<cfinclude template="wf-shared.cfm">

<cfset url.dir = "rooms">


<cfparam name="attributes.fullsite" default="http://www.scu.edu" />
<cfoutput>
   <cfparam name="url.imagefocus" default="">
   <cfparam name="url.dir" default="">
	<cfparam name="form.inbuild" default="">
	<cfparam name="form.dirFrom" default="">
	<cfparam name="form.dirTo" default="">
	<cfparam name="form.using" default="">
	<cfparam name="form.latlong" default="">
	
	<cfif isdefined("url.ib") and isdefined("url.u") and isdefined("url.df") and isdefined("url.dt")>
		<cfset form.inbuild = url.ib>
		<cfset form.using = url.u>
		<cfset "form.dirFrom#url.ib#" = url.df>
		<cfset "form.dirTo#url.ib#" = url.dt>
		<cfset "form.dirFrom" = url.df>
		<cfset "form.dirTo" = url.dt>
	</cfif>
	
	<cfif len(form.inbuild)>
	    <cfparam name="form.dirFrom#form.inbuild#" default="">
	    <cfparam name="form.dirTo#form.inbuild#" default="">
	    <cfset form.dirFrom = evaluate("form.dirFrom#form.inbuild#")>
	    <cfset form.dirTo = evaluate("form.dirTo#form.inbuild#")>
	</cfif>
	
	<cfset persistQS = "ib=#form.inbuild#&df=#evaluate("form.dirfrom#form.inbuild#")#&dt=#evaluate("form.dirto#form.inbuild#")#&u=#form.using#">
	
   <cfset variables.scripts = 'carousel' />
   <cfset attributes.pagetype = 'home' />
   <cfinclude template="/web/apps/mobile/includes/_head.cfm" />
       <div data-role="content" id="homecontent">
           <div class="content-primary">
           <ul id="navHome" data-role="listview">
           	<cfif len(url.imagefocus)>
				<cfset imgFocus()>
			<cfelseif isdefined("form.submitted")>
               	<cfif (len(form.dirFrom) or len(form.latlong)) and len(form.dirTo)>
					<cfset getAllData()>
                       <cfset showMaps()>
                   <cfelse>
                   	 <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading">Error: please select to and from locations</li>
                   </cfif>
               <cfelseif len(url.dir)>
                   <cfset selectLocations()>
               </cfif>
           </ul>
           </div>
			<div class="content-secondary">
			<cfset mainMenu()>
			</div>	
       </div><!-- /content -->
   <cfinclude template="/web/apps/mobile/includes/_foot.cfm" />
</cfoutput>



<cffunction name="imgFocus">
	<cfoutput>
         <a href="?#persistQS#" data-role="button" data-icon="arrow-l">back to directions</a> 
		 <img src="#variables.config.dir_cached_image##url.imagefocus#">
        
    </cfoutput>
</cffunction>

<cffunction name="selectLocations">
	<cfoutput>
        <form id='directionsForm' name='directionsForm' action="?" method="post" class="ui-body ui-body-c">
        	<input type="hidden" name="submitted" value="1" />
        	
       	
           	<cfset getAllData()>              

           	<li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">Directions within buildings</li>
               <label for="inBuild" class="ui-hidden-accessible">in building :</label>
               
               <select name="inBuild" id="inBuild" onChange="populateRooms(this);">
                   <option value="0"> in building... </option>
                   <cfloop query="getDistBldg">
                       <option value="#loc_id#" <cfif form.inBuild is loc_id>selected</cfif>>#locname#</option>
                   </cfloop>
               </select>
               
               <li id="locopts0">
                   <select name="dirfrom" id="dirfrom">
                       <option value="">from room...</option>
                       <option value="" disabled>select a building</option>                   
                   </select>
                   <select name="dirfrom" id="dirfrom">
                       <option value="">to room...</option>
                       <option value="" disabled>select a building</option>                   
                   </select>
               </li>

                <cfloop query="getDistBldg">
                   <li id="locopts#loc_id#" <cfif not form.inbuild is loc_id>style="display:none"<cfelse>style="display:inline"</cfif>>
                     <select name="dirfrom#loc_id#">
                           <option value="">from room...</option>
                           <option></option>
                           <cfset showRooms("dirFrom#loc_id#",loc_id)>                        
                      </select>
                      <select name="dirTo#loc_id#">
                       <option value="">to room...</option>
                           <cfset showRooms("dirTo#loc_id#",loc_id)>                        
                      </select>                       
                   </li>
               </cfloop>
               <li>using 
               <select name="using">
               	<option value="Stair">stairs</option>
               	<option value="Elevator">elevators</option>
               	<option value="either">either stairs or elevator</option>
               </select>
               </li>                
               <li><input type="submit" name="go" id="search-basic" value="Map It &raquo;"  data-icon="star" /></li>
			<script type="text/javascript">
                   var lastloc = '0';
                   function populateRooms(sel) {
                       loc = sel.options[sel.selectedIndex].value;				
                       document.getElementById('locopts'+loc).style.display = 'inline';
                       if (lastloc != '') {
                           document.getElementById('locopts'+lastloc).style.display = 'none';
                       }
                       lastloc = loc;
                   }
				
							
               </script>           

        </form>

	</cfoutput>
</cffunction>

<cffunction name="showRooms">
<cfargument name="field">
<cfargument name="location">
	<cfparam name="form.#field#" default="">
	<cfquery name="getLoc" dbtype="query">
    	select * from getRooms where loc_id = <cfqueryparam value="#location#" cfsqltype="cf_sql_numeric">  order by floornum, roomname, roomnum        
    </cfquery>

	<cfoutput query="getLoc" group="floornum">
        <optgroup label="Floor #floornum#"></optgroup>
        <cfoutput>
        	<cfif not refind("[0-9]{3}\-[0-9]{3}",roomnum)>
                <option value="#floc_id#" <cfif evaluate("form.#field#") is floc_id>selected</cfif>>#roomname#<cfif not find(roomnum,roomname)><cfif len(roomname)> - </cfif>#roomnum#<cfelse></cfif></option>
            </cfif>
        </cfoutput>
    </cfoutput>

</cffunction>

<cffunction name="showMaps">
	<cfif url.dir is "campus"><cfset form.using = "Entrance"></cfif>

	<cfset generator = createobject("Component","web.src.wwwroot.invoke_custom").init("c.phonebook.directions.generate_maps").init(url.dir)>                    

    <cfif not len(form.dirfrom) and len(form.latlong)>
    	<cfset fromVert = getClosestVertexToLatLng(form.latlong)>
    
        <cfquery name="gettovert" datasource="phonebook">
            select * from floor_vertex where campus_loc_id = <cfqueryparam value="#form.dirTo#">        	
        </cfquery>    
		<cfset res = generator.get(fromVert, gettovert.vertex_id,"Stairs","vert")>
    <cfelse>               
		<cfset res = generator.get(form.dirFrom,form.dirTo,form.using)>
    </cfif>


    <cfif isdefined("res.message") and find("Error",res.message)>
         <cfoutput>              
            <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">#res.message#</li>               
		</cfoutput>
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
            
        <li id="debug"></li>
        	<div id="testlen" style="width:100%;"></div>
            <li class="ui-li ui-li-divider ui-bar-b ui-corner-top" role="heading" data-role="list-divider">#res.title#    </li>          
            <cfloop list="#res.floorOrder#" index="f">
            	<cfset thisFloor = res["f"&f]>
                <cfif len(thisfloor.txt)><li class="ui-li ui-li-divider ui-bar-b ui-corner-top" data-role="list-divider">#thisFloor.txt#</li></cfif>               

                 <li class="ui-bar-c ui-corner-all ui-shadow" style="padding:4px;">                
                    	<div style="width:100%;overflow:hidden" id="fl#ct#_cont">
                            <div id="fl#ct#_a"><a href="?imagefocus=#thisFloor.image#&#persistQS#"><img src="#variables.config.dir_cached_image##thisFloor.image#" id="fl#ct#"></a></div>
                        </div>
                 	<!---<a href="?imagefocus=#thisFloor.image#&#persistQS#" data-role="button" data-icon="arrow-r">expand
                    </a>--->
                 </li>
                 <!---<script type="text/javascript">
				 	addFloor('fl#ct#',#thisFloor.viewbound_sx#,#thisFloor.viewbound_sy#,#thisFloor.viewbound_ex#,#thisFloor.viewbound_ey#,#thisFloor.imwidth#,#thisFloor.imheight#);
                 </script>--->
                 
                 <!---
				 SMALL IMAGE VERSION                 
                 <div class="ui-bar-c ui-corner-all ui-shadow" id="img#ct#">
                    <a href="?imagefocus=#thisFloor.image#&#persistQS#" data-role="button" data-icon="arrow-r"><img src="#variables.config.dir_cached_image##thisFloor.image#" style="width:90%"></a>
                 </div>--->
				<cfset ct = ct+1>
            </cfloop>
		</cfoutput>

   </cfif>
	
</cffunction>

