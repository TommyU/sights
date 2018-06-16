function website_search(){
    var keyword = $("#q").val();
    $.get( "/api/search?keyword="+keyword, function( data ) {
      	html = ""
	if(data.msg != undefined){
            $("result").html(data.msg)
        }else{
            for(var i=0;i<data.items.length;i++){
	        html +="<tr><td>" + (i+1) + "</td>";
	        html +="<td>"+data.items[i].htmlTitle+"</td>";
	        html +="<td>"+ data.items[i].link +"</td></tr>";
	    }
	    $( "#result" ).html(html);
        }
    });
}

$(function(){
    $('form').submit(false);  //disable submit of forms
    $('#q').bind('keypress', function(event){
        if(event.keyCode == "13"){
            website_search();
	    }
    });
});
