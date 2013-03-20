var filter ="";

 $(document).ready(function() {
 	  $('#search').keyup(function(e) {
			filter = "&fi=" +$('#search').val();
			if(e.keyCode == 13) {
				filter = "&fi=" +$('#search').val();
			}
		});
		$('#search').focus();
		
		

   var refreshId = setInterval(function() {
	$.get("/API/search.pl?tp=host" + filter,function(data){
		$("#host").html(data);
		});
	$.get("/API/search.pl?tp=group" + filter,function(data){
		$("#group").html(data);
		});
   }, 1000);
   $.ajaxSetup({ cache: false });
});

function affSearch(){
	$("#search").css("display","");
}

function hideSearch(){
	$("#search").css("display","none");
}

function moreHost(){
	morehost = "&mo=more";
}

function lessHost(){
	morehost = "";
}

function resSearch(){
	$('#text-search').val('');
	filter = '';
	hideSearch();
}
