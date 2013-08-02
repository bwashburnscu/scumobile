<cfprocessingdirective suppressWhiteSpace="true">
<cfsavecontent variable="htmlstring">
<cfif url.type IS "note" or url.type IS "obit">
<cfinclude template="/web/cms/scm/classnotes/customcf/index.cfm" />
<cfelseif url.type IS "submit">
<cfinclude template="/web/cms/scm/classnotes/customcf/submit.cfm" />
</cfif>
</cfsavecontent>
</cfprocessingdirective>

<cfhtmlhead text='
<link rel="stylesheet" href="/survey/customcf/survey.css" />
'/><!---  --->

<!DOCTYPE html> 
<html> 
	<head> 
	<title>Alumni</title>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="../assets/jquery.mobile-1.3.2.min.css" />
	<link rel="stylesheet" href="../assets/scu.css" />
	<link rel="stylesheet" href="../assets/secondary.css" />
	<script src="../assets/jquery-1.10.2.min.js"></script> 
	<script src="../assets/jquery.mobile-1.3.2.min.js"></script>
	<script src="../assets/submenu.js"></script>
	<link rel="stylesheet" href="../assets/submenu.css" /> 
   
	</head> 
<body>  

<div data-role="page" class="type-interior" data-theme="a">
	<script src="../assets/navmenu.js"></script>
	<script src="../assets/geturlvars.js"></script>
	<div id="header" data-add-back-btn="true">
		<a href="../index.html" data-ajax="false" class="homenav"><img alt="" src="../assets/38-house.png" /></a>
	</div><!-- /header -->

	<div data-role="content">
		<div class="content-primary">
		<h2 id="ialumni" class="pagetitle"><a data-ajax="false" href="../alumni.html">Alumni</a></h2>
			<nav id="mobile">
			    <a class="navicon mtoggle" href="#">MAIN MENU</a>	
			    <ul id="submenu"></ul>    
			    <script>
			    	navmenu('classnotes','submenu');
			    </script>
			</nav>
		<div id="subtitle">Class Notes</div>
		<div data-role="collapsible">
			<h4>Search Class Notes</h4>
			<cfset attributes.formtype = 'mobile' />
			<cfinclude template="/web/cms/scm/classnotes/customcf/rc-filter.cfm" />
		</div>
    	<div id="pagecontent">
		<cfoutput>#htmlstring#</cfoutput>
		</div>
	</div>
		<div class="content-secondary">
		<!--- <cfif url.type IS "note" or url.type IS "obit"> --->

		<!--- </cfif> --->
		<ul id="fullmenu" data-role="listview" data-inset="true"></ul>
			    <script>
				    navmenu('classnotes','fullmenu');
			    </script>
		</div>
	
	</div>
	
	<div data-role="footer" id="footer">
		<p style="text-align:center;">&copy; Santa Clara University</p>
	</div><!-- /footer -->
</div><!-- /page -->

</body>
</html>
