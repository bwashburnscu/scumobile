<cfset variables.config.dir_cached_image = "/images/wf_cache/">
<cfset variables.config.campus_image = "/map/images/campus_dec2012.jpg">

<cfset sy = 37.353> 
<cfset sx = -121.94485> 
<cfset ey = 37.345053>
<cfset ex = -121.93062>

<cfset mapPixelWidth = 1800>
<cfset mapPixelHeight = 1278>





<cffunction name="mainMenu">
	<cfoutput>
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
	</cfoutput>
</cffunction>


<cffunction name="getAllData">
	<cfparam name="form.using" default="">

    <cfquery name="getfloors" datasource="phonebook">
        select * from floor_image  where loc_id = 144  order by stackpos
    </cfquery>
    
    <cfquery name="verticies" datasource="phonebook">
        select * from floor_vertex 
    </cfquery>
    <cfquery name="verticiesWrooms" dbtype="query">
        select * from verticies where floc_id is not null
    </cfquery>
    
    <cfquery name="getAll" datasource="phonebook">
        select * from floor_vertex v left join floor_edge e on v.vertex_id = e.from_vertex
        left join floor_image_loc floc on floc.floc_id = v.floc_id
        where specialtype is null
        <cfif form.using is "Stair">
            or specialtype != <cfqueryparam value="Elevator">        
        </cfif>
        <cfif form.using is "Elevator">
            or specialtype != <cfqueryparam value="Stair">
        </cfif>
        order by floor_id, roomnum, roomname
    </cfquery>
    
    <cfquery name="getDistPoints" dbtype="query">
        select distinct vertex_id,label,mapx,mapy, floor_id as fid,floc_id from verticies
    </cfquery>
    
    
    <cfquery name="getRooms" datasource="phonebook">
        select distinct if(length(commonName)>0,l.commonName,l.name) as locname, l.loc_id, fi.fid, fi.image_path, fi.floornum, floc.roomnum, floc.roomname, floc.floc_id
        from floor_image fi 
            left join location l on fi.loc_id = l.loc_id   
            left join floor_image_loc floc on floc.fid = fi.fid
        where floc.floc_id in (<cfqueryparam value="#valuelist(verticiesWrooms.floc_id)#" list="yes">)
        order by if(length(commonName)>0,l.commonName,l.name) , floornum, roomname
    </cfquery>
    
    <cfquery name="getDistBldg" dbtype="query">
        select distinct loc_id, locname from getrooms
    </cfquery>
    
    <cfquery name="getspecialEdges" dbtype="query">
        select distinct * from getAll where specialtype = 'Other Link'
    </cfquery>
    <cfset specialEdges = valuelist(getspecialEdges.to_vertex)>
    
</cffunction>
