function website_search(){
    var keyword = $("#q").val();
    $.get( "/api/search?keyword="+keyword, function( data ) {
        if($("#panel_list").is(":visible")==false){
           $("#panel_list").toggle();
           $("#player").get(0).pause();
           $("#panel_display").toggle();
        }

        html = "";
        if(data.msg != undefined){
            $("result").html(data.msg)
        }else{
            for(var i=0;i<data.items.length;i++){
                html +="<tr><td>" + (i+1) + "</td>";
                html +="<td>"+data.items[i].htmlTitle+"</td>";
                html +="<td>"+ data.items[i].link +"</td>";
                var sb = encodeURI(keyword) + "|" + encodeURI(data.items[i].link) +"|" + encodeURI(data.items[i].title);
                sb = btoa(sb);
                html +='<td><button class="btn btn-info mr-sm-1" type="button" onclick=website_watch(\''+sb+'\')>view</button></td></tr>';
	        }
	        $( "#result" ).html(html);
        }
    });
}

function website_watch(video_data){
    video_data = atob(video_data);
    console.log(video_data);
    var array = video_data.split('|');
    var keyword = btoa(array[0]);
    var url = btoa(array[1]);
    var title = btoa(array[2]);
    $("#panel_list").hide();
    $("#panel_display").show();

     $.get( "/api/video_status?keyword="+keyword+"&video_name="+title+"&video_url="+url, function( data ) {
         html = "";
         if(data.status!=undefined){
             if (data.status==0 || data.status==1){
                 var html_loading = '<div class="progress">' + 
                   '<div class="progress-bar progress-bar-striped progress-bar-warning active" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100" style="width: 75%">' + 
                    '<span class="sr-only">75% Complete</span>' +
                   '</div>' +
                  '</div>';
                 $("#panel_display").html("<h1>loading...</h1>" + html_loading);
                 video_data = btoa(video_data);
                 setTimeout("website_watch('"+video_data+"')", 1000);
             }else{
                 //window.location = "/watch.html?data="+video_data
                 var video_uri = data.video_uri
                 if(video_uri==undefined){
                     alert("server error!");
                 }else{
                     var $dom =$("#player", $("#panel_display"))
                     if($dom && $dom.attr("userdata")==video_data){
                         //$("#panel_display").max_size();
                     }else{
                         var v_html = '<video id="player" width="100%" height="auto" autoplay="autoplay" userdata="'+video_data+'" controls>';
                         v_html+='<source src="'+video_uri+'" type="video/mp4" codecs="avc1.42E01E, mp4a.40.2"> </video>';
                         $("#panel_display").html(v_html);
                     }
                 }
             }
         }else{
             alert(data.msg);
         }
     });
}

function delete_video(hash){
    console.log("will delete video:"+hash);
}

function display_downloaded_list(){
    $.get( "/api/watched_list", function( data ) {
        html = "";
        if(data.msg != undefined){
            $("result").html(data.msg)
        }else{
            for(var i=0;i<data.length;i++){
                html +="<tr><td>" + (i+1) + "</td>";
                html +="<td>"+data[i].last_downloaded_time+"</td>";
                html +="<td>"+data[i].downloaded_times+"</td>";
                html +="<td>"+data[i].video_name+"</td>";
                html +="<td>"+data[i].keyword+"</td>";
                html +="<td>"+data[i].video_size+"</td>";
                html +="<td>"+data[i].is_deleted+"</td>";
                html +='<td><button class="btn btn-info mr-sm-1" type="button" onclick=delete_video(\''+data[i].hash+'\')>delete</button></td></tr>';
	        }
	        $( "#result_watched_list" ).html(html);
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
