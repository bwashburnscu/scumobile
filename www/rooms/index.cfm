<cfparam name="url.loc" default="" />
<cfparam name="url.auth" default="" />
<cfparam name="url.room" default="" />
<cfparam name="url.type" default="" />
<cfparam name="url.task" default="" />
<cfparam name="url.action" default="" />
<cfparam name="form.strt" default="y">
<cfparam name="form.room_id" default="">
<cfparam name="attributes.fullsite" default="http://www.scu.edu/rooms" />
<cfparam name="attributes.sitecookie" default="rooms" />

<cfset ldap = createobject("component","utility.novell.customcf.login").init()> 

<cfset variables.roomQ = createobject("component","rooms").init(ldap)>

<cfset variables.loggedIn = ldap.isLoggedIn()>

<cfparam name="form.hostname" default="#ldap.getAttribute("fname")# #ldap.getAttribute("lname")#">
<cfparam name="form.hostemail" default="#ldap.getAttribute("username")#@scu.edu">

<cfif len(url.loc)>
    <cfset thisBuild = variables.roomQ.getBuildings(url.loc)>
</cfif>

<cfinclude template="/includes/_head.cfm" />

	<div data-role="content">
		<div>	
		<cfoutput>
			<cfif len(url.auth)>
				<cfset requireLogin()>
			</cfif>
		    
		    <cfif len(url.type)>
		
				<cfset requireLogin()>
		
		        <cfif not len(url.task)>
		            <cfset url.task = "new">
		        </cfif>
				<cfif not len(form.room_id)>
					<cfset form.room_id = url.room>
				</cfif>
		        
		        <cfset obj = createObject("Component","reservation").init(ldap)/>
		        <cfset obj.run()>
		      
		        
		    <cfelseif len(url.action)>
		    
		    	<cfswitch expression="#url.action#">
		        	<cfcase value="immediate">
		        		<cfif not len(url.loc)>
		                	<cfset chooseBuilding()>
						<cfelse>
		                	<cfset showImmediatelyAvailable()>
						</cfif>
		            </cfcase>
		        	<cfcase value="future">
		        		<cfif not len(url.loc)>
		                	<cfset chooseBuilding()>
						<cfelse>
		                	<cfset timeChoices()>
						</cfif>
		            </cfcase>
		        	<cfcase value="future_time">
						<cfset processParams()>
		                <cfif not len(url.task) or url.task is "edit">
							<cfset enterTime()>            
						<cfelse>
							<cfset doTimeSearch()>            
						</cfif>
		            </cfcase>
		        	<cfcase value="future_browse">
						<cfset processParams()>
		                <cfif not len(url.task) or url.task is "edit">
							<cfset browseRoom()>            
						<cfelse>
							<cfset doBrowseSearch()>            
						</cfif>
		            </cfcase>
		        	<cfcase value="myres">
		            	<cfset requireLogin()>
		            </cfcase>
		        </cfswitch>
		        
			<cfelse>
		    	<cfset mainMenu()>
			</cfif>   
		</cfoutput>
		</div>
	</div><!-- /content -->
	

<cfinclude template="/includes/_foot.cfm" />



<cffunction name="requireLogin">
    <cfinvoke component="#ldap#" method="protect" returnvariable="hasAccess">
        <cfinvokeargument name="isMobile" value="true">
    </cfinvoke>
    <cfreturn hasAccess>
</cffunction>


<cffunction name="mainMenu">
<cfoutput>
    <p>Reserve conference rooms and study spaces in the Library and Lucas Hall.</p>
    <ul data-role="listview" data-inset="true">
    	<li><a href="?action=immediate">Available Now</a></li>
    	<li><a href="?action=future">Future Reservation</a></li>
    	<li><a href="?type=reservation&task=menu" rel="external">Edit My Reservations</a></li>    
    </ul>
</cfoutput>
</cffunction>

