var morehost = "";
var filter ="";

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
	filter = "";
	hideSearch();
}

$(document).ready(function() {
	$.get("/API/getgroup.pl?st=ok" + morehost + filter,function(data){
		$("#group-list").html(data);
		});
	$('#text-search').keyup(function(e) {
			filter = "&fi=" +$('#text-search').val();
			if(e.keyCode == 13) {
				filter = "&fi=" +$('#text-search').val();
			}
		});
	$('#form-search').submit(function() {
			filter = "&fi=" +$('#text-search').val();		
		});
	var refreshId = setInterval(function() {
		$.get("/API/getgroup.pl?st=ok" + morehost + filter,function(data){
		$("#group-list").html(data);
		});
	 }, 1000);
   $.ajaxSetup({ cache: false });
	
});