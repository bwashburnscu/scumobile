<cfsetting showdebugoutput="yes" />
<cfset url.v = "m" />
<cfparam name="url.type" default="submit" />

<cfparam name="form.showtype" default="">
<cfparam name="form.showdt" default=">01">
<cfparam name="form.showGrad" default="">
<cfparam name="form.showschool" default="">
<cfparam name="form.showyears" default="">
<cfparam name="form.searchq" default="">

<cfset attributes.pagetitle = "Class Notes" />
<cfset attributes.fullsite = "http://www.scu.edu/scm/classnotes/" />
<cfparam name="attributes.sitecookie" default="classnotes" />

<cfif form.showtype is "obit">
	<cfset url.type = "obit">
<cfelseif listfind("wedding announcements,birth announcements,work updates",form.showtype)>
	<cfset url.type = "note">
</cfif>

<cfset variables.xslpath = "/web/apps/mobile/xsl/class_2.xsl" />

<cfset xslparams = StructNew()>