<cffunction name="timeChoices">
<cfoutput>
	<h3>Make Future Reservation</h3>
    <h4>#thisBuild.name# </h4>
    <ul id="home" data-role="listview">
    	<li><a href="?action=future_time&loc=#url.loc#">Enter a Specific Time</a></li>
    	<li><a href="?action=future_browse&loc=#url.loc#">Browse Room Availability</a></li>
    </ul>
</cfoutput>
</cffunction>

<cffunction name="enterTime">
<cfoutput>
    <h3>Make Future Reservation in #thisBuild.name#</h3>
    <h4>Enter a time window to see which rooms are available:</h4>
	<cfset showForm(false,true)>
    <cfif not variables.loggedIn>
        <p>(Searching Public Rooms. To see protected rooms that you have access to, <a href="?action=future_time&loc=#url.loc#&auth=1" rel="external">login</a>)</p>
	</cfif>
</cfoutput>
</cffunction>

<cffunction name="browseRoom">
<cfoutput>
    <h3>Make a Future Reservation in #thisBuild.name#</h3>
    <p>Select a room and date to see when it is available:</p>
	<cfset showForm(true, false, false)>
    <cfif not variables.loggedIn>
        <p>(Searching Public Rooms. To see protected rooms that you have access to, <a href="?action=future_browse&loc=#url.loc#&auth=1" rel="external">login</a>)</p>
	</cfif>
</cfoutput>
</cffunction>


<cffunction name="showImmediatelyAvailable">
<cfoutput>
	<cfset range_start = "#dateformat(now(),"yyyy-mm-dd")# #timeformat(now(),"HH:mm:ss")#">
    <cfset range_end = "#dateformat(now(),"yyyy-mm-dd")# #timeformat(dateadd("h",1,now()),"HH:mm:ss")#">
    
    <cfset roomsavail = variables.roomQ.roomsAvailable(range_start,range_end,"",url.loc)>
    
    <p>The following rooms are available for the next hour. Click a room name to reserve it (login required).</p>
    <cfif not variables.loggedIn>
        <p>(Showing Public Rooms. To see protected rooms that you have access to, <a href="?action=#url.action#&loc=#url.loc#&auth=1" rel="external">login</a>)</p>
	</cfif>
    
    <cfif roomsavail.recordcount is 0>
		No rooms currently available.
	</cfif>
    <ul id="home" title="Rooms Available" data-role="listview" data-inset="true">
    	<cfloop query="roomsavail">
        	<li><a href="?loc=#url.loc#&room=#room_id#&action=#url.action#&type=reservation" rel="external">#roomname#<cfif len(roomname_common)> - #roomname_Common#</cfif></a></li>
        </cfloop>
    </ul>
</cfoutput>
</cffunction>



<cffunction name="chooseBuilding">
<cfoutput>

    <cfset buildings = variables.roomQ.getBuildings()>

    <p>Select a building to view  rooms</p>
    <ul id="home" title="Select a Building" data-role="listview" data-inset="true">
    	<cfloop query="buildings">
        	<li><a href="?loc=#loc_id#&action=#url.action#">#name#</a></li>
        </cfloop>
    </ul>
</cfoutput>
</cffunction>



<cffunction name="processParams">
	<cfset resOb = createobject("component","reservation").init(ldap)>
	<cfset resOb.getMemento_Form()>

</cffunction>

<cffunction name="showForm">
<cfargument name="showRoomSelect" default="false">
<cfargument name="showTimeSelect" default="false">
<cfargument name="showDateSelect" default="false">
<cfoutput>
    <form method="post" action="?action=#url.action#&loc=#url.loc#&task=save" id="resForm">
    	<cfif showRoomSelect>
        	<cfset allrooms = variables.roomQ.getrooms(url.loc)>
            <p><strong>Room</strong> <br>
                <div class="fieldrow">
                    <select name="room_id">
                        <cfloop query="allrooms">
                            <option value="#room_id#">#roomname#</option>
                        </cfloop>
                    </select>       
                </div>
            </p>     
		</cfif>
        
		<cfset resOb = createobject("component","reservation").daySelect(showTimeSelect,showDateSelect)>
        <input type="submit" value="search &rsaquo;" />
    </form>                	
    <cfif not variables.loggedIn>
        <p>(Showing Public Rooms. To see protected rooms that you have access to, <a href="?action=#url.action#&loc=#url.loc#&auth=1">login</a>)</p>
	</cfif>
    
