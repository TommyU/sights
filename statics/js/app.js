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
    //$("#panel_list").hide();
    var container_id="#myMovie";
    var movie_container="#myMovieBody";
    $(container_id).show();

     $.get( "/api/video_status?keyword="+keyword+"&video_name="+title+"&video_url="+url, function( data ) {
         html = "";
         if(data.status!=undefined){
             if (data.status==0 || data.status==1){
                 var html_loading = '<div class="progress">' + 
                   '<div class="progress-bar progress-bar-striped progress-bar-warning active" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100" style="width: 75%">' + 
                    '<span class="sr-only">75% Complete</span>' +
                   '</div>' +
                  '</div>';
                 $(movie_container).html("<h1>loading...</h1>" + html_loading);
                 video_data = btoa(video_data);
                 setTimeout("website_watch('"+video_data+"')", 1000);
             }else{
                 var video_uri = data.video_uri
                 if(video_uri==undefined){
                     $(movie_container).html("<h1>server error!.</h1>" );
                 }else{
                     var $dom =$("#player", $(movie_container))
                     if($dom && $dom.attr("userdata")==video_data){

                     }else{
                         var v_html = '<video id="player" width="100%" height="auto" autoplay="autoplay" userdata="'+video_data+'" controls>';
                         v_html+='<source src="'+video_uri+'" type="video/mp4" codecs="avc1.42E01E, mp4a.40.2"> </video>';
                         $(movie_container).html(v_html);
                         $("#myMovieShare").html("<a href='javascript:void(0)' onclick=copy2clipboard('http://"+window.location.host+"/v/watch?hash="+data.hash+"')>分享链接</a>")
        $("#btn_pause_mv").bind("click", function(){
            $("#player").get(0).pause();
            $(container_id).hide();
        });
                     }
                 }
             }
         }else{
             alert(data.msg);
             $(movie_container).html("<h1>server error!.</h1>" + data.msg);
         }
     });
}

function watch_by_hash(hash){
    $("#myMovie").show();

    var $dom =$("#player", $("#myMovie"))
    if($dom && $dom.attr("userdata")==hash){
        //$("#panel_display").max_size();
    }else{
        var v_html = '<video id="player" width="100%" height="auto" autoplay="autoplay" userdata="'+hash+'" controls>';
        v_html+='<source src="/videos/'+hash+'.mp4" type="video/mp4" codecs="avc1.42E01E, mp4a.40.2"> </video>';
        $("#myMovieBody").html(v_html);
        $("#myMovieShare").html("<a href='javascript:void(0)' onclick=copy2clipboard('http://"+window.location.host+"/v/watch?hash="+hash+"')>分享链接</a>")
        $("#btn_pause_mv").bind("click", function(){
            $("#player").get(0).pause();
            $("#myMovie").hide();
        });
    }
}

function delete_video(hash){
    console.log("will delete video:"+hash);
}

function display_disk_usage(){
    $.get( "/api/disk_usage", function( data ) {
        html = "";
        if(data.msg != undefined){
            $("#panel_watched_list").html(data.msg)
        }else{
            $("#myModalLabel").html("disk usages");
            $("#myModalBody").html("<pre>" + data + "</pre>");
            $("#myModal").show();
        }
    });
}

function update_video_sizes(){
    $.get( "/api/update_video_sizes", function( data ) {
        html = "";
        if(data.msg != undefined){
            $("#myModalLabel").html("on updating sizes");
            $("#myModalBody").html("<p>" + data.msg + "</p>");
            $("#myModal").show();
        }
    });
}

function display_downloaded_list(){
    $.get( "/api/watched_list", function( data ) {
        html = "";
        if(data.msg != undefined){
            $("result_watched_list").html(data.msg)
        }else{
            for(var i=0;i<data.length;i++){
                var date_obj = new Date(data[i].last_downloaded_time*1000);
                html +="<tr><td>" + (i+1) + "</td>";
                html +="<td>"+date_obj.toLocaleDateString() + date_obj.toLocaleTimeString()+"</td>";
                html +="<td>"+data[i].downloaded_times+"</td>";
                html +="<td><a href='javascript:void(0)' onclick=watch_by_hash(\""+data[i].hash+"\")>"+decodeURI(data[i].video_name)+"</a></td>";
                html +="<td>"+decodeURI(data[i].keyword)+"</td>";
                html +="<td>"+Math.round(data[i].video_size/1048576)+"M </td>";
                html +="<td>"+(data[i].is_deleted==1?'Y':'N')+"</td>";
                html +='<td><button class="btn btn-info mr-sm-1" type="button" onclick=delete_video(\''+data[i].hash+'\')>del</button></td></tr>';
	        }
	        $( "#result_watched_list" ).html(html);
        }
    });
}

function copy2clipboard(value) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val(value).select();
    document.execCommand("copy");
    $temp.remove();
}

$(function(){
    $('form').submit(false);  //disable submit of forms
    $('#q').bind('keypress', function(event){
        if(event.keyCode == "13"){
            website_search();
	    }
    });
});
