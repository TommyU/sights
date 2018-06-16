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
	        html +="<td>"+ data.items[i].link +"</td>";
		var sb = encodeURI(keyword) + "|" + encodeURI(data.items[i].link) +"|" + encodeURI(data.items[i].title);
	        html +='<td><button class="btn btn-info mr-sm-1" type="button" onclick=website_watch(\''+sb+'\')>view</button></td></tr>';
	    }
	    $( "#result" ).html(html);
        }
    });
}

function website_watch(dat){
    console.log(dat);
}

$(function(){
    $('form').submit(false);  //disable submit of forms
    $('#q').bind('keypress', function(event){
        if(event.keyCode == "13"){
            website_search();
	    }
    });
});
