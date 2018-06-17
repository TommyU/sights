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

function website_watch(video_data){
    console.log(video_data);
    var array = video_data.split('|');
    var keyword = btoa(array[0]);
    var url = btoa(array[1]);
    var title = btoa(array[2]);

     $.get( "/api/video_status?keyword="+keyword+"&video_name="+title+"&video_url="+url, function( data ) {
         html = "";
         if(data.status!=undefined){
             if (data.status==0 || data.status==1){
                 setTimeout("website_watch('"+video_data+"')", 5000);
             }else{
                 //window.location = "/watch.html?data="+video_data
                 var video_uri = data.video_uri
                 if(video_uri==undefined){
                     alert("server error!");
                 }else{
                     var v_html = '<video id="player" width="100%" height="auto" autoplay="autoplay" controls>';
                     v_html+='<source src="'+video_uri+" type="video/mp4" codecs="avc1.42E01E, mp4a.40.2"> </video>';
                     $("#panel_list").toggle();
                     $("#panel_display").toggle();
                     $("#panel_display").html(v_html);
                 }
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
