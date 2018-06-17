function website_search(){
    var keyword = $("#q").val();
    $.get( "/api/search?keyword="+keyword, function( data ) {
        html = "";
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
    var array = dat.split('|');
    var keyword = array[0];
    var url = array[1];
    var title = array[2];

     $.get( "/api/video_status?keyword="+keyword+"&video_name="+title+"&video_url="+url, function( data ) {
         html = "";
         if(data.status!=undefined){
             if (data.status==0 || data.status==1){
                 settimeout("website_watch('"+data+"')", 5000);
             }else{
                 window.location = "/watch.html?data="+data
             }
         }else{
             alert(data.msg);
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
