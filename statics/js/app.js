function website.search(){
    var keyword = $("#q").val();
    $.get( "/api/search?keyword"+keyword, function( data ) {
      $( "#result" ).html( data );
    });
}