</cfoutput>
</cffunction>


<cffunction name="doTimeSearch">
<cfoutput>
    <div class="nav"><a href='/'>SCU</a> &rsaquo; <a href='/rooms'>Reservations</a> &rsaquo; <a href='?action=future'>Future</a> &rsaquo; <a href="?action=future&loc=#url.loc#">#thisBuild.abbrev#</A> &rsaquo; <a href="?action=future_time&loc=#url.loc#">Time</A></div>

	<h4>The following rooms are available 
    	<cfif dateformat(form.start_date) is dateformat(form.end_date)>
			on <strong>#dateformat(form.start_date,"mmm. d, yyyy")#</strong> from <strong>#timeformat(form.start_time)# to #timeformat(form.end_time)#</strong>
		<cfelse>
			from <strong>#dateformat(form.start_date,"mmm. d, yyyy")# at #timeformat(form.start_time)#</strong> to <strong>#dateformat(form.end_date,"mmm. d, yyyy")# #timeformat(form.end_time)#</strong>
		</cfif>
    </h4>
    <cfset roomsavail = variables.roomQ.roomsAvailable("#dateformat(form.start_date)# #timeformat(form.start_time)#","#dateformat(form.end_date)# #timeformat(form.end_time)#","",url.loc)>
    <ul id="home" title="Rooms Available" data-role="listview" data-inset="true">

    <cfloop query="roomsavail">
        <li><a href="?loc=#url.loc#&room=#room_id#&action=#url.action#&type=reservation&dur=#form.duration#&ds=#urlencodedformat("#dateformat(form.start_date)# #timeformat(form.start_time)#")#">#roomname#<cfif len(roomname_common)> - #roomname_Common#</cfif></a></li>
    </cfloop>
    </ul>
    
</cfoutput>
</cffunction>


<cffunction name="doBrowseSearch">
<cfset thisroom = variables.roomQ.getrooms(url.loc,form.room_id)>

<cfoutput>
	<h4>The following times are available for <strong>#thisroom.roomname#</strong> on <strong>#dateformat(form.start_date,"mmm. d, yyyy")#</strong>. Click a free block to make a reservation in that time frame.</h4>
    
	<cfset starttm = dateformat(form.start_date,"yyyy-mm-dd") & " 12:00 AM">
	<cfset endtm = dateformat(form.start_date,"yyyy-mm-dd") & " 11:59 PM">

    <cfset timesavail = variables.roomQ.getReservations(starttm,endtm,form.room_id)>
    <ul id="home" title="Times Available" data-role="listview">
  
  	<cfset startFree = starttm>
  	<cfloop query="timesavail">
    	<cfif timeformat(startfree) is not timeformat(res_start) and datediff("n",startfree,res_start) gt 10>
            <li><a href="?loc=#url.loc#&room=#form.room_id#&action=#url.action#&type=reservation">Free from #timeformat(startfree,"h:mm")# <cfif timeformat(startfree,"tt") is not timeformat(res_start,"tt") or startFree is "12:00 AM">#timeformat(startfree,"tt")#</cfif> to #timeformat(res_start,"h:mm tt")#</a></li>
		</cfif>
		<cfset startfree = res_end>
    </cfloop>
	
	<cfif isdate(timesavail.res_end)>
		<cfif datecompare(timesavail.res_end,endtm) is -1>
	        <li><a href="?loc=#url.loc#&room=#form.room_id#&action=#url.action#&type=reservation">Free from #timeformat(startfree,"h:mm tt")# to midnight</a></li>
		</cfif>
	<cfelse>
		<li><a href="?loc=#url.loc#&room=#form.room_id#&action=#url.action#&type=reservation">Free from #timeformat(startfree,"h:mm tt")# to midnight</a></li>
	</cfif>
  
    </ul>
</cfoutput>
</cffunction>


