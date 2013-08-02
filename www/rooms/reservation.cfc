<cfcomponent extends="rooms.customcf.reservation">

	<cffunction name="showmenu">
    	<cfoutput>
            <!---<div class="nav"><a href='/'>SCU</a> &raquo; <a href='/rooms'>Reservations</a> &raquo; <a href='?type=reservation&task=menu'>My Reservations</a></div>
            <div xmlns="" class="page">--->
			<h4>My Reservations</h4>
            
            <cfquery name="getMyReservations" datasource="phonebook">
                select res.*, room.roomname from rw_res res join rw_room room on res.room_id = room.room_id where hostemail = <cfqueryparam value="#variables.myemail#">
                and (res_start >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp"> or res_end >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">) order by res_start
            </cfquery>

			<cfoutput>
                <ul data-role="listview" data-inset="true">
                    <cfloop query="getMyReservations">
                        <li><a href="?type=reservation&task=edit&id=#res_id#&book=#rw_booking_id#"><cfif datecompare(res_start,now(),"d") is 0>Today<cfelseif datecompare(res_start,dateadd("d",1,now()),"d") is 0>Tomorrow<cfelse>#dateformat(res_start,"m/d/yy")#</cfif> 
                            <cfif dateformat(res_start) is dateformat(res_end)>
                                <cfif timeformat(res_start,"t") is timeformat(res_end,"t")>
                                    #timeformat(res_start,"h:mm")# - #timeformat(res_end,"h:mm tt")#:
                                <cfelse>
                                    #timeformat(res_start,"h:mm tt")# - #timeformat(res_end,"h:mm tt")#:
                                </cfif>
                            <cfelse>
                                #timeformat(res_start,"h:mm tt")# to <cfif datecompare(res_end,now(),"d") is 0>Today<cfelseif datecompare(res_end,dateadd("d",1,now()),"d") is 0>Tomorrow<cfelse>#dateformat(res_end,"m/d/yy")#</cfif>  #timeformat(res_end,"h:mm tt")#:
                            </cfif></strong>
                        #roomname# - #purpose#</a>
                        </li>
                    </cfloop>
                    <cfif getMyReservations.recordcount is 0>
                        <li>You do not have any upcoming reservations.</li>
                    </cfif>
                    <li><a href="?action=immediate">New Immediate Reservation</a></li>
                    <li><a href="?action=future">New Future Reservation</a></li>
                    
                </ul>
            </cfoutput>

		</cfoutput>
    </cffunction>

    <cffunction name="getMemento_DB">
        <cfif len(url.id) and isnumeric(url.id)>		
            <cfquery name="getc" datasource="#variables.dsn#">
                select * from #variables.table# where #variables.identifier# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.id#">
            </cfquery>
            <cfset variables.memento = getc>
            <cfif getc.recordcount is 0 and isdefined("url.book")>
                <cfquery name="getc" datasource="#variables.dsn#">
                    select * from #variables.table# where rw_booking_id = <cfqueryparam value="#url.book#">
                </cfquery>
	            <cfset variables.memento = getc>
			</cfif>
            
			<cfset setSelectedDate(variables.memento.res_start)>
            <cfset setSelectedHour(variables.memento.res_start)>
			<cfset setDuration(datediff("n",variables.memento.res_start,variables.memento.res_end))>
            
        </cfif>
        <cfreturn variables.memento> 
   </cffunction>    


    <cffunction name="getMemento_Form">
       <cfloop list="#variables.fields#" index="i">
            <cfparam name="form.#i#" default="">
        </cfloop>
        
        <cfif isdefined("url.ds") and len(url.ds)>
			<cfset setSelectedDate(url.ds)>
            <cfset setSelectedHour(url.ds)>
		</cfif>
        <cfif isdefined("url.dur") and len(url.dur)>
			<cfset setDuration(url.dur)>
		</cfif>
        
        
        <cfparam name="form.strt" default="">
        <cfparam name="form.dayBtn" default="">
        <cfparam name="form.hrBtn" default="">
        <cfparam name="form.start_date" default="">
        <cfparam name="form.start_time" default="">
        <cfparam name="form.end_time" default="">
        <cfparam name="form.end_date" default="">
        <cfparam name="form.duration" default="">
       
        <cfparam name="form.starthour" default="">
        <cfparam name="form.startMin" default="">
        <cfparam name="form.starthourAMPM" default="">
      
        <cfparam name="form.startMon" default="">
        <cfparam name="form.startDay" default="">
        <cfparam name="form.startYr" default="">
      
       
        <cfif not len(form.strt)>
			<cfset form.strt = "x">
		</cfif>
        <cfif not len(form.dayBtn)>
			<cfset form.dayBtn = "a">
		</cfif>
        <cfif not len(form.hrBtn)>
			<cfset form.hrBtn = "e">
		</cfif>
        
                
       <cfif not len(form.starthour)>
        	<cfset mnow = now()>
			<cfset nowMin = timeformat(mnow,"m")>
			<cfset nowHr = timeformat(mnow,"h")>
            <cfif nowMin gt 45>
            	<cfset form.start_time = timeformat(dateadd("n",60-nowMin,mnow),"hh:mm tt")>
			<cfelseif nowMin gt 30>
            	<cfset form.start_time = timeformat(dateadd("n",45-nowMin,mnow),"hh:mm tt")>
			<cfelseif nowMin gt 15>
            	<cfset form.start_time = timeformat(dateadd("n",30-nowMin,mnow),"hh:mm tt")>
            <cfelse>
            	<cfset form.start_time = timeformat(dateadd("n",15-nowMin,mnow),"hh:mm tt")>
			</cfif>
        <cfelse>
        	<cfset form.start_time = "#form.starthour#:#form.startmin# #form.starthourAMPM#">
		</cfif>

        <cfswitch expression="#form.strt#">
        	<cfcase value="x">
            	<cfset form.start_date = dateformat(now(),"yyyy-mm-dd")>
            	<cfset form.start_time = timeformat(now(),"hh:mm tt")>
            </cfcase>
            <cfcase value="custom">
            	<!---<cfset form.start_date = "#form.startYr#-#form.startMon#-#form.startDay#">--->
            </cfcase>
        	<cfcase value="y">
				<cfset url.task = "edit">
                <cfset form.strt = "custom">
            </cfcase>
        </cfswitch>
        <cfswitch expression="#form.dayBtn#">
        	<cfcase value="a">
            	<cfset form.start_date = dateformat(now(),"yyyy-mm-dd")>
            </cfcase>
        	<cfcase value="b">
            	<cfset form.start_date = dateformat(dateadd("d",1,now()),"yyyy-mm-dd")>
            </cfcase>
            <cfcase value="custom">
            	<cfset form.start_date = "#form.startYr#-#form.startMon#-#form.startDay#">
            </cfcase>
        	<cfcase value="c">
            	<cfif not len(form.start_date)>
					<cfset form.start_date = now()>
				</cfif>            	
				<cfset url.task = "edit">
                <cfset form.dayBtn = "custom">
            </cfcase>
        </cfswitch>
        <cfswitch expression="#form.hrBtn#">
        	<cfcase value="d">
            	<cfset form.duration = "30">
            </cfcase>
        	<cfcase value="e">
            	<cfset form.duration = "60">
            </cfcase>
        	<cfcase value="f">
            	<cfset form.duration = "120">
            </cfcase>
            <!---<cfcase value="custom">
            	<cfset form.start_date = now()>
            </cfcase>--->
        	<cfcase value="g">
				<cfset url.task = "edit">
            	<cfset form.duration = "60">                
                <cfset form.hrBtn = "custom">
            </cfcase>
        </cfswitch>

        
        <cfset form.end_date = dateformat(dateadd("n",form.duration,form.start_date & form.start_time),"yyyy-mm-dd")>
		<cfset form.end_time = dateadd("n",form.duration,form.start_date & form.start_time)>
                
		<cfset form.startYr = dateformat(form.start_date,"yyyy")>
        <cfset form.startMon = dateformat(form.start_date,"mmm")>
        <cfset form.startDay = dateformat(form.start_date,"dd")>

        <cfset form.starthour = timeformat(form.start_time,"hh")>
        <cfset form.startmin = timeformat(form.start_time,"mm")>
        <cfset form.starthourAMPM = timeformat(form.start_time,"tt")>

        <cfif not len(form.purpose)>
			<cfset form.purpose = "Mobile Reservation">
		</cfif>

		<cfset form.reminder = 60>	
        <cfset variables.memento = form>
       <cfreturn variables.memento>
    </cffunction>
    
    
    <cffunction name="setSelectedDate">
   	<cfargument name="dt" required="yes"> 
		<cfset form.start_date = dateformat(dt,"yyyy-mm-dd")>
        <cfset form.start_time = timeformat(dt,"hh:mm tt")>
    
		<cfset form.startYr = dateformat(dt,"yyyy")>
        <cfset form.startMon = dateformat(dt,"mmm")>
        <cfset form.startDay = dateformat(dt,"dd")>
        
        <cfif datecompare(dt,now(),"d") is 0>
			<cfset form.strt = 'custom'>
			<cfset form.dayBtn = 'a'>
        <cfelseif datecompare(dt,dateadd("d",1,now()),"d") is 0>
			<cfset form.strt = 'custom'>
			<cfset form.dayBtn = 'b'>
        <cfelse>
			<cfset form.strt = 'custom'>
			<cfset form.dayBtn = 'custom'>
		</cfif>

    </cffunction>
    
    <cffunction name="setDuration">
   	<cfargument name="nummin" required="yes"> 
		<cfset form.duration = nummin>
		<cfswitch expression="#nummin#">
        	<cfcase value="30"><cfset form.hrBtn = 'd'></cfcase>
        	<cfcase value="60"><cfset form.hrBtn = 'e'></cfcase>
        	<cfcase value="120"><cfset form.hrBtn = 'f'></cfcase>
        	<cfdefaultcase>
				<cfset form.hrBtn = 'custom'>
            
            </cfdefaultcase>
        </cfswitch>
    </cffunction>
    

    
    <cffunction name="setSelectedHour">
   	<cfargument name="tm" required="yes"> 
        <cfset form.starthour = timeformat(tm,"hh")>
        <cfset form.startmin = timeformat(tm,"mm")>
        <cfset form.starthourAMPM = timeformat(tm,"tt")>
    </cffunction>
    

    <cffunction name="daySelect">
    <cfargument name="showTimeSelect" default="true">
	<cfargument name="showDateSelect" default="false">
    <cfoutput>
    
        <script type="text/javascript">
            var g0 = ['x','y'];
            var g1 = ['a','b','c'];
            var g2 = ['d','e','f','g'];
        
            function sel(arr,chgto) {
                if (arr == g0)
                    get('strt').value = chgto;
                else if (arr == g1)
                    get('dayBtn').value = chgto;
                else
                    get('hrBtn').value = chgto;
            
                if (chgto == 'c' || chgto == 'g' || chgto == 'y') { 
                    get('resForm').submit();
                } else {
                    for (var i=0;i<arr.length;i++) {
                        get(arr[i]).className = 'ob';
                    }
                    get(chgto).className = 'obsel';
                }
            }
            function get(el) {
              return document.getElementById(el);
            }
        </script>
    
        <style type="text/css">
            .fieldrow {
                padding-left:10px;
            }
            .ob, .obsel {
                padding:2px;
                margin:1px;
                background:##ccc;
                border:1px solid ##aaa;
            }
            .obsel {
                background:##fff;
            }
        </style>
            
				<fieldset data-role="controlgroup" data-type="horizontal"> 
				<legend>Date:</legend>
                <cfif form.strt is "y" or form.strt is "custom" or arguments.showDateSelect>
                    <cfif form.dayBtn is "c" or form.dayBtn is "custom" or arguments.showDateSelect>
                        <select name="startMon">
                            <cfloop from="1" to="12" index="i">
                                <option <cfif form.startMon is dateformat("#i#-01-2000","mmm")>selected</cfif>>#dateformat("#i#-01-2000","mmm")#</option>
                            </cfloop>
                        </select>
                        <select name="startDay">
                            <cfloop from="1" to="31" index="i">
                                <option <cfif form.startDay is i>selected</cfif>>#i#</option>
                            </cfloop>
                        </select>
                        <select name="startYr">
                            <cfloop from="0" to="1" index="i">
                                <option <cfif form.startYr is (dateformat(now(),"yyyy")+i)>selected</cfif>>#dateformat(now(),"yyyy")+i#</option>
                            </cfloop>
                        </select>
                    <cfelse>
				    	<input type="radio" name="checkdate" id="a" class="custom" onclick="sel(g1,'a')" />
						<label for="a">Today</label>
			
						<input type="radio" name="checkdate" id="b" class="custom" onclick="sel(g1,'b')" />
						<label for="b">Tomorrow</label>
			
						<input type="radio" name="checkdate" id="c" class="custom" onclick="sel(g1,'c')" />
						<label for="c">+</label>  
                    </cfif>
					</fieldset>
                    
                   <cfif showTimeSelect>
						<fieldset data-role="controlgroup" data-type="horizontal">
						<legend>Time:</legend>
						<select name="starthour">				
                            <cfloop from="0" to="11" index="i">
                                <option <cfif form.starthour is timeformat(dateadd("h",i,"12:00 AM"),"h")>selected</cfif>>#timeformat(dateadd("h",i,"12:00 AM"),"h")#</option>
                            </cfloop>
                        </select>
						<select name="startMin">
                            <option <cfif form.startMin is "00">selected</cfif>>00</option>
                            <option <cfif form.startMin is "15">selected</cfif>>15</option>
                            <option <cfif form.startMin is "30">selected</cfif>>30</option>
                            <option <cfif form.startMin is "45">selected</cfif>>45</option>
                        </select>
                        <select name="starthourAMPM">
                            <option <cfif form.starthourAMPM is "AM">selected</cfif>>AM</option>
                            <option <cfif form.starthourAMPM is "PM">selected</cfif>>PM</option>
                        </select>
						</fieldset>
                    </cfif>
                <cfelse>
                    <a href="javascript:sel(g0,'x');" id="x" class="ob<cfif form.strt is "x">sel</cfif>">Now</a>  
                    <a href="javascript:sel(g0,'y');" id="y" class="ob<cfif form.strt is "y">sel</cfif>">Later...</a>
                </cfif>
                <input type="hidden" name="strt" id="strt" value="#form.strt#">
                <input type="hidden" name="dayBtn" id="dayBtn" value="#form.dayBtn#">
            
            <cfif showTimeSelect>
                    <cfif form.hrBtn is "g" or form.hrBtn is "custom">
                        <select name="duration">
                            <option value="15" <cfif form.duration is "15">selected</cfif>>15 min</option>
                            <option value="30" <cfif form.duration is "30">selected</cfif>>30 min</option>
                            <option value="45" <cfif form.duration is "45">selected</cfif>>45 min</option>
                            <option value="60" <cfif form.duration is "60">selected</cfif>>1 hour</option>
                            <option value="90" <cfif form.duration is "90">selected</cfif>>1.5 hours</option>
                            <option value="120" <cfif form.duration is "120">selected</cfif>>2 hours</option>
                            <option value="150" <cfif form.duration is "150">selected</cfif>>2.5 hours</option>
                            <option value="180" <cfif form.duration is "180">selected</cfif>>3 hours</option>
                            <option value="210" <cfif form.duration is "210">selected</cfif>>3.5 hours</option>
                            <option value="240" <cfif form.duration is "240">selected</cfif>>4 hours</option>
                        </select>
            
                    <cfelse>
					<fieldset data-role="controlgroup" data-type="horizontal">
					<legend>Duration</legend>
				    	<input type="radio" name="setdur" id="d" class="custom" onclick="sel(g2,'d')" />
						<label for="d">30m</label>
			
						<input type="radio" name="setdur" id="e" class="custom" onclick="sel(g2,'e')" />
						<label for="e">1h</label>
			
						<input type="radio" name="setdur" id="f" class="custom" onclick="sel(g2,'f')" />
						<label for="f">2h</label>
						
						<input type="radio" name="setdur" id="g" class="custom" onclick="sel(g2,'g')" />
						<label for="g">+</label>
					</fieldset>
                    </cfif>
                    <input type="hidden" name="hrBtn" id="hrBtn" value="#form.hrBtn#">
            </cfif>
            
    </cfoutput>
    </cffunction>
    



    <cffunction name="objForm">
    	<cfif not len(variables.memento.res_id) or userHasPermission(variables.memento.res_id,"","change")>
            <cfparam name="form.reminder" default="">
            <cfflush>
            <cfquery name="getRooms" datasource="phonebook">
                select * from rw_room  where  1 = 1
                <cfif not variables.isSystemAdmin>
                    and (access_reserve = 0 or access_reserve is null
                    or access_reserve in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                    or access_admin in (<cfqueryparam value="#variables.myGroups#" list="yes" cfsqltype="cf_sql_numeric">)
                    or room_id = <cfqueryparam value="#variables.memento.room_id#">
                    )
                </cfif>
                <cfif isdefined("url.loc") and len(url.loc)>
                    and loc_id = <cfqueryparam value="#url.loc#">
                </cfif>
                 order by roomname
            </cfquery>
    
            <cfif len(variables.memento.res_start)>
                <cfset form.start_date = dateformat(variables.memento.res_start,"mm/dd/yyyy")>
                <cfset form.end_date = dateformat(variables.memento.res_end,"mm/dd/yyyy")>
                <cfset form.start_time = timeformat(variables.memento.res_start,"hh:mm tt")>
                <cfset form.end_time = timeformat(variables.memento.res_end,"hh:mm tt")>
            </cfif>
    
            <cfif len(variables.memento.rw_booking_id)>
                <cfquery name="getReminder" datasource="phonebook">
                    select * from rw_res_notification  where booking_id = <cfqueryparam value="#variables.memento.rw_booking_id#">
                </cfquery>
                <cfif getReminder.recordcount gt 0>
                    <cfset form.reminder = getreminder.num_min>
                </cfif>
            </cfif>
    <!---<cfdump var="#variables.memento#">    	
    <cfdump var="#getRooms#"> --->   	
            <cfoutput>
				<div data-role="fieldcontain">
                <input type="hidden" name="rw_booking_id" value="#variables.memento.rw_booking_id#">      
                <legend>Room</legend>
                        <select name="room_id">
                            <cfloop query="getrooms">
                                <option value="#room_id#" <cfif variables.memento.room_id is room_id>selected</cfif>>#roomname#</option>
                            </cfloop>
                        </select>           
                <cfset daySelect(true)>
                
                <!---<script type="text/javascript">
                    var g0 = ['x','y'];
                    var g1 = ['a','b','c'];
                    var g2 = ['d','e','f','g'];
                
                    function sel(arr,chgto) {
                        if (arr == g0)
                            get('strt').value = chgto;
                        else if (arr == g1)
                            get('dayBtn').value = chgto;
                        else
                            get('hrBtn').value = chgto;
                    
                        if (chgto == 'c' || chgto == 'g' || chgto == 'y') { 
                            get('resForm').submit();
                        } else {
                            for (var i=0;i<arr.length;i++) {
                                get(arr[i]).className = 'ob';
                            }
                            get(chgto).className = 'obsel';
                        }
                    }
                    function get(el) {
                      return document.getElementById(el);
                    }
                </script>
    
                <style type="text/css">
                    .fieldrow {
                        padding-left:10px;
                    }
                    .ob, .obsel {
                        padding:2px;
                        margin:1px;
                        background:##ccc;
                        border:1px solid ##aaa;
                    }
                    .obsel {
                        background:##fff;
                    }
                </style>
                
                
              
                <p><strong>Start</strong> <br>
                <div class="fieldrow">
                
                    <cfif form.strt is "y" or  form.strt is "custom">
                        <cfif form.dayBtn is "c" or  form.dayBtn is "custom">
                            <p><select name="startMon">
                                <cfloop from="1" to="12" index="i">
                                    <option <cfif form.startMon is dateformat("#i#-01-2000","mmm")>selected</cfif>>#dateformat("#i#-01-2000","mmm")#</option>
                                </cfloop>
                            </select>
                            <select name="startDay">
                                <cfloop from="1" to="31" index="i">
                                    <option <cfif form.startDay is i>selected</cfif>>#i#</option>
                                </cfloop>
                            </select>
                            <select name="startYr">
                                <cfloop from="0" to="1" index="i">
                                    <option <cfif form.startYr is (dateformat(now(),"yyyy")+i)>selected</cfif>>#dateformat(now(),"yyyy")+i#</option>
                                </cfloop>
                            </select></p>
                        <cfelse>
                            <a href="javascript:sel(g1,'a');" id="a" class="ob<cfif form.dayBtn is "a">sel</cfif>">Today</a>  
                            <a href="javascript:sel(g1,'b');" id="b" class="ob<cfif form.dayBtn is "b">sel</cfif>">Tomorrow</a>  
                            <a href="javascript:sel(g1,'c');" id="c" class="ob<cfif form.dayBtn is "c">sel</cfif>">Other...</a>
                        </cfif>
                        
                       <p> at <select name="starthour">
                            <cfloop from="0" to="11" index="i">
                                <option <cfif form.starthour is timeformat(dateadd("h",i,"12:00 AM"),"h")>selected</cfif>>#timeformat(dateadd("h",i,"12:00 AM"),"h")#</option>
                            </cfloop>
                        </select>:<select name="startMin">
                            <option <cfif form.startMin is "00">selected</cfif>>00</option>
                            <option <cfif form.startMin is "15">selected</cfif>>15</option>
                            <option <cfif form.startMin is "30">selected</cfif>>30</option>
                            <option <cfif form.startMin is "45">selected</cfif>>45</option>
                        </select>
                        <select name="starthourAMPM">
                            <option <cfif form.starthourAMPM is "AM">selected</cfif>>AM</option>
                            <option <cfif form.starthourAMPM is "PM">selected</cfif>>PM</option>
                        </select></p>
                    <cfelse>
                        <a href="javascript:sel(g0,'x');" id="x" class="ob<cfif form.strt is "x">sel</cfif>">Now</a>  
                        <a href="javascript:sel(g0,'y');" id="y" class="ob<cfif form.strt is "y">sel</cfif>">Later...</a>
                    </cfif>
                    
                    <input type="hidden" name="strt" id="strt" value="#form.strt#">
                    <input type="hidden" name="dayBtn" id="dayBtn" value="#form.dayBtn#">
                    
                </div>
    
                <p><strong>Duration</strong> <br>
                <div class="fieldrow">
                    <cfif form.hrBtn is "g" or form.hrBtn is "custom">
                        <select name="duration">
                            <option value="15" <cfif form.duration is "15">selected</cfif>>15 min</option>
                            <option value="30" <cfif form.duration is "30">selected</cfif>>30 min</option>
                            <option value="45" <cfif form.duration is "45">selected</cfif>>45 min</option>
                            <option value="60" <cfif form.duration is "60">selected</cfif>>1 hour</option>
                            <option value="90" <cfif form.duration is "90">selected</cfif>>1.5 hours</option>
                            <option value="120" <cfif form.duration is "120">selected</cfif>>2 hours</option>
                            <option value="150" <cfif form.duration is "150">selected</cfif>>2.5 hours</option>
                            <option value="180" <cfif form.duration is "180">selected</cfif>>3 hours</option>
                            <option value="210" <cfif form.duration is "210">selected</cfif>>3.5 hours</option>
                            <option value="240" <cfif form.duration is "240">selected</cfif>>4 hours</option>
                        </select>
            
                    <cfelse>
                        <a href="javascript:sel(g2,'d');" id="d" class="ob<cfif form.hrBtn is "d">sel</cfif>">30 min.</a>  
                        <a href="javascript:sel(g2,'e');" id="e" class="ob<cfif form.hrBtn is "e">sel</cfif>">1 hour</a>  
                        <a href="javascript:sel(g2,'f');" id="f" class="ob<cfif form.hrBtn is "f">sel</cfif>">2 hours</a> 
                        <a href="javascript:sel(g2,'g');" id="g" class="ob<cfif form.hrBtn is "g">sel</cfif>">Other...</a>
                    </cfif>
                    <input type="hidden" name="hrBtn" id="hrBtn" value="#form.hrBtn#">
                </div>--->
    
                <legend>Reservation Title</legend>
                <input type="text" name="purpose" value="#variables.memento.purpose#" />
				</div>
            </cfoutput>
		<cfelse>
        	<cfoutput>You do not have access to edit this reservation</cfoutput>
        </cfif>
    </cffunction>
    
    
    <cffunction name="save">
        <cfset variables.memento = getMemento_Form()/>

        <cfif url.task is "edit">
			<cfset displayForm()>
        <cfelse>
			<cfif not isRefresh()>
				<cfset result = validate()/>
    
                <cfif len(result)>
                    <cfset displayForm(result) />
                <cfelse>
                        <cfif len(evaluate("variables.memento.#variables.identifier#"))>
                            <cfset result = updateSql()/>
                        <cfelse>
                            <cfset result = insertSql()/>
                        </cfif>
                        
                        <cfif not result.success>
                             <cfoutput><div class="alert">#result.reason#<br>Your reservation was not saved.</div></cfoutput>
                            <cfset getMemento_Form()>
                            <cfif len(form.res_id)>
                                <cfset edit()>
                            <cfelse>
                                <cfset new()>
                            </cfif>					
                        <cfelse>
                            <cfoutput><div class="alert">The #variables.myTypeFriendly# was successfully saved.</div>#showPostSubmit()#</cfoutput>
                        </cfif>
                    <cfset saveDupeMemento()>
                </cfif>
            <cfelse>
            	<cfset showmenu()>
			</cfif>
		</cfif>
     </cffunction>


    <cffunction name="displayForm">
    <cfargument name="resultTxt" required="no" default="">
    
        <cfhtmlhead text="<link rel=stylesheet href=""/style/general_memento.css"">">
        <cfif len(resultTxt)>
            <cfoutput><div class="alert">Error: The #variables.myTypeFriendly# could not be saved. <ul>#resultTxt#</ul></div></cfoutput>
        </cfif>
        <cfoutput>
            <form method="post" id="resForm" action="#encodeURL("?task=save&type=#variables.mytype#&book=#variables.memento.rw_booking_id#")#" data-ajax="false">
                <input type="hidden" name="#variables.identifier#" value="#evaluate("variables.memento.#variables.identifier#")#">
                <cfset objForm()/>
                <cfif len(variables.memento.res_id)>
                    <input type="submit" class="submit" name="save_event" value="save changes" />
                    </form>
                    <form method="post" action="#encodeURL("?task=delete&type=#variables.mytype#&id=#variables.memento.res_id#&book=#variables.memento.rw_booking_id#")#" style="display:inline">
                   	<input type="submit" class="submit" name="save_event" value="cancel reservation" />
				<cfelse>
                    <input type="submit" class="submit" name="save_event" value="reserve &raquo;" />
				</cfif>
                (all fields required)
            </form>
        </cfoutput>
    </cffunction>



    <cffunction name="delete">
        <cfif structKeyExists(form,"confirmDelete")>
            <cfset doDeletion()/>
            <cfoutput>
                <div class="alert">The #variables.myTypeFriendly# has been deleted.</div>
				 
            </cfoutput>
            <cfset showMenu()>
        <cfelseif structKeyExists(form,"cancelDelete")>
            <cfset showMenu()>
        <cfelse>
            <cfoutput>
                #mySummary()#
                <p>Are you sure you want to delete this #variables.myTypeFriendly#?</p>
                <form method="post" action="?#cgi.QUERY_STRING#">
                    <input type="submit" class="submit" name="cancelDelete" value="cancel" onclick="finished();"/>                    	
                    <input type="submit" class="submit" name="confirmDelete" value="yes"/>
                </form>
            </cfoutput>
        </cfif>
    </cffunction>

   
   
	<!---<cffunction name="view">
    	<cfquery name="getRes" datasource="phonebook">
            select * from rw_res res join rw_room room on res.room_id = room.room_id
            where res_id = <cfqueryparam value="#url.id#">
        </cfquery>

        <cfif getres.recordcount is 0>
			<cfif isdefined("url.book")>
                <cfquery name="getRes" datasource="phonebook">
                    select * from rw_res res join rw_room room on res.room_id = room.room_id
                    where rw_booking_id = <cfqueryparam value="#url.book#">
                </cfquery>
			</cfif>
			<cfif getres.recordcount is 0>
				<cfoutput>
					<h4>Reservation Not Found</h4>
                    <p>We're sorry, the reservation you are attempting to view has not been found. It might have been edited or deleted since you loaded the page. <strong>Please refresh the grid display to get an up to date reservation listing.</strong></p>

                    <p><a href="javascript:finished();">Close Window and Refresh Availability</a>    </p>      
                    <script type="text/javascript">
						window.onunload = finished;
                        function finished() {                            
							window.parent.doResubmit();
                        }
                    </script>             
				</cfoutput>
            </cfif>
		</cfif>
        
        <cfoutput query="getres">
	    	<cfif userHasPermission(res_id,"","change")>           
            	<div style="margin:6px 1px;padding:6px;border:1px dotted ##ccc;width:150px;color:red;float:right;margin-right:10px;text-align:center">
					<p>Modify this reservation:</p>
                
                    <form method="post" action="?task=edit&id=#res_id#&book=#rw_booking_id#" >                	
                        <input type="submit" class="submit" value="edit">
                    </form>                
                    <form method="post" action="?task=delete&id=#res_id#&book=#rw_booking_id#" >                	
                        <input type="submit" class="submit" value="delete">
                    </form>                
                </div>
			</cfif>
            
            <cfset resLength = datediff("n",res_start,res_end)>
            <cfif resLength is 60>
            	<cfset resLength = "1 hour">            
            <cfelseif resLength gt 60>
            	<cfset resLength= replace(numberformat(resLength/60,"9.9"),".0","") & " hours">
			<cfelse>
            	<cfset resLength= resLength & " minutes">
			</cfif>
            
            <h4>Reservation Detail</h4>
            <cfif dateformat(res_start) is dateformat(res_end)>
                <p><strong>Date: </strong> #dateformat(res_start,"dddd, mmmm d, yyyy")#<br>
				<strong>Time:</strong>  #timeformat(res_start,"h:mm tt")# to #timeformat(res_end,"h:mm tt")#  (#resLength#)  </p>            
			<cfelse>
                <p><strong>Start: </strong> #dateformat(res_start,"dddd, mmmm d, yyyy")# at #timeformat(res_start,"h:mm tt")#<br> 
                <strong>End:</strong> #dateformat(res_end,"dddd, mmmm d, yyyy")# at #timeformat(res_end,"h:mm tt")#</p> 
			</cfif>
            
            <p><strong>Room:</strong> #roomname#</p> 
            <cfif not variables.myClass is "student">
                <p><strong>Purpose:</strong> #purpose#<br> 
                <cfif len(hostname)><strong>Creator:</strong> #hostname#<br></cfif>
                <cfif len(hostemail)><strong>Contact:</strong> #hostemail#<br></cfif>
			</cfif>

            <cfif len(loc_id) and len(floc_id) and loc_id is not 0 and floc_id is not 0>
				<cfset displayFloorImage(floc_id)>
			</cfif>
            
        </cfoutput>
    </cffunction>


    <cffunction name="displayFloorImage">
    <cfargument name="floc_id" required="no" default="">
        
		<cfset imageHeight = 280>    
            
        <cfquery name="getIMG" datasource="phonebook">
            select * from floor_image_loc fl left join floor_image fi on fl.fid = fi.fid
            where fl.floc_id = <cfqueryparam value="#floc_id#">           
        </cfquery>
        
        <cfset transformRatio = imageHeight/getIMG.imheight>
            
        <cfif getIMG.recordcount gt 0>
            <cfoutput>
                <div style="position: relative;left:20px;top:0px;height:#imageHeight#px;"><!---#getIMG.imheight#px--->
                    <div style="position:absolute;left:0px;top:0px;"><img src="#getIMG.image_path#" style="height:#imageHeight#px" /></div>
                    <div style="position:absolute;left:#getIMG.loc_x*transformRatio#px;top:#(getIMG.loc_y*transformRatio-44)#px"><img src="/phonebook/images/arrow.gif" /></div>
                </div>
            </cfoutput>
        
        </cfif>
    </cffunction>

--->

</cfcomponent>