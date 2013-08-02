<cfparam name="attributes.fullsite" default="http://www.scu.edu/map" />
<cfparam name="attributes.sitecookie" default="map" />
<cfparam name="attributes.pagetitle" default="Campus Map" />

<cfparam name="url.loc_id" default="0" />

<cfparam name="url.org_id" default="0" />

<cffunction name="getLocation">
	<cfargument name="locid" default="" required="yes" type="numeric" />
    <cfquery name="qlocation" datasource="phonebook">
    select *
    from location
    where 1=1
    	and loc_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.locid#" />
    </cfquery>
    <cfreturn qlocation />
</cffunction>


<cffunction name="getOrgLocation">
	<cfargument name="orgid" default="" required="yes" type="numeric" />
    <cfquery name="qorglocation" datasource="phonebook">
    select o.name, l.gps_latitude, l.gps_longitude
    from location l, organization o
    where 1=1
    	and l.loc_id = o.loc_id
    	and o.org_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.orgid#" />
    </cfquery>
    <cfreturn qorglocation />
</cffunction>
