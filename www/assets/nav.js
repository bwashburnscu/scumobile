$("#navpage").live("pageshow", function(e) {
	  var navstring = getUrlVars()["nav"];
		if(!navstring || navstring == ''){
			navstring = 'main';
			}
	  $.ajax({
		  type: "GET",
		  url: 'http://test01.scu.edu/nav/'+navstring+'.json',
		  dataType: 'json',
		     beforeSend: function(x) {
		      if(x && x.overrideMimeType) {
		       x.overrideMimeType("application/j-son;charset=UTF-8");
		      }
			 },
			 success: function(data){
			 	var output = '';
			    for (var i in data.menuitems) {
				    output += '<li><a href="' + data.menuitems[i].href + '" rel="external">';
				    output += data.menuitems[i].label;
				    output += '</a></li>';
		        }
				$("#primary-nav ul").append(output).listview("refresh");
		     }
			});
		});
		
function getUrlVars() {
	var vars = [], hash;
	var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
	for(var i = 0; i < hashes.length; i++)
	    {
	        hash = hashes[i].split('=');
	        vars.push(hash[0]);
	        vars[hash[0]] = hash[1];
	    }
	return vars;
	}