		function navmenu(n,m,a) {
			var access = a;
		    $.ajax({
		     type: "GET",
		     url: 'http://m.scu.edu/nav/'+n+'.json',
		     dataType: 'json',
		     beforeSend: function(x) {
		      if(x && x.overrideMimeType) {
		       x.overrideMimeType("application/j-son;charset=UTF-8");
		      }
			 },
			 success: function(data){
			 	var output = '';
			    for (var i in data.menuitems) {
				    output += '<li><a href="' + data.menuitems[i].href + '"';
				    if(data.menuitems[i].rel == 'external') {
				    	output += ' target="_system"';
				    }
				    output += ' data-ajax="false"';
				    output += '>';
				    output += data.menuitems[i].label;
				    output += '</a></li>';
		        }
				$("#"+m).append(output);
				if (access != 'local') {
					$("#"+m).listview("refresh");
				}				
		     }
			});
		}
		