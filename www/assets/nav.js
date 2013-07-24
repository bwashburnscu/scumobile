$(".navpage").on("pageshow", function(e) {
	  if(!navstring || navstring == ''){
			navstring = 'main';
			}
	  $.ajax({
		  type: "GET",
		  url: 'http://m.scu.edu/nav/'+navstring+'.json',
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
		
