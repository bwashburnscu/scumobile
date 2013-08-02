<cfcomponent>
	<cfset variables.adminGroupID = 22>

	<cffunction name="init" access="public">
	<cfargument name="ldapObj" required="yes">
    
		<cfset variables.ldapObj = ldapObj>
		<cfset variables.isSystemAdmin = false>
        <cfset variables.isRoomAdmin = false>
        
    	<cfif ldapObj.isLoggedIn()>
			<cfset variables.public_rooms_only = false>
            
			<cfset variables.myGroups = ldapObj.getAttribute("groups")>
            <cfset variables.myClass = ldapObj.getAttribute("class")>
            <cfset variables.myEmail = ldapObj.getAttribute("username")&"@scu.edu">
            
            <cfif listfind(variables.myGroups,variables.adminGroupID)>
                <cfset variables.isSystemAdmin = true>
            </cfif>
		<cfelse>
			<cfset variables.public_rooms_only = true>            
		</cfif>

		<cfreturn this>
	</cffunction>


    <cffunction name="roomsAvailable" returnType="query" output="no" >
        <cfargument name="range_start" default="" required="true">
        <cfargument name="range_end" default="" required="true">
    	<cfargument name="room_id" default="" required="false">
    	<cfargument name="loc_id" default="" required="false">
    	<cfargument name="ldapOb" default="" required="false">
    
        <cfquery name="rooms" datasource="phonebook">
            select roomname, room_id, roomname_common
            from rw_room room <!---left join floor_image_loc floc on room.floc_id = floc.floc_id--->
            where room_id not in 
            (
                select distinct room_id from rw_res where 			
                   ( res_start >= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_start <= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
                   or ( res_end >= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_end <= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
                   or ( res_start <= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_end >= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
            )       
            <cfif variables.public_rooms_only>
				and cat_id in (1,2,3,7)
            <cfelseif not variables.isSystemAdmin>
                and (access_reserve = 0 or access_reserve is null
                or access_reserve in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                or access_admin in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                )
			</cfif>
            <cfif len(loc_id)>
				and loc_id = <cfqueryparam value="#loc_id#">
			</cfif>
            order by roomname
        </cfquery>

    	<cfreturn rooms>
	</cffunction>

    <cffunction name="getReservations" returnType="query" output="no" >
        <cfargument name="range_start" default="" required="true">
        <cfargument name="range_end" default="" required="true">
    	<cfargument name="room_id" default="" required="true">

    
        <cfquery name="res" datasource="phonebook">
            select *
            from rw_res
            where room_id = <cfqueryparam value="#room_id#">
            and 
        	(
               ( res_start >= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_start <= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
               or ( res_end >= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_end <= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
               or ( res_start <= <cfqueryparam value="#range_start#" cfsqltype="cf_sql_timestamp"> and res_end >= <cfqueryparam value="#range_end#" cfsqltype="cf_sql_timestamp"> )
			)
            order by res_start
        </cfquery>

    	<cfreturn res>
	</cffunction>




	<cffunction name="getRooms">
    <cfargument name="loc_id" required="no" default="">
    <cfargument name="room_id" required="no" default="">
    <cfargument name="ldapOb" default="" required="false">

    
            <cfquery name="rooms" datasource="phonebook">
            select * from rw_room  where  1 = 1
			   <cfif not variables.isSystemAdmin>
                    and (access_reserve = 0 or access_reserve is null
                    or access_reserve in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                    or access_admin in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                    or room_id = <cfqueryparam value="#variables.memento.room_id#">
                    )
                </cfif>
            <cfif len(loc_id)>
				and loc_id = <cfqueryparam value="#loc_id#">
			</cfif>
            <cfif len(room_id)>
				and room_id = <cfqueryparam value="#room_id#">
			</cfif>
             order by roomname
        </cfquery>
    	<cfreturn rooms>
	</cffunction>
    

	<cffunction name="getBuildings">
    <cfargument name="loc_id" required="no" default="">
    	<cfquery name="getb" datasource="phonebook">
        	select loc_id, if( length(commonName) > 0,commonName,name) as name, abbrev	 
            from location where loc_id in (select distinct loc_id from rw_room)
            <cfif len(loc_id)>and loc_id = <cfqueryparam value="#loc_id#"></cfif>
             order by name
        </cfquery>
        <cfreturn getb>
    </cffunction>
</cfcomponent>